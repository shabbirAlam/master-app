import SwiftUI

/// SwiftUI wrapper that renders its content inside a snapshot-proof container
/// (see `SnapShotPreventingContainer`) and logs screenshot attempts.
struct SnapShotPreventingView<Content: View>: View {
    /// The protected content.
    var content: Content
    /// Publisher for system-wide screenshot notifications.
    let screenshotPublisher = NotificationCenter.default
        .publisher(for: UIApplication.userDidTakeScreenshotNotification)

    /// Creates the view with content built by the given builder.
    /// - Parameter content: A builder producing the protected content.
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content()
    }

    /// Hosting controller that owns the embedded content view.
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
                AppLogger.secure.log("Screenshot attempt detected", .notice)
            }
    }
}

/// Shared constants for the snapshot-preventing components.
enum SnapShotPreventingViewConstants {
    /// Tag applied to the embedded hosting view so it can be identified in the view hierarchy.
    static let secureViewTag: Int = 1009
}
