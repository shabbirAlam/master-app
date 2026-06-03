import SwiftUI

struct SnapShotPreventingView<Content: View>: View {
    var content: Content
    let screenshotPublisher = NotificationCenter.default
        .publisher(for: UIApplication.userDidTakeScreenshotNotification)

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content()
    }

    @State private var hostingController: UIHostingController<Content>?

    var body: some View {
        SnapShotPreventingContainer(hostingController: $hostingController)
            .overlay {
                GeometryReader { proxy in
                    let size = proxy.size
                    Color.clear
                        .preference(key: SizeKey.self, value: size)
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
            .onReceive(screenshotPublisher) { _ in
                AppLogger.log("Screenshot attempt detected", level: .notice)
            }
    }
}

enum SnapShotPreventingViewConstants {
    static let secureViewTag: Int = 1009
}
