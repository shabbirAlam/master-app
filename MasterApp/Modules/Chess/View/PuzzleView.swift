import SwiftUI

struct PuzzleView: View {
    @State private var viewModel: PuzzleViewModel
    @State private var showOverlay = true
    private let theme: Theme

    private let boardSize: CGFloat
    private let squareSize: CGFloat

    init(viewModel: PuzzleViewModel, theme: Theme = AppTheme.light) {
        self.viewModel = viewModel
        self.theme = theme
        let screenWidth = UIScreen.main.bounds.width
        self.boardSize = screenWidth - 32
        self.squareSize = (screenWidth - 32) / 8
    }

    var body: some View {
        ZStack {
            theme.background.ignoresSafeArea()
            content
        }
        .navigationTitle("Chess Puzzles")
        .navigationBarTitleDisplayMode(.inline)
        .overlay {
            if viewModel.puzzleCompleted, showOverlay {
                successOverlay
                    .onTapGesture { showOverlay = false }
                    .onAppear { startDismissTimer() }
            }
            if viewModel.puzzleFailed, let error = viewModel.errorMessage, showOverlay {
                errorOverlay(message: error)
                    .onTapGesture { showOverlay = false }
                    .onAppear { startDismissTimer() }
            }
        }
        .animation(.easeInOut, value: viewModel.puzzleCompleted)
        .animation(.easeInOut, value: viewModel.puzzleFailed)
        .onChange(of: viewModel.puzzleCompleted) { showOverlay = true }
        .onChange(of: viewModel.puzzleFailed) { showOverlay = true }
    }

    private func startDismissTimer() {
        Task {
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            showOverlay = false
        }
    }

    @ViewBuilder
    private var content: some View {
        VStack(spacing: 8) {
            ratingBar
            boardView
            if viewModel.puzzleCompleted || viewModel.puzzleFailed {
                actionButtons
            }
            Spacer()
        }
        .padding(.horizontal, 16)
    }

    private var ratingBar: some View {
        HStack {
            Text("You: \(viewModel.userRating)")
                .font(.caption)
                .foregroundColor(theme.textPrimary.opacity(0.7))
            Spacer()
            Text("Puzzle: \(viewModel.puzzleRating)")
                .font(.caption)
                .foregroundColor(theme.textPrimary.opacity(0.7))
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 6)
    }

    private var boardRows: [Int] { [0, 1, 2, 3, 4, 5, 6, 7] }

    private var boardView: some View {
        VStack(spacing: 0) {
            ForEach(boardRows, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(0..<8, id: \.self) { col in
                        squareView(row: row, col: col)
                    }
                }
            }
        }
    }

    private func squareView(row: Int, col: Int) -> some View {
        let position = Position(row: row, col: col)
        let isLight = (row + col) % 2 == 0
        let isSelected = viewModel.selectedPosition == position
        let isLastMove = viewModel.gameState.moveHistory.last.map { $0.from == position || $0.to == position } ?? false
        let isValidMove = viewModel.showHints && viewModel.validMoves.contains(position)
        let piece = viewModel.gameState.piece(at: position)
        let isFileLabel = row == 7
        let isRankLabel = col == 0
        let isKingInCheck = viewModel.gameState.status == .check && viewModel.gameState.findKing(viewModel.gameState.currentTurn) == position

        return ZStack {
            Rectangle()
                .fill(squareColor(isLight: isLight, isSelected: isSelected, isValidMove: isValidMove, isLastMove: isLastMove, isKingInCheck: isKingInCheck))

            if isValidMove {
                if piece != nil {
                    Circle().stroke(Color.orange, lineWidth: 3).padding(3)
                } else {
                    Circle().fill(Color.gray.opacity(0.5))
                        .frame(width: squareSize * 0.25, height: squareSize * 0.25)
                }
            }

            if isRankLabel {
                Text("\(8 - row)")
                    .font(.system(size: 9))
                    .foregroundColor(theme.textPrimary.opacity(0.5))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .padding(.leading, 2)
                    .padding(.top, 1)
            }

            if isFileLabel {
                let fileChar = String(UnicodeScalar(97 + col)!)
                Text(fileChar)
                    .font(.system(size: 9))
                    .foregroundColor(theme.textPrimary.opacity(0.5))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                    .padding(.trailing, 2)
                    .padding(.bottom, 1)
            }

            if let piece {
                Image(piece.assetName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: squareSize * 0.75, height: squareSize * 0.75)
            }
        }
        .frame(width: squareSize, height: squareSize)
        .contentShape(Rectangle())
        .onTapGesture {
            viewModel.selectSquare(at: position)
        }
        .accessibilityIdentifier("puzzle_square_\(position.algebraic)")
    }

    private func squareColor(isLight: Bool, isSelected: Bool, isValidMove: Bool, isLastMove: Bool, isKingInCheck: Bool) -> Color {
        if isSelected {
            return Color.yellow.opacity(0.6)
        }
        if isKingInCheck {
            return Color.red.opacity(0.45)
        }
        if isLastMove {
            return Color.yellow.opacity(0.3)
        }
        if isValidMove {
            return isLight ? theme.accent.opacity(0.25) : theme.accent.opacity(0.35)
        }
        return isLight ? theme.boardLight : theme.boardDark
    }

    private var successOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            VStack(spacing: 20) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 64))
                    .foregroundColor(.green)
                Text("Puzzle Solved!")
                    .font(.title.bold())
                    .foregroundColor(.white)
                Text("Rating: \(viewModel.puzzleRating)")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(24)
            .background(.ultraThinMaterial)
            .cornerRadius(16)
        }
    }

    private func errorOverlay(message: String) -> some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            VStack(spacing: 20) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 64))
                    .foregroundColor(.red)
                Text(message)
                    .font(.headline)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
            .padding(24)
            .background(.ultraThinMaterial)
            .cornerRadius(16)
        }
    }

    private var actionButtons: some View {
        HStack(spacing: 16) {
            Button {
                viewModel.retry()
            } label: {
                Label("Retry", systemImage: "arrow.counterclockwise")
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .foregroundColor(.blue)
                    .background(Color.white)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.blue, lineWidth: 1.5)
                    )
            }
            .accessibilityIdentifier("puzzle_retry")
            Button {
                viewModel.nextPuzzle()
            } label: {
                Label("Next", systemImage: "forward.end")
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .accessibilityIdentifier("puzzle_next")
        }
        .foregroundColor(.white)
    }
}

#Preview {
    NavigationStack {
        PuzzleView(viewModel: PuzzleViewModel(
            puzzle: ChessPuzzle(
                id: "preview",
                title: "Scholar's Mate",
                rating: 300,
                fen: "r1bqkb1r/pppp1ppp/2n5/4p2Q/2B1P3/8/PPPP1PPP/RNB1K1NR w KQkq -",
                premove: nil,
                expectedMoves: ["h5f7"],
                responseMoves: []
            )
        ))
    }
}
