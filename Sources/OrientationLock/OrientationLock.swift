#if canImport(UIKit) && !os(tvOS) && !os(watchOS)
import Combine
import UIKit

/// Controls allowed interface orientations and forces rotation at runtime.
///
/// - ``allow(_:)`` sets policy (which orientations are permitted) without rotating.
/// - ``force(_:)`` sets policy and rotates immediately.
@MainActor
public final class OrientationLock: ObservableObject {
    public static let shared = OrientationLock()

    public private(set) var allowedOrientations: UIInterfaceOrientationMask = .portrait
    @Published public private(set) var isLandscape = false

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

    /// Allows landscape left and rotates immediately.
    public func forceLandscape() {
        enterLandscape()
    }

    // MARK: - Scenario

    /// Allows landscape left and rotates into landscape (e.g. video/camera expand).
    public func enterLandscape() {
        isLandscape = true
        allow(.landscapeLeft)
        rotate(to: .landscapeLeft)
    }

    /// Returns to portrait-only policy and rotates back to portrait.
    public func exitLandscape() {
        isLandscape = false
        allow(.portrait)
        rotate(to: .portrait)
    }

    /// Toggles between landscape left and portrait.
    public func toggleLandscape() {
        if isLandscape {
            exitLandscape()
        } else {
            enterLandscape()
        }
    }

    // MARK: - Rotation

    private func rotate(to orientation: UIInterfaceOrientation) {
        if #available(iOS 16.0, *) {
            activeRootViewController()?.setNeedsUpdateOfSupportedInterfaceOrientations()

            if let scene = activeWindowScene() {
                let preferences = UIWindowScene.GeometryPreferences.iOS(
                    interfaceOrientations: Self.mask(for: orientation)
                )
                scene.requestGeometryUpdate(preferences) { _ in }
            }

            UIViewController.attemptRotationToDeviceOrientation()
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
