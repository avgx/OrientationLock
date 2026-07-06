#if canImport(UIKit) && !os(tvOS) && !os(watchOS)
import SwiftUI
import UIKit

extension View {
    /// Declares allowed orientations while this view is visible (policy only, no rotation).
    public func allowedOrientations(_ mask: UIInterfaceOrientationMask) -> some View {
        modifier(AllowedOrientationsModifier(mask: mask))
    }

    /// Exits landscape when this view disappears, if landscape mode is active.
    public func resetsLandscapeOnDisappear() -> some View {
        onDisappear {
            if OrientationLock.shared.isLandscape {
                OrientationLock.shared.exitLandscape()
            }
        }
    }
}

private struct AllowedOrientationsModifier: ViewModifier {
    let mask: UIInterfaceOrientationMask

    func body(content: Content) -> some View {
        content
            .onAppear {
                OrientationLock.shared.allow(mask)
            }
            .onDisappear {
                guard OrientationLock.shared.allowedOrientations == mask else { return }
                if OrientationLock.shared.isLandscape {
                    OrientationLock.shared.exitLandscape()
                } else {
                    OrientationLock.shared.allow(.portrait)
                }
            }
    }
}
#endif
