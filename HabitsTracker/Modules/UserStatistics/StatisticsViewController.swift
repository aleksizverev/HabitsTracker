import UIKit

final class StatisticsViewController: UIViewController {
    private let pageTitleLable: UILabel = {
        let label = UILabel()
        label.text = "User stats to be added..."
        label.font = UIFont.systemFont(ofSize: 34, weight: UIFont.Weight.bold)
        label.textColor = UIColor(red: 0.102, green: 0.106, blue: 0.133, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        addSubviews()
        applyConstraints()
    }
    
    private func addSubviews() {
        view.addSubview(pageTitleLable)
    }
    
    private func applyConstraints() {
        NSLayoutConstraint.activate([
            pageTitleLable.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            pageTitleLable.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])
    }
}
