import SwiftUI

extension View {
    @ViewBuilder
    func applyContainerRelativeFrame(_ axes: Axis.Set, alignment: Alignment = .center) -> some View {
        if #available(iOS 17.0, *) {
            self.containerRelativeFrame(axes, alignment: alignment)
        } else {
            self
        }
    }
    
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
