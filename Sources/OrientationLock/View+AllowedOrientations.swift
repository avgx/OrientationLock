#if canImport(UIKit) && !os(tvOS) && !os(watchOS)
import SwiftUI
import UIKit

extension View {
    /// Declares allowed orientations while this view is visible (policy only, no rotation).
    public func allowedOrientations(_ mask: UIInterfaceOrientationMask) -> some View {
        modifier(AllowedOrientationsModifier(mask: mask))
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
                if OrientationLock.shared.allowedOrientations == mask {
                    OrientationLock.shared.allow(.portrait)
                }
            }
    }
}
#endif
