import SwiftUI

struct ChessView: View {
    @State private var viewModel: ChessViewModel
    @State private var pendingAction: ChessMenuAction?
    @State private var selectedColor: PieceColor = .white
    @State private var isAutoAnimating = false
    @State private var autoDisplayColor: PieceColor = .white
    @State private var showPuzzles = false
    @State private var puzzleViewModel: PuzzleViewModel?
    private let theme: Theme
    private let puzzleRepository: PuzzleRepository

    private enum ChessMenuAction: Identifiable {
        case restart, close
        var id: Self { self }

        var title: String {
            switch self {
            case .restart: "Restart Game"
            case .close: "Close Game"
            }
        }

        var message: String {
            switch self {
            case .restart: "Are you sure you want to restart? Current progress will be lost."
            case .close: "Are you sure you want to close? Current progress will be lost."
            }
        }
    }

    private let boardSize: CGFloat
    private let squareSize: CGFloat

    init(viewModel: ChessViewModel, puzzleRepository: PuzzleRepository = SQLitePuzzleRepository(), theme: Theme = AppTheme.light) {
        self.viewModel = viewModel
        self.puzzleRepository = puzzleRepository
        self.theme = theme
        let screenWidth = UIScreen.main.bounds.width
        self.boardSize = screenWidth - 32
        self.squareSize = (screenWidth - 32) / 8
    }

    private var needsConfirmation: Bool {
        !viewModel.game.moveHistory.isEmpty && !viewModel.game.status.isGameOver
    }

