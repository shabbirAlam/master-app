import SwiftUI

struct ChessView: View {
    @State private var viewModel: ChessViewModel
    private let theme: Theme

    private let boardSize: CGFloat
    private let squareSize: CGFloat

    init(viewModel: ChessViewModel, theme: Theme = AppTheme.light) {
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
        .navigationTitle("Chess")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.gameMode == nil {
            modeSelectionView
        } else {
            gameView
        }
    }

    private var modeSelectionView: some View {
        VStack(spacing: 24) {
            Text("♚ Chess ♔")
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(theme.textPrimary)

            Text("Choose a game mode")
                .font(.title3)
                .foregroundColor(theme.textPrimary.opacity(0.7))

            ratingSetupView

            VStack(spacing: 16) {
                Button {
                    viewModel.setGameMode(.vsComputer)
                } label: {
                    HStack {
                        Image(systemName: "cpu")
                            .font(.title2)
                        Text("vs Computer")
                            .font(.title3)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue.opacity(0.15))
                    .cornerRadius(12)
                }
                .accessibilityIdentifier("chess_vs_computer")

                Button {
                    viewModel.setGameMode(.twoPlayer)
                } label: {
                    HStack {
                        Image(systemName: "person.2")
                            .font(.title2)
                        Text("2 Players")
                            .font(.title3)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green.opacity(0.15))
                    .cornerRadius(12)
                }
                .accessibilityIdentifier("chess_two_player")
            }
            .padding(.horizontal, 40)
        }
    }

    private var ratingSetupView: some View {
        VStack(spacing: 12) {
            Text("Your Elo: \(viewModel.userRating)")
                .font(.headline)
                .foregroundColor(theme.textPrimary)
                .accessibilityIdentifier("chess_user_rating")

            VStack(spacing: 8) {
                Text("Computer Elo: \(viewModel.computerRating)")
                    .font(.subheadline)
                    .foregroundColor(theme.textPrimary.opacity(0.8))

                Stepper(
                    value: Binding(
                        get: { viewModel.computerRating },
                        set: { viewModel.updateComputerRating($0) }
                    ),
                    in: ChessRatingProfile.minimumRating...ChessRatingProfile.maximumRating,
                    step: ChessRatingProfile.ratingStep
                ) {
                    EmptyView()
                }
                .labelsHidden()
                .accessibilityIdentifier("chess_computer_rating_stepper")
            }
        }
        .padding(.horizontal, 40)
    }

    private var gameView: some View {
        VStack(spacing: 8) {
            topBar
            statusBar
            capturedRow(.white)
            boardView
            capturedRow(.black)
            moveHistoryRow
            userTimeRow
            Spacer()
        }
        .padding(.horizontal, 16)
    }

    private var topBar: some View {
        HStack {
            Button("Menu") {
                viewModel.backToMenu()
            }
            .accessibilityIdentifier("chess_back_menu")
            Spacer()
            Button("New Game") {
                viewModel.resetGame()
            }
            .accessibilityIdentifier("chess_new_game")
        }
        .padding(.vertical, 4)
    }

    private var statusBar: some View {
        VStack(spacing: 6) {
            if viewModel.gameMode == .vsComputer {
                HStack(spacing: 16) {
                    Text("You: \(viewModel.userRating)")
                    HStack(spacing: 4) {
                        Text("PC: \(viewModel.computerRating)")
                        if let time = viewModel.computerLastMoveTimeString {
                            Text("(\(time))")
                                .monospacedDigit()
                        }
                    }
                }
                .font(.caption)
                .foregroundColor(theme.textPrimary.opacity(0.7))
            }

            HStack {
                Circle()
                    .fill(viewModel.game.currentTurn == .white ? Color.white : Color.black)
                    .frame(width: 12, height: 12)
                    .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                Text(viewModel.statusMessage)
                    .font(.headline)
                    .foregroundColor(theme.textPrimary)
            }
        }
        .padding(.vertical, 4)
        .accessibilityLabel(viewModel.statusMessage)
        .accessibilityIdentifier("chess_status")
    }

    private func capturedRow(_ color: PieceColor) -> some View {
        let pieces = viewModel.game.capturedPieces[color] ?? []
        return HStack {
            Text(color == .white ? "White captured:" : "Black captured:")
                .font(.caption)
                .foregroundColor(theme.textPrimary.opacity(0.6))
            ForEach(Array(pieces.enumerated()), id: \.offset) { _, piece in
                Text(piece.symbol)
                    .font(.caption)
            }
            Spacer()
        }
        .frame(height: 20)
        .padding(.horizontal, 4)
    }

