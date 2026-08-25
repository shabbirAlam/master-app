import SwiftUI

/// UIKit bridge that reuses the internal layout view of a secure text entry
/// `UITextField`, which the system excludes from screenshots and app
/// switcher previews. The SwiftUI content is embedded into that view via a
/// hosting controller.
struct SnapShotPreventingContainer<Content: View>: UIViewRepresentable {
    typealias UIViewType = UIView
    /// The hosting controller whose view is embedded into the secure container.
    @Binding var hostingController: UIHostingController<Content>?

    /// Builds the snapshot-proof container view extracted from a secure text field.
    func makeUIView(context: Context) -> UIView {
        let secureTextField = UITextField()
        secureTextField.isSecureTextEntry = true
        if let textLayoutView = secureTextField.subviews.last {
            textLayoutView.backgroundColor = .clear
        }
        if let textLayoutView = secureTextField.subviews.first {
            return textLayoutView
        }
        return UIView()
    }

    /// Embeds the hosting controller's view into the secure container once available.
    func updateUIView(_ uiView: UIView, context: Context) {
        if let hostingController, !uiView.subviews.contains(where: { $0.tag == SnapShotPreventingViewConstants.secureViewTag }) {
            uiView.addSubview(hostingController.view)
        }
    }
}
