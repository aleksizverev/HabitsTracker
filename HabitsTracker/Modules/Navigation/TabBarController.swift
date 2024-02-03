import UIKit

final class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
    }
    
    private func setupTabs() {
        let trackersListViewController = TrackersListViewController()
        
        trackersListViewController.tabBarItem = UITabBarItem(
            title: "Trackers",
            image: UIImage(named: "TrackersListTabBarItem"),
            selectedImage: nil)
        
        let statisticsViewController = StatisticsViewController()
        statisticsViewController.tabBarItem = UITabBarItem(
            title: "Statistics",
            image: UIImage(named: "StatisticsTabBarItem"),
            selectedImage: nil)
        
        let controllers = [UINavigationController(rootViewController: trackersListViewController),
                           UINavigationController(rootViewController: statisticsViewController)]
        
        self.setViewControllers(controllers, animated: true)
    }
}
