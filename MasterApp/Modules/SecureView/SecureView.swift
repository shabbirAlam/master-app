import SwiftUI

struct SecureView: View {
    var body: some View {
        Text("This is secure view")
            .secure()
    }
}

#Preview {
    SecureView()
}
