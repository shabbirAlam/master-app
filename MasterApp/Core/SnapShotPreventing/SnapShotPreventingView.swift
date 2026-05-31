import SwiftUI

struct SnapShotPreventingView<Content: View>: View {
    var content: Content
    let pub = NotificationCenter.default
        .publisher(for: UIApplication.userDidTakeScreenshotNotification)

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content()
    }

    @State private var hostingController: UIHostingController<Content>?

    var body: some View {
        _SnapShotPreventingView(hostingController: $hostingController)
            .overlay {
                GeometryReader {
                    let size = $0.size
                    Color.clear.preference(key: SizeKey.self, value: size)
                        .onPreferenceChange(SizeKey.self, perform: { value in
                            if value != .zero {
                                if hostingController == nil {
                                    hostingController = UIHostingController(rootView: content)
                                    hostingController?.view.backgroundColor = .clear
                                    hostingController?.view.tag = SnapShotPreventingViewConstants.secureViewTag
                                    hostingController?.view.frame = .init(origin: .zero, size: value)
                                } else {
                                    hostingController?.view.frame = .init(origin: .zero, size: value)
                                }
                            }
                        })
                }

            }
            .onReceive(pub) { _ in
                print("Admin policy doesn't allow to take screenshot")
            }

    }
}

enum SnapShotPreventingViewConstants {
    static let secureViewTag: Int = 1009
}
