import Foundation
import ChessKitEngine

/// Errors produced by the Stockfish-backed chess AI service.
enum ChessKitAIError: Error, LocalizedError {
    /// The engine is not initialized yet.
    case engineNotReady
    /// The engine failed to return a legal best move.
    case bestMoveNotFound
    /// A move returned by the engine could not be interpreted.
    case invalidMove(String)
    /// The engine was stopped while a request was in progress.
    case engineStopped
    /// The NNUE data download for the engine failed.
    case nnueDownloadFailed(String)

    /// Human-readable error message for app-level logging and UI feedback.
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

/// Contract for requesting chess engine moves during gameplay.
protocol ChessKitAIService: Sendable {
    /// Requests the best move for the given player color in the provided position.
    /// - Parameters:
    ///   - game: The current game state.
    ///   - color: The side for which to compute a move.
    ///   - moveTime: The maximum move-search time in milliseconds.
    /// - Returns: The chosen move, if a valid move is available.
    func selectMove(from game: GameState, for color: PieceColor, moveTime milliseconds: Int) async throws -> Move?
    /// Starts the underlying engine and prepares it for move generation.
    func start() async
    /// Stops the engine and releases any pending move continuation.
    func stop() async
}

/// Stockfish-backed AI engine wrapper used to generate moves for the chess game.
actor ChessKitAIServiceImpl: ChessKitAIService {
    private let engine: Engine
    private var streamTask: Task<Void, Never>?
    private var moveContinuation: CheckedContinuation<String, Error>?
    private var isReady = false

    nonisolated private static let nnueMain = "nn-1111cefa1111"
    nonisolated private static let nnueSmall = "nn-37f18f62d772"

    /// Creates a new engine-backed AI service.
    init() {
        self.engine = Engine(type: .stockfish, loggingEnabled: false)
    }

    /// Starts the engine and ensures required NNUE files are available.
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

    /// Stops the engine and cancels any pending move request.
    func stop() async {
        streamTask?.cancel()
        streamTask = nil
        moveContinuation?.resume(throwing: ChessKitAIError.engineStopped)
        moveContinuation = nil
        await engine.stop()
        isReady = false
    }

    /// Requests the engine to choose the best legal move for the current board.
    /// - Parameters:
    ///   - game: The board state to evaluate.
    ///   - color: The side to move.
    ///   - moveTime: Search time in milliseconds.
    /// - Returns: The parsed move when the engine provides one.
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

    /// Cancels an in-flight engine request.
    private func cancelMove() async {
        moveContinuation?.resume(throwing: CancellationError())
        moveContinuation = nil
    }

    /// Handles a best-move response returned by the engine stream.
    /// - Parameter response: The engine response object.
    private func handleResponse(_ response: EngineResponse) {
        if case .bestmove(let move, _) = response {
            moveContinuation?.resume(returning: move)
            moveContinuation = nil
        }
    }

    /// Ensures the local NNUE files used for evaluation are available.
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

    /// Downloads a required NNUE evaluation file from the Stockfish asset source.
    /// - Parameters:
    ///   - name: The NNUE file name.
    ///   - destination: Local file URL used for storage.
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

    /// Updates the engine with the local evaluation file paths.
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

    /// Interprets a UCI move string into the app's `Move` representation.
    /// - Parameters:
    ///   - uci: The engine-provided move as UCI notation.
    ///   - game: The active board state for context.
    ///   - color: The side to move.
    /// - Returns: The mapped move model, or `nil` when the move is invalid.
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
