import XCTest
import SnapshotTesting
@testable import HabitsTracker

final class HabitsTrackerTests: XCTestCase {
    func testTrackerListViewController() {
        let vc = TrackersListViewController()
        
        assertSnapshot(matching: vc, as: .image)
    }
}
