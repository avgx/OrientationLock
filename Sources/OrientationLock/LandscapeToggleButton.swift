#if canImport(UIKit) && !os(tvOS) && !os(watchOS)
import SwiftUI

/// Button that toggles landscape left / portrait. Icon shows the action on next tap.
public struct LandscapeToggleButton: View {
    @ObservedObject private var lock = OrientationLock.shared

    public init() {}

    public var body: some View {
        Button(action: lock.toggleLandscape) {
            Image(systemName: lock.isLandscape ? Self.exitSymbol : Self.enterSymbol)
        }
        .accessibilityLabel(lock.isLandscape ? "Exit landscape" : "Enter landscape")
    }

    private static let enterSymbol = "arrow.up.left.and.arrow.down.right"
    private static let exitSymbol = "arrow.down.right.and.arrow.up.left"
}
#endif
