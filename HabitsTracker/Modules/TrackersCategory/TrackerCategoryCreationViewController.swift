import UIKit

protocol TrackerCategoryCreationViewControllerDelegate: AnyObject {
    func addNewCategory(category: String)
}

final class TrackerCategoryCreationViewController: UIViewController {
    
    weak var delegate: TrackerCategoryCreationViewControllerDelegate?
    
    private var categoryTitle: String? {
        didSet {
            setupDoneButtonState()
        }
    }
    
    private lazy var categoryTitleField: UITextField = {
        let textField = UITextField()
        textField.setLeftPaddingPoints(16)
        textField.setRightPaddingPoints(16)
        
        let paragraphStyle = NSMutableParagraphStyle()
        let placeholderText = NSAttributedString(
            string: "Enter category name",
            attributes: [.foregroundColor: UIColor(named: "YP Gray") ?? .lightGray,
                         .font: UIFont.systemFont(ofSize: 17, weight: .regular),
                         .paragraphStyle: paragraphStyle])
        textField.attributedPlaceholder = placeholderText
        textField.backgroundColor = UIColor(named: "YP Background")
        textField.layer.cornerRadius = 16
        textField.layer.masksToBounds = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.addTarget(self, action: #selector(didTypeText), for: .editingChanged)
        
        return textField
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Done", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 16
        button.backgroundColor = UIColor(named: "YP Gray")
        button.addTarget(self, action: #selector(Self.didTapDoneButton), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "New category"
        
        addSubviews()
        applyConstraints()
    }
    
    @objc private func didTapDoneButton() {
        guard let categoryTitle = categoryTitle else {
            return
        }
        delegate?.addNewCategory(category: categoryTitle)
        self.dismiss(animated: true)
    }
    
    @objc private func didTypeText(sender: UITextField) {
        guard let title = sender.text else {
            return
        }
        categoryTitle = title
    }
    
    private func setupDoneButtonState() {
        if let categoryTitle = categoryTitle,
           !categoryTitle.isEmpty {
            doneButton.backgroundColor = UIColor(named: "YP Black")
            doneButton.isEnabled = true
            return
        }
        doneButton.backgroundColor = UIColor(named: "YP Gray")
        doneButton.isEnabled = false
    }
    
    private func addSubviews() {
        view.addSubview(categoryTitleField)
        view.addSubview(doneButton)
    }
    
    private func applyConstraints() {
        NSLayoutConstraint.activate([
            categoryTitleField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            categoryTitleField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            categoryTitleField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            categoryTitleField.heightAnchor.constraint(equalToConstant: Constants.defaultTextFieldHeight),
            
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            doneButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            doneButton.heightAnchor.constraint(equalToConstant: Constants.defaultButtonHeight)
        ])
    }
}

extension TrackerCategoryCreationViewController {
    private enum Constants {
        static let defaultTextFieldHeight: CGFloat = 75
        static let defaultButtonHeight: CGFloat = 60
    }
}
