#if canImport(UIKit) && !os(tvOS) && !os(watchOS)
import UIKit

/// Controls allowed interface orientations and forces rotation at runtime.
///
/// - ``allow(_:)`` sets policy (which orientations are permitted) without rotating.
/// - ``force(_:)`` sets policy and rotates immediately.
@MainActor
public final class OrientationLock {
    public static let shared = OrientationLock()

    public private(set) var allowedOrientations: UIInterfaceOrientationMask = .portrait

    private init() {}

    // MARK: - Policy

    /// Updates allowed orientations without rotating the interface.
    public func allow(_ mask: UIInterfaceOrientationMask) {
        allowedOrientations = mask
        if #available(iOS 16.0, *) {
            activeRootViewController()?.setNeedsUpdateOfSupportedInterfaceOrientations()
        }
    }

    // MARK: - Action

    /// Updates allowed orientations and rotates to the given orientation immediately.
    public func force(_ orientation: UIInterfaceOrientation) {
        allow(Self.mask(for: orientation))
        rotate(to: orientation)
    }

    /// Forces rotation to a landscape orientation.
    public func forceLandscape() {
        force(Self.preferredLandscape(current: currentInterfaceOrientation))
    }

    // MARK: - Scenario

    /// Allows landscape and rotates into fullscreen landscape (e.g. video/camera expand).
    public func enterFullscreen() {
        allow(.landscapeLeft)
        force(Self.preferredLandscape(current: currentInterfaceOrientation))
    }

    /// Returns to portrait-only policy and rotates back to portrait.
    public func exitFullscreen() {
        allow(.portrait)
        force(.portrait)
    }

    // MARK: - Rotation

    private func rotate(to orientation: UIInterfaceOrientation) {
        if #available(iOS 16.0, *) {
            activeRootViewController()?.setNeedsUpdateOfSupportedInterfaceOrientations()
            
            if let scene = activeWindowScene() {
                let preferences = UIWindowScene.GeometryPreferences.iOS(
                    interfaceOrientations: Self.mask(for: orientation)
                )
                scene.requestGeometryUpdate(preferences) { [weak self] _ in
                    Task { @MainActor in
                        self?.legacyForce(orientation)
                    }
                }
            }
        } else {
            UIViewController.attemptRotationToDeviceOrientation()
            legacyForce(orientation)
        }
    }

    private func legacyForce(_ orientation: UIInterfaceOrientation) {
        UIDevice.current.setValue(orientation.rawValue, forKey: "orientation")
        UIViewController.attemptRotationToDeviceOrientation()
    }

    // MARK: - Scene helpers

    private func activeWindowScene() -> UIWindowScene? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive }
    }

    private func activeRootViewController() -> UIViewController? {
        activeWindowScene()?.windows.first?.rootViewController
    }

    public var currentInterfaceOrientation: UIInterfaceOrientation {
        activeWindowScene()?.interfaceOrientation ?? .portrait
    }
    
    // MARK: - Testable helpers

    internal nonisolated static func preferredLandscape(
        current: UIInterfaceOrientation
    ) -> UIInterfaceOrientation {
        switch current {
        case .landscapeLeft: .landscapeRight
        case .landscapeRight: .landscapeLeft
        default: .landscapeLeft
        }
    }

    internal nonisolated static func mask(for orientation: UIInterfaceOrientation) -> UIInterfaceOrientationMask {
        switch orientation {
        case .portrait: .portrait
        case .portraitUpsideDown: .portraitUpsideDown
        case .landscapeLeft: .landscapeLeft
        case .landscapeRight: .landscapeRight
        default: .portrait
        }
    }
}
#endif
