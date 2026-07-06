#if canImport(UIKit) && !os(tvOS) && !os(watchOS)
import UIKit

/// App delegate that reports ``OrientationLock/shared`` allowed orientations to UIKit.
public final class OrientationLockAppDelegate: NSObject, UIApplicationDelegate {
    public func application(
        _ application: UIApplication,
        supportedInterfaceOrientationsFor window: UIWindow?
    ) -> UIInterfaceOrientationMask {
        OrientationLock.shared.allowedOrientations
    }
}
#endif
