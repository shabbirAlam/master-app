import SwiftUI

extension View {
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
