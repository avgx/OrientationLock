import Testing
#if canImport(UIKit)
import UIKit
@testable import OrientationLock

@Test func defaultAllowedOrientationsIsPortrait() async throws {
    await MainActor.run {
        #expect(OrientationLock.shared.allowedOrientations == .portrait)
        #expect(OrientationLock.shared.isLandscape == false)
    }
}

@Test func maskForOrientation() async throws {
    #expect(OrientationLock.mask(for: .portrait) == .portrait)
    #expect(OrientationLock.mask(for: .landscapeLeft) == .landscapeLeft)
    #expect(OrientationLock.mask(for: .landscapeRight) == .landscapeRight)
    #expect(OrientationLock.mask(for: .portraitUpsideDown) == .portraitUpsideDown)
}
#endif
