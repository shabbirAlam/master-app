import SwiftUI

struct SecureView: View {
    @State private var viewModel: SecureViewModel

    init(viewModel: SecureViewModel = SecureViewModel()) {
        self.viewModel = viewModel
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