    private var boardView: some View {
        VStack(spacing: 0) {
            ForEach(0..<8, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(0..<8, id: \.self) { col in
                        squareView(row: row, col: col)
                    }
                }
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color.gray.opacity(0.5), lineWidth: 2)
        )
        .sheet(isPresented: $viewModel.showPromotionDialog) {
            promotionSheet
        }
    }

    private func squareView(row: Int, col: Int) -> some View {
        let position = Position(row: row, col: col)
        let isLight = (row + col) % 2 == 0
        let isSelected = viewModel.selectedPosition == position
        let isValidMove = viewModel.validMoves.contains(position)
        let isLastMove = viewModel.game.moveHistory.last.map { $0.to == position || $0.from == position } ?? false
        let piece = viewModel.game.piece(at: position)

        return ZStack {
            Rectangle()
                .fill(squareColor(isLight: isLight, isSelected: isSelected, isValidMove: isValidMove, isLastMove: isLastMove))

            if isValidMove {
                if piece != nil {
                    Circle()
                        .stroke(Color.orange, lineWidth: 3)
                        .padding(3)
                } else {
                    Circle()
                        .fill(Color.gray.opacity(0.5))
                        .frame(width: squareSize * 0.25, height: squareSize * 0.25)
                }
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
        .accessibilityIdentifier("chess_square_\(position.algebraic)")
        .accessibilityLabel(accessibilityLabel(for: piece, at: position, isSelected: isSelected, isValidMove: isValidMove))
    }

    private func squareColor(isLight: Bool, isSelected: Bool, isValidMove: Bool, isLastMove: Bool) -> Color {
        if isSelected {
            return Color.yellow.opacity(0.6)
        }
        if isLastMove {
            return Color.yellow.opacity(0.3)
        }
        if isValidMove {
            return isLight ? Color.green.opacity(0.3) : Color.green.opacity(0.4)
        }
        return isLight ? Color(white: 0.9) : Color(white: 0.6)
    }

    private func accessibilityLabel(for piece: ChessPiece?, at position: Position, isSelected: Bool, isValidMove: Bool) -> String {
        var label = "\(position.algebraic)"
        if let piece {
            label = "\(piece.color.rawValue) \(piece.type.rawValue) on \(position.algebraic)"
        }
        if isSelected {
            label += ", selected"
        }
        if isValidMove {
            label += ", valid move"
        }
        return label
    }

    private var moveHistoryRow: some View {
        ScrollView(.horizontal, showsIndicators: true) {
            HStack(spacing: 4) {
                ForEach(Array(viewModel.game.moveHistory.enumerated()), id: \.offset) { index, move in
                    Text(move.notation)
                        .font(.caption2)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.gray.opacity(0.15))
                        )
                }
            }
            .padding(.vertical, 4)
        }
        .frame(height: 30)
    }

    private var userTimeRow: some View {
        HStack {
            if viewModel.gameMode == .vsComputer {
                Text("Your last move: ")
                    .font(.caption)
                    .foregroundColor(theme.textPrimary.opacity(0.6))
                if let time = viewModel.userLastMoveTimeString {
                    Text(time)
                        .font(.caption)
                        .foregroundColor(theme.textPrimary)
                        .monospacedDigit()
                } else {
                    Text("--")
                        .font(.caption)
                        .foregroundColor(theme.textPrimary.opacity(0.4))
                }
            }
            Spacer()
        }
        .padding(.horizontal, 4)
    }

    @ViewBuilder
    private var promotionSheet: some View {
        VStack(spacing: 20) {
            Text("Choose Promotion")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top)

            Text("Select a piece for promotion:")
                .foregroundColor(.secondary)

            HStack(spacing: 24) {
                ForEach([PieceType.queen, .rook, .bishop, .knight], id: \.self) { type in
                    Button {
                        viewModel.selectPromotion(type)
                    } label: {
                        VStack {
                            Text(ChessPiece(type: type, color: viewModel.game.currentTurn == .white ? .white : .black).symbol)
                                .font(.system(size: 44))
                            Text(type.rawValue.capitalized)
                                .font(.caption)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
            }
            .padding()
        }
        .presentationDetents([.height(200)])
        .accessibilityIdentifier("chess_promotion_sheet")
    }
}

#Preview("Two Player") {
    let vm = ChessViewModel()
    vm.setGameModeForSnapshot(.twoPlayer)
    return ChessView(viewModel: vm)
}

#Preview("Mode Selection") {
    ChessView(viewModel: ChessViewModel())
}
