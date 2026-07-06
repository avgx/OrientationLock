import Testing
#if canImport(UIKit)
import UIKit
@testable import OrientationLock

@Test func defaultAllowedOrientationsIsPortrait() async throws {
    await MainActor.run {
        #expect(OrientationLock.shared.allowedOrientations == .portrait)
    }
}

@Test func preferredLandscapeFromPortrait() async throws {
    await MainActor.run {
        let result = OrientationLock.preferredLandscape(current: .portrait)
        #expect(result == .landscapeLeft)
    }
}

@Test func preferredLandscapeTogglesLeftAndRight() async throws {
    await MainActor.run {
        #expect(OrientationLock.preferredLandscape(current: .landscapeLeft) == .landscapeRight)
        #expect(OrientationLock.preferredLandscape(current: .landscapeRight) == .landscapeLeft)
    }
}

@Test func maskForOrientation() async throws {
    await MainActor.run {
        #expect(OrientationLock.mask(for: .portrait) == .portrait)
        #expect(OrientationLock.mask(for: .landscapeLeft) == .landscapeLeft)
        #expect(OrientationLock.mask(for: .landscapeRight) == .landscapeRight)
        #expect(OrientationLock.mask(for: .portraitUpsideDown) == .portraitUpsideDown)
    }
}
#endif
