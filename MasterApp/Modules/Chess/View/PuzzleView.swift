import SwiftUI

/// Puzzle-focused chess screen that renders the board, tracks moves, and presents
/// success or failure overlays for the current challenge.
struct PuzzleView: View {
    /// The observable state for the active puzzle.
    @State private var viewModel: PuzzleViewModel
    /// Whether the result overlay is currently visible.
    @State private var showOverlay = true
    /// The active design-system theme.
    private let theme: Theme

    /// The full board size for the puzzle view.
    private let boardSize: CGFloat
    /// Size of each individual chess square.
    private let squareSize: CGFloat

    /// Creates the puzzle screen for the provided puzzle view model.
    /// - Parameters:
    ///   - viewModel: The puzzle state and orchestration object.
    ///   - theme: The theme used for styling the layout.
    init(viewModel: PuzzleViewModel, theme: Theme = AppTheme.light) {
        self.viewModel = viewModel
        self.theme = theme
        let screenWidth = UIScreen.main.bounds.width
        self.boardSize = screenWidth - 32
        self.squareSize = (screenWidth - 32) / 8
    }

    /// Renders the puzzle view, including the board and result overlay states.
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

    /// Hides the success/failure overlay after a short period of time.
    private func startDismissTimer() {
        Task {
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            showOverlay = false
        }
    }

    /// Layout for the puzzle board and action controls.
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

    /// Displays the user's current rating versus the puzzle's difficulty rating.
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

    /// Order of rows rendered for the board.
    private var boardRows: [Int] { [0, 1, 2, 3, 4, 5, 6, 7] }

    /// Full 8x8 chessboard for puzzle play.
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

    /// Renders a single square on the chess board.
    /// - Parameters:
    ///   - row: The row index for the square.
    ///   - col: The column index for the square.
    /// - Returns: The board square view.
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

    /// Chooses the square color based on selection and puzzle state.
    /// - Parameters:
    ///   - isLight: Whether the square is a light square.
    ///   - isSelected: Whether the square is currently selected.
    ///   - isValidMove: Whether the square is a valid destination for a selected move.
    ///   - isLastMove: Whether the square was part of the last move.
    ///   - isKingInCheck: Whether the king is currently in check on this square.
    /// - Returns: The chosen fill color.
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

    /// Success modal shown when the player completes the puzzle.
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
            }
            .padding(24)
            .background(.ultraThinMaterial)
            .cornerRadius(16)
        }
    }

    /// Failure modal shown when the player makes an invalid move or misses the expected sequence.
    /// - Parameter message: The failure message to display.
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

    /// Buttons presented after puzzle resolution to retry or advance to the next puzzle.
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
