import SwiftUI

import SwiftUI

extension View {
    /// Applies `containerRelativeFrame` on iOS 17+; a no-op on earlier versions.
    /// - Parameters:
    ///   - axes: The axes to lay out relative to the container.
    ///   - alignment: The alignment within the container frame.
    @ViewBuilder
    func applyContainerRelativeFrame(_ axes: Axis.Set, alignment: Alignment = .center) -> some View {
        if #available(iOS 17.0, *) {
            self.containerRelativeFrame(axes, alignment: alignment)
        } else {
            self
        }
    }
    
    /// Wraps the view in a snapshot-preventing container so its contents are
    /// hidden from the app switcher and screenshots.
    /// - Parameter ignoreSafeArea: When `true` (default), the container ignores safe-area insets.
    @ViewBuilder
    func secure(ignoreSafeArea: Bool = true) -> some View {
        if ignoreSafeArea {
            SnapShotPreventingView {
                self
            }
            .ignoresSafeArea()
        } else {
            SnapShotPreventingView {
                self
            }
        }
    }
}
