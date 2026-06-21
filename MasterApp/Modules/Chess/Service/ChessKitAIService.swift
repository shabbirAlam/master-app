import Foundation
import ChessKitEngine

enum ChessKitAIError: Error, LocalizedError {
    case engineNotReady
    case bestMoveNotFound
    case invalidMove(String)
    case engineStopped
    case nnueDownloadFailed(String)

    var errorDescription: String? {
        switch self {
        case .engineNotReady: "Chess engine is not ready yet"
        case .bestMoveNotFound: "Engine did not return a move"
        case .invalidMove(let uci): "Engine returned invalid move: \(uci)"
        case .engineStopped: "Engine was stopped"
        case .nnueDownloadFailed(let reason): "Failed to download chess engine data: \(reason)"
        }
    }
}

protocol ChessKitAIService: Sendable {
    func selectMove(from game: GameState, for color: PieceColor, moveTime milliseconds: Int) async throws -> Move?
    func start() async
    func stop() async
}

actor ChessKitAIServiceImpl: ChessKitAIService {
    private let engine: Engine
    private var streamTask: Task<Void, Never>?
    private var moveContinuation: CheckedContinuation<String, Error>?
    private var isReady = false

    nonisolated private static let nnueMain = "nn-1111cefa1111"
    nonisolated private static let nnueSmall = "nn-37f18f62d772"

    init() {
        self.engine = Engine(type: .stockfish, loggingEnabled: false)
    }

    func start() async {
        await ensureNNUEFiles()

        await engine.start()

        streamTask = Task { [weak self] in
            guard let stream = await self?.engine.responseStream else { return }
            for await response in stream {
                guard let self else { return }
                await handleResponse(response)
            }
        }

        while !(await engine.isRunning) {
            try? await Task.sleep(nanoseconds: 10_000_000)
        }

        await setNNUEOptions()

        isReady = true
    }

    func stop() async {
        streamTask?.cancel()
        streamTask = nil
        moveContinuation?.resume(throwing: ChessKitAIError.engineStopped)
        moveContinuation = nil
        await engine.stop()
        isReady = false
    }

    func selectMove(from game: GameState, for color: PieceColor, moveTime milliseconds: Int = 2000) async throws -> Move? {
        guard isReady else { throw ChessKitAIError.engineNotReady }

        let uciMoves = game.moveHistory.map(\.uci)

        let moveString = try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<String, Error>) in
                self.moveContinuation?.resume(throwing: ChessKitAIError.engineStopped)
                self.moveContinuation = continuation
                Task {
                    await engine.send(command: .position(.startpos, moves: uciMoves))
                    await engine.send(command: .go(movetime: milliseconds))
                }
            }
        } onCancel: {
            Task { [weak self] in
                await self?.cancelMove()
            }
        }

        return parseUCIMove(moveString, in: game, for: color)
    }

    private func cancelMove() async {
        moveContinuation?.resume(throwing: CancellationError())
        moveContinuation = nil
    }

    private func handleResponse(_ response: EngineResponse) {
        if case .bestmove(let move, _) = response {
            moveContinuation?.resume(returning: move)
            moveContinuation = nil
        }
    }

    private func ensureNNUEFiles() async {
        let fileManager = FileManager.default
        guard let cachesDir = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            await AppLogger.chessAI.log("Cannot access caches directory for NNUE files", .error)
            return
        }

        let mainNNUE = cachesDir.appendingPathComponent("\(Self.nnueMain).nnue")
        let smallNNUE = cachesDir.appendingPathComponent("\(Self.nnueSmall).nnue")

        if fileManager.fileExists(atPath: mainNNUE.path), fileManager.fileExists(atPath: smallNNUE.path) {
            await AppLogger.chessAI.log("NNUE files already cached", .info)
            return
        }

        await AppLogger.chessAI.log("NNUE files not found, downloading...", .notice)

        if !fileManager.fileExists(atPath: mainNNUE.path) {
            await downloadNNUE(name: Self.nnueMain, to: mainNNUE)
        }
        if !fileManager.fileExists(atPath: smallNNUE.path) {
            await downloadNNUE(name: Self.nnueSmall, to: smallNNUE)
        }
    }

    private func downloadNNUE(name: String, to destination: URL) async {
        let urlString = "https://tests.stockfishchess.org/api/nn/\(name).nnue"
        guard let url = URL(string: urlString) else {
            await AppLogger.chessAI.log("Invalid NNUE URL: \(urlString)", .error)
            return
        }

        do {
            let request = URLRequest(url: url, timeoutInterval: 30)
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                await AppLogger.chessAI.log("NNUE download failed: HTTP \((response as? HTTPURLResponse)?.statusCode ?? -1)", .error)
                return
            }
            try data.write(to: destination)
            await AppLogger.chessAI.log("Downloaded \(name).nnue (\(data.count) bytes)", .info)
        } catch {
            await AppLogger.chessAI.log("Failed to download \(name).nnue: \(error.localizedDescription)", .error)
        }
    }

    private func setNNUEOptions() async {
        let fileManager = FileManager.default
        guard let cachesDir = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first else { return }

        let mainNNUE = cachesDir.appendingPathComponent("\(Self.nnueMain).nnue")
        if fileManager.fileExists(atPath: mainNNUE.path) {
            await engine.send(command: .setoption(id: "EvalFile", value: mainNNUE.path))
            await AppLogger.chessAI.log("Set EvalFile to \(mainNNUE.path)", .info)
        }

        let smallNNUE = cachesDir.appendingPathComponent("\(Self.nnueSmall).nnue")
        if fileManager.fileExists(atPath: smallNNUE.path) {
            await engine.send(command: .setoption(id: "EvalFileSmall", value: smallNNUE.path))
            await AppLogger.chessAI.log("Set EvalFileSmall to \(smallNNUE.path)", .info)
        }
    }

    private func parseUCIMove(_ uci: String, in game: GameState, for color: PieceColor) -> Move? {
        guard uci.count >= 4 else { return nil }
        let chars = Array(uci)

        guard let fromColVal = chars[0].asciiValue,
              let fromRowVal = chars[1].asciiValue,
              let toColVal = chars[2].asciiValue,
              let toRowVal = chars[3].asciiValue else {
            return nil
        }

        let fromCol = Int(fromColVal - 97)
        let fromRow = 7 - Int(fromRowVal - 49)
        let toCol = Int(toColVal - 97)
        let toRow = 7 - Int(toRowVal - 49)

        guard (0..<8).contains(fromRow), (0..<8).contains(fromCol),
              (0..<8).contains(toRow), (0..<8).contains(toCol) else {
            return nil
        }

        let from = Position(row: fromRow, col: fromCol)
        let to = Position(row: toRow, col: toCol)

        let promotion: PieceType?
        if uci.count == 5 {
            switch chars[4] {
            case "q": promotion = .queen
            case "r": promotion = .rook
            case "b": promotion = .bishop
            case "n": promotion = .knight
            default: promotion = nil
            }
        } else {
            promotion = nil
        }

        let captured = game.piece(at: to)
        let isCastling: Bool
        if let piece = game.piece(at: from), piece.type == .king {
            isCastling = abs(toCol - fromCol) == 2
        } else {
            isCastling = false
        }
        let isEnPassant = captured == nil && game.piece(at: from)?.type == .pawn && toCol != fromCol

        return Move(
            from: from,
            to: to,
            captured: captured,
            promotion: promotion,
            isCastling: isCastling,
            isEnPassant: isEnPassant
        )
    }

    nonisolated deinit {
        moveContinuation?.resume(throwing: ChessKitAIError.engineStopped)
        let task = streamTask
        Task { task?.cancel() }
    }
}
