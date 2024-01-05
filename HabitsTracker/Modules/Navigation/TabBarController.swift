import UIKit

final class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTabs()
    }
    
    private func setUpTabs() {
        let trackersListViewController = TrackersListViewController()
        
        let navigationController = UINavigationController(rootViewController: trackersListViewController)
        
        trackersListViewController.tabBarItem = UITabBarItem(
            title: "Trackers",
            image: UIImage(named: "TrackersListTabBarItem"),
            selectedImage: nil)
        
        let statisticsViewController = StatisticsViewController()
        statisticsViewController.tabBarItem = UITabBarItem(
            title: "Statistics",
            image: UIImage(named: "StatisticsTabBarItem"),
            selectedImage: nil)
        
        let controllers = [navigationController, statisticsViewController]
        
        self.setViewControllers(controllers, animated: true)
    }
}
