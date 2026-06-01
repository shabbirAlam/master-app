import SwiftUI

struct SecureView: View {
    @StateObject private var viewModel: SecureViewModel

    init(viewModel: SecureViewModel = SecureViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        Text(viewModel.content.message)
            .secure()
            .accessibilityIdentifier("secure_text")
            .accessibilityLabel(viewModel.content.message)
    }
}

#Preview {
    SecureView()
}
