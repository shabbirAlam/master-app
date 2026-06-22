import SwiftUI

struct PuzzleView: View {
    @State private var viewModel: PuzzleViewModel
    @State private var showPuzzleList = false
    @Environment(\.dismiss) private var dismiss
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
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                }
                .accessibilityIdentifier("puzzle_close")
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showPuzzleList = true
                } label: {
                    Image(systemName: "list.bullet")
                }
                .accessibilityIdentifier("puzzle_list_button")
            }
        }
        .sheet(isPresented: $showPuzzleList) {
            puzzleListView
        }
        .overlay {
            if viewModel.puzzleCompleted {
                successOverlay
            }
            if viewModel.puzzleFailed, let error = viewModel.errorMessage {
                errorOverlay(message: error)
            }
        }
        .animation(.easeInOut, value: viewModel.puzzleCompleted)
        .animation(.easeInOut, value: viewModel.puzzleFailed)
    }

    @ViewBuilder
    private var content: some View {
        VStack(spacing: 8) {
            ratingBar
            progressBar
            boardView
            Spacer()
        }
        .padding(.horizontal, 16)
    }

    private var ratingBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("You: \(viewModel.userRating)")
                    .font(.caption)
                    .foregroundColor(theme.textPrimary.opacity(0.7))
                Text("Puzzle: \(viewModel.puzzleRating)")
                    .font(.caption)
                    .foregroundColor(theme.textPrimary.opacity(0.7))
            }
            Spacer()
            Text(viewModel.currentPuzzle.title)
                .font(.caption.bold())
                .foregroundColor(theme.textPrimary)
            Spacer()
            Text("\(viewModel.currentStep + 1)/\(viewModel.totalSteps)")
                .font(.caption.monospacedDigit())
                .foregroundColor(theme.textPrimary.opacity(0.7))
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 6)
    }

    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 8)
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.blue)
                    .frame(width: geo.size.width * CGFloat(viewModel.currentStep) / CGFloat(max(viewModel.totalSteps, 1)), height: 8)
            }
        }
        .frame(height: 8)
        .padding(.horizontal, 4)
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
        let piece = viewModel.gameState.piece(at: position)
        let isFileLabel = row == 7
        let isRankLabel = col == 0

        return ZStack {
            Rectangle()
                .fill(squareColor(isLight: isLight, isSelected: isSelected))

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
                Text(piece.symbol)
                    .font(.system(size: squareSize * 0.7))
            }
        }
        .frame(width: squareSize, height: squareSize)
        .contentShape(Rectangle())
        .onTapGesture {
            viewModel.selectSquare(at: position)
        }
        .accessibilityIdentifier("puzzle_square_\(position.algebraic)")
    }

    private func squareColor(isLight: Bool, isSelected: Bool) -> Color {
        if isSelected {
            return Color.yellow.opacity(0.6)
        }
        return isLight ? Color(white: 0.9) : Color(white: 0.6)
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
                HStack(spacing: 16) {
                    Button {
                        viewModel.retry()
                    } label: {
                        Label("Retry", systemImage: "arrow.counterclockwise")
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(10)
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
                HStack(spacing: 16) {
                    Button {
                        viewModel.retry()
                    } label: {
                        Label("Retry", systemImage: "arrow.counterclockwise")
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(10)
                    }
                    .accessibilityIdentifier("puzzle_retry_error")
                    Button {
                        viewModel.nextPuzzle()
                    } label: {
                        Label("Next Puzzle", systemImage: "forward.end")
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .accessibilityIdentifier("puzzle_next_error")
                }
                .foregroundColor(.white)
            }
            .padding(24)
            .background(.ultraThinMaterial)
            .cornerRadius(16)
        }
    }

    private var puzzleListView: some View {
        NavigationStack {
            List(viewModel.availablePuzzles) { puzzle in
                Button {
                    viewModel.selectPuzzle(puzzle)
                    showPuzzleList = false
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(puzzle.title)
                                .font(.headline)
                                .foregroundColor(.primary)
                            Text("Rating: \(puzzle.rating) | Moves: \(puzzle.totalSteps)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        if puzzle.id == viewModel.currentPuzzle.id {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .accessibilityIdentifier("puzzle_list_item_\(puzzle.id)")
            }
            .navigationTitle("Select Puzzle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        showPuzzleList = false
                    }
                }
            }
        }
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
                expectedMoves: ["h5f7"],
                responseMoves: []
            )
        ))
    }
}
