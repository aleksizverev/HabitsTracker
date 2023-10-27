import UIKit

final class TrackerCreationViewController: UIViewController {
    private var trackerTitleField: UITextField = {
        let textField = UITextField()
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.firstLineHeadIndent = 16
        let placeholderText = NSAttributedString(
            string: "Enter the tracker name",
            attributes: [
                .foregroundColor: UIColor(named: "YP Gray"),
                .font: UIFont.systemFont(ofSize: 17, weight: .regular),
                .paragraphStyle: paragraphStyle
            ]
        )
        textField.attributedPlaceholder = placeholderText
        
        textField.backgroundColor = UIColor(named: "YP Background")
        textField.layer.cornerRadius = 16
        textField.layer.masksToBounds = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    private var trackerPropertiesStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.distribution = .fillProportionally
        stack.spacing = 0
        stack.layer.cornerRadius = 16
        stack.layer.masksToBounds = true
        return stack
    }()
    private var categoryButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Category", for: .normal)
        button.setTitleColor(UIColor(named: "YP Black"), for: .normal)
        button.contentHorizontalAlignment = .leading
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        button.backgroundColor = UIColor(named: "YP Background")
        return button
    }()
    private var scheduleButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Schedule", for: .normal)
        button.setTitleColor(UIColor(named: "YP Black"), for: .normal)
        button.contentHorizontalAlignment = .leading
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        button.tintColor = UIColor(named: "YP Black")
        button.backgroundColor = UIColor(named: "YP Background")
        return button
    }()
    private var separator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(named: "YP Gray")
        view.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return view
    }()
    private var listItem1: UIImageView = {
        let image = UIImage(named: "ListItem")
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    private var listItem2: UIImageView = {
        let image = UIImage(named: "ListItem")
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    private var trackerCreationButtonsStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 8
        return stack
    }()
    private var cancelButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Cancel", for: .normal)
        button.setTitleColor(UIColor(named: "YP Red"), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.layer.borderColor = UIColor(named: "YP Red")?.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.backgroundColor = .white
        return button
    }()
    private var creationButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Create", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.backgroundColor = UIColor(named: "YP Gray")
        return button
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setUpNavBar()
        addSubviews()
        applyConstraints()
    }
    
    private func setUpNavBar(){
        self.navigationItem.title = "Tracker creation"
    }
    private func addSubviews() {
        view.addSubview(trackerTitleField)
        view.addSubview(trackerPropertiesStackView)
        view.addSubview(trackerCreationButtonsStack)
        
        trackerPropertiesStackView.addArrangedSubview(categoryButton)
        trackerPropertiesStackView.addArrangedSubview(scheduleButton)
        
        trackerCreationButtonsStack.addArrangedSubview(cancelButton)
        trackerCreationButtonsStack.addArrangedSubview(creationButton)
        
        categoryButton.addSubview(separator)
        categoryButton.addSubview(listItem1)
        scheduleButton.addSubview(listItem2)
    }
    private func applyConstraints() {
        NSLayoutConstraint.activate([
            trackerTitleField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            trackerTitleField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            trackerTitleField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            trackerTitleField.heightAnchor.constraint(equalToConstant: 75),
            
            trackerPropertiesStackView.topAnchor.constraint(equalTo: trackerTitleField.bottomAnchor, constant: 24),
            trackerPropertiesStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            trackerPropertiesStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            trackerPropertiesStackView.heightAnchor.constraint(equalToConstant: 150),
            
            categoryButton.leadingAnchor.constraint(equalTo: trackerPropertiesStackView.leadingAnchor),
            categoryButton.trailingAnchor.constraint(equalTo: trackerPropertiesStackView.trailingAnchor),
            scheduleButton.leadingAnchor.constraint(equalTo: trackerPropertiesStackView.leadingAnchor),
            scheduleButton.trailingAnchor.constraint(equalTo: trackerPropertiesStackView.trailingAnchor),
            
            separator.widthAnchor.constraint(equalTo: trackerPropertiesStackView.widthAnchor, multiplier: 0.9),
            separator.bottomAnchor.constraint(equalTo: categoryButton.bottomAnchor),
            separator.centerXAnchor.constraint(equalTo: categoryButton.centerXAnchor),
            
            listItem1.trailingAnchor.constraint(equalTo: categoryButton.trailingAnchor, constant: -16),
            listItem1.centerYAnchor.constraint(equalTo: categoryButton.centerYAnchor),
            listItem2.trailingAnchor.constraint(equalTo: scheduleButton.trailingAnchor, constant: -16),
            listItem2.centerYAnchor.constraint(equalTo: scheduleButton.centerYAnchor),
            
            trackerCreationButtonsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            trackerCreationButtonsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            trackerCreationButtonsStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            trackerCreationButtonsStack.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
}