    var body: some View {
        ZStack {
            theme.background.ignoresSafeArea()
            content
        }
        .navigationTitle("Chess")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(viewModel.gameMode != nil)
        .toolbar {
            if viewModel.gameMode != nil {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button("Restart") {
                            if needsConfirmation {
                                pendingAction = .restart
                            } else {
                                viewModel.restartGame()
                            }
                        }
                        Button("Close") {
                            if needsConfirmation {
                                pendingAction = .close
                            } else {
                                viewModel.backToMenu()
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                    .accessibilityIdentifier("chess_menu_button")
                }
            }
        }
        .alert(
            pendingAction?.title ?? "",
            isPresented: .init(
                get: { pendingAction != nil },
                set: { if !$0 { pendingAction = nil } }
            ),
            presenting: pendingAction
        ) { action in
            Button("Cancel", role: .cancel) {
                pendingAction = nil
            }
            Button("OK") {
                switch action {
                case .restart: viewModel.restartGame()
                case .close: viewModel.backToMenu()
                }
                pendingAction = nil
            }
        } message: { action in
            Text(action.message)
        }
        .navigationDestination(isPresented: $showPuzzles) {
            if let vm = puzzleViewModel {
                PuzzleView(viewModel: vm)
            }
        }
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

            VStack(spacing: 12) {
                Text("Your Color")
                    .font(.headline)
                    .foregroundColor(theme.textPrimary)

                HStack(spacing: 12) {
                    colorButton(.white, label: "White", icon: "crown.fill")
                    colorButton(.black, label: "Black", icon: "crown.fill")
                    Button {
                        startAutoAnimation()
                    } label: {
                        VStack(spacing: 3) {
                            Image(systemName: "bolt.fill")
                                .font(.system(size: 18, weight: .medium))
                            Text(isAutoAnimating ? "..." : "Auto")
                                .font(.system(size: 10))
                                .fontWeight(.medium)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 9)
                        .background(isAutoAnimating ? Color.orange.opacity(0.25) : Color.purple.opacity(0.15))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(isAutoAnimating ? Color.orange : Color.purple, lineWidth: 2)
                        )
                    }
                    .disabled(isAutoAnimating)
                    .accessibilityIdentifier("chess_color_auto")
                }
            }
            .padding(.horizontal, 40)

            Toggle(isOn: $viewModel.undoEnabled) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.uturn.backward")
                        .font(.caption)
                    Text("Undo")
                        .font(.caption)
                }
            }
            .toggleStyle(.switch)
            .padding(.horizontal, 40)

            Toggle(isOn: $viewModel.showHints) {
                HStack(spacing: 8) {
                    Image(systemName: "lightbulb")
                        .font(.caption)
                    Text("Hints")
                        .font(.caption)
                }
            }
            .toggleStyle(.switch)
            .padding(.horizontal, 40)

            VStack(spacing: 16) {
                Button {
                    viewModel.setGameMode(.vsComputer, with: selectedColor)
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
                    viewModel.setGameMode(.twoPlayer, with: selectedColor)
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

                Button {
                    let vm = PuzzleViewModel(repository: puzzleRepository, ratingService: viewModel.ratingService, userRating: viewModel.userRating)
                    vm.showHints = viewModel.showHints
                    puzzleViewModel = vm
                    showPuzzles = true
                } label: {
                    HStack {
                        Image(systemName: "puzzlepiece.extension.fill")
                            .font(.title2)
                        Text("Puzzles")
                            .font(.title3)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange.opacity(0.15))
                    .cornerRadius(12)
                }
                .accessibilityIdentifier("chess_puzzles")
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
            statusBar
            if viewModel.userColor == .black {
                capturedRow(.black)
                boardView
                capturedRow(.white)
            } else {
                capturedRow(.white)
                boardView
                capturedRow(.black)
            }
            moveHistoryRow
            userTimeRow
            HStack {
                Spacer()
                if viewModel.undoEnabled && !viewModel.game.undoStack.isEmpty {
                    Button {
                        viewModel.undoLastMove()
                    } label: {
                        Image(systemName: "arrow.uturn.backward")
                            .font(.system(size: 16))
                            .padding(10)
                            .background(Color.gray.opacity(0.15))
                            .clipShape(Circle())
                    }
                    .accessibilityIdentifier("chess_undo_button")
                }
            }
            .padding(.horizontal, 4)
            Spacer()
        }
        .padding(.horizontal, 16)
    }

    private var statusBar: some View {
        VStack(spacing: 6) {
            if case .vsComputer = viewModel.gameMode {
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

    private var boardRows: [Int] {
        viewModel.userColor == .black ? [7, 6, 5, 4, 3, 2, 1, 0] : [0, 1, 2, 3, 4, 5, 6, 7]
    }

    private var columnsReversed: Bool {
        viewModel.userColor == .black
    }

    private var boardView: some View {
        VStack(spacing: 0) {
            ForEach(boardRows, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(0..<8, id: \.self) { i in
                        let col = columnsReversed ? 7 - i : i
                        squareView(row: row, col: col)
                    }
                }
            }
        }
        .sheet(isPresented: $viewModel.showPromotionDialog) {
            promotionSheet
        }
    }

    private func squareView(row: Int, col: Int) -> some View {
        let position = Position(row: row, col: col)
        let isLight = (row + col) % 2 == 0
        let isSelected = viewModel.selectedPosition == position
        let isValidMove = viewModel.showHints && viewModel.validMoves.contains(position)
        let isLastMove = viewModel.game.moveHistory.last.map { $0.to == position || $0.from == position } ?? false
        let piece = viewModel.game.piece(at: position)
        let bottomRow = boardRows.last
        let isFileLabel = row == bottomRow
        let isRankLabel = columnsReversed ? col == 7 : col == 0

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

    private func colorButton(_ color: PieceColor, label: String, icon: String) -> some View {
        let isSelected = isAutoAnimating ? autoDisplayColor == color : selectedColor == color
        return Button {
            selectedColor = color
        } label: {
            VStack(spacing: 3) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(color == .white ? .white : .black)
                Text(label)
                    .font(.system(size: 10))
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 9)
            .background(Color.purple.opacity(0.15))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.accentColor, lineWidth: isSelected ? 2 : 0)
            )
        }
        .disabled(isAutoAnimating)
        .accessibilityIdentifier("chess_color_\(label.lowercased())")
    }

    private func startAutoAnimation() {
        isAutoAnimating = true
        autoDisplayColor = .white

        let finalColor: PieceColor = Bool.random() ? .white : .black
        let totalSteps = 10
        var currentStep = 0

        Timer.scheduledTimer(withTimeInterval: 0.10, repeats: true) { timer in
            currentStep += 1
            autoDisplayColor = autoDisplayColor == .white ? .black : .white

            if currentStep >= totalSteps {
                timer.invalidate()
                withAnimation(.easeInOut(duration: 0.2)) {
                    autoDisplayColor = finalColor
                    selectedColor = finalColor
                    isAutoAnimating = false
                }
            }
        }
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
            if case .vsComputer = viewModel.gameMode {
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
