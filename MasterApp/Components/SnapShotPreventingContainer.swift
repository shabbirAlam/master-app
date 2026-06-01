import SwiftUI

struct SnapShotPreventingContainer<Content: View>: UIViewRepresentable {
    typealias UIViewType = UIView
    @Binding var hostingController: UIHostingController<Content>?

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

    func updateUIView(_ uiView: UIView, context: Context) {
        if let hostingController, !uiView.subviews.contains(where: { $0.tag == SnapShotPreventingViewConstants.secureViewTag }) {
            uiView.addSubview(hostingController.view)
        }
    }
}
