import UIKit

final class TrackerTypeChoiceViewController: UIViewController {
    private var pageTitleLable: UILabel = {
        let label = UILabel()
        label.text = "Tracker type here!"
        label.font = UIFont.systemFont(ofSize: 34, weight: UIFont.Weight.bold)
        label.textColor = UIColor(red: 0.102, green: 0.106, blue: 0.133, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private var habitButton: UIButton = {
        let button = UIButton()
        button.setTitle("Habit", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 16
        button.backgroundColor = UIColor(named: "YP Black")
        
        button.addTarget(self, action: #selector(Self.habitCreationButtonDidTap), for: .touchUpInside)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    private var irregularEventButton: UIButton = {
        let button = UIButton()
        button.setTitle("Irregular event", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 16
        button.tintColor = .red
        button.backgroundColor = UIColor(named: "YP Black")
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    private var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setUpNavBar()
        
        addSubviews()
        applyConstraints()
    }
    
    @objc
    private func habitCreationButtonDidTap(){
        let trackerCreationVC = UINavigationController(rootViewController: TrackerCreationViewController())
        present(trackerCreationVC, animated: true)
    }
    private func setUpNavBar(){
        self.navigationItem.title = "Tracker creation"
    }
    private func addSubviews() {
        view.addSubview(stackView)
        stackView.addArrangedSubview(habitButton)
        stackView.addArrangedSubview(irregularEventButton)
    }
    private func applyConstraints() {
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stackView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            
            habitButton.heightAnchor.constraint(equalToConstant: 60),
            irregularEventButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
}