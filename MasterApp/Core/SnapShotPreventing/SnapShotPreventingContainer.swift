import SwiftUI

struct _SnapShotPreventingView<Content: View>: UIViewRepresentable {
    typealias UIViewType = UIView
    @Binding var hostingController: UIHostingController<Content>?

    func makeUIView(context: Context) -> UIView {
        let secureTxtField = UITextField()
        secureTxtField.isSecureTextEntry = true
        if let textLayoutView = secureTxtField.subviews.last {
            textLayoutView.backgroundColor = .clear
        }
        if let textLayoutView = secureTxtField.subviews.first {
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
