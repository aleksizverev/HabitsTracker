import XCTest
import SnapshotTesting
@testable import HabitsTracker

final class HabitsTrackerTests: XCTestCase {
    func testTrackerListViewControllerLightTheme() {
        let vc = TrackersListViewController()
        assertSnapshot(matching: vc, as: .image(traits: UITraitCollection(userInterfaceStyle: .light)))
    }

    func testTrackerListViewControllerDarkTheme() {
        let vc = TrackersListViewController()
        assertSnapshot(matching: vc, as: .image(traits: UITraitCollection(userInterfaceStyle: .dark)))
    }
}
