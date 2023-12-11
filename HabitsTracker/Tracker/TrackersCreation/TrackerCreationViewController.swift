import UIKit

final class TrackerCreationViewController: UIViewController {
    private let emojis: [String] = ["😀", "😎", "🚀", "⚽️", "🍕", "🎉", "🌟", "🎈", "🐶", "🍦", "🎸", "📚", "🚲", "🏖️", "🍩", "🎲", "🍭", "🖥️", "🌈", "🍔", "📱", "🛸", "🏕️", "🎨", "🌺", "🎁", "📷", "🍉", "🧩", "🎳"]
    private var weekdaysNames = [
        1: "Mon",
        2: "Tue",
        3: "Wed",
        4: "Thu",
        5: "Fri",
        6: "Sat",
        7: "Sun",
    ]
    
    private var tableViewCellTitleData: [String] = ["Category", "Schedule"]
    private var tableViewCellScheduleSubTitleData: String = ""
    private var trackerSchedule: [Int] = [] {
        didSet {
            setupCreationButtonColor()
        }
    }
    private var trackerTitle: String? {
        didSet {
            setupCreationButtonColor()
        }
    }
    private var trackerCategory: String? {
        didSet {
            setupCreationButtonColor()
        }
    }
    
    private lazy var trackerTitleField: UITextField = {
        let textField = UITextField()
        textField.setLeftPaddingPoints(16)
        textField.setRightPaddingPoints(16)
        
        let paragraphStyle = NSMutableParagraphStyle()
        let placeholderText = NSAttributedString(
            string: "Enter tracker name",
            attributes: [.foregroundColor: UIColor(named: "YP Gray"),
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
    private let trackerCreationButtonsStack: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        return stackView
    }()
    private lazy var cancelButton: UIButton = {
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
        button.addTarget(self, action: #selector(didTapCancelButton), for: .touchUpInside)
        return button
    }()
    private lazy var creationButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Create", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.backgroundColor = UIColor(named: "YP Gray")
        button.isEnabled = false
        button.addTarget(self, action: #selector(didTapCreationButton), for: .touchUpInside)
        return button
    }()
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = UIColor(named: "YP Background")
        tableView.isScrollEnabled = false
        tableView.rowHeight = 75
        tableView.layer.cornerRadius = 16
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.separatorColor = UIColor(named: "YP Gray")
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "Tracker creation"
        
        tableView.dataSource = self
        tableView.delegate = self
        
        trackerTitleField.delegate = self
        
        addSubviews()
        applyConstraints()
    }
    
    // MARK: - Selectors
    @objc
    private func didTapCancelButton() {
        self.dismiss(animated: true)
    }
    @objc
    private func didTypeText(sender: UITextField) {
        guard let title = sender.text else { return }
        trackerTitle = title
    }
    @objc
    private func didTapCreationButton(){
        guard let trackerTitle = trackerTitle else { return }
        guard let trackerCategory = trackerCategory else { return }
        
        let tracker = Tracker(id: UUID(),
                              title: trackerTitle,
                              color: UIColor().randomColor(),
                              emoji: emojis.randomElement() ?? "🚀",
                              schedule: trackerSchedule)
        
        NotificationCenter.default.post(name: NSNotification.Name("CategoriesUpdateNotification"),
                                        object: nil,
                                        userInfo: ["Tracker": tracker,
                                                   "Category" : trackerCategory ])
        
        self.presentingViewController?.presentingViewController?.dismiss(animated: true)
    }
    private func didTapScheduleButton() {
        view.endEditing(true)
        
        let trackerScheduleVC = TrackerScheduleViewController()
        trackerScheduleVC.delegate = self
        trackerScheduleVC.chosenSchedule = Set<Int>(trackerSchedule)
        present(UINavigationController(rootViewController: trackerScheduleVC), animated: true)
    }
    private func didTapCategoryButton() {
        view.endEditing(true)
        let trackerCategoryVC = TrackerCategoryViewController()
        trackerCategoryVC.delegate = self
        trackerCategoryVC.setChosenCategory(category: trackerCategory)
        present(UINavigationController(rootViewController: trackerCategoryVC), animated: true)
    }
    
    // MARK: - SetupFunctions
    private func addSubviews() {
        view.addSubview(trackerTitleField)
        view.addSubview(trackerCreationButtonsStack)
        view.addSubview(tableView)
        
        trackerCreationButtonsStack.addArrangedSubview(cancelButton)
        trackerCreationButtonsStack.addArrangedSubview(creationButton)
    }
    private func applyConstraints() {
        NSLayoutConstraint.activate([
            trackerTitleField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            trackerTitleField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            trackerTitleField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            trackerTitleField.heightAnchor.constraint(equalToConstant: Constants.defaultCellHeight),
            
            tableView.topAnchor.constraint(equalTo: trackerTitleField.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: Constants.defaultTableViewHeight),
            
            trackerCreationButtonsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            trackerCreationButtonsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            trackerCreationButtonsStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            trackerCreationButtonsStack.heightAnchor.constraint(equalToConstant: Constants.defaultButtonStackHeight)
        ])
    }
    
    // MARK: - LogicFunctions
    private func setupCreationButtonColor() {
        if let trackerTitle = trackerTitle,
           let trackerCategory = trackerCategory,
           !trackerTitle.isEmpty && !trackerSchedule.isEmpty && !trackerCategory.isEmpty {
            creationButton.backgroundColor = UIColor(named: "YP Black")
            creationButton.isEnabled = true
            return
        }
        creationButton.backgroundColor = UIColor(named: "YP Gray")
        creationButton.isEnabled = false
    }
}

extension TrackerCreationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension TrackerCreationViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableViewCellTitleData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "SubtitleCell")
        
        cell.backgroundColor = UIColor(named: "YP Background")
        cell.textLabel?.text = tableViewCellTitleData[indexPath.row]
        cell.textLabel?.textColor = UIColor(named: "YP Black")
        cell.textLabel?.font = UIFont.systemFont(ofSize: 17)
        
        if indexPath.row == 0 {
            cell.detailTextLabel?.text = trackerCategory
            cell.detailTextLabel?.textColor = UIColor(named: "YP Gray")
            cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 17)
        }
        
        if indexPath.row == 1 {
            cell.detailTextLabel?.text = tableViewCellScheduleSubTitleData
            cell.detailTextLabel?.textColor = UIColor(named: "YP Gray")
            cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 17)
        }
        
        
        let listItem = UIImageView(image: UIImage(named: "ListItem"))
        listItem.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        cell.accessoryView = listItem
        
        return cell
    }
}

extension TrackerCreationViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            didTapCategoryButton()
        case 1:
            didTapScheduleButton()
        default:
            return
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - TrackerScheduleViewControllerDelegate
extension TrackerCreationViewController: TrackerScheduleViewControllerDelegate {
    func addSchedule(schedule: [Int]) {
        trackerSchedule = schedule
        tableViewCellScheduleSubTitleData = ""
        
        for dayNum in schedule {
            if let name = weekdaysNames[dayNum] {
                tableViewCellScheduleSubTitleData += "\(name), "
            }
        }
        if !tableViewCellScheduleSubTitleData.isEmpty {
            tableViewCellScheduleSubTitleData = String(tableViewCellScheduleSubTitleData.dropLast(2))
        }
        tableView.reloadData()
    }
}

extension TrackerCreationViewController: TrackerCategoryViewControllerDelegate {
    func addCategory(category: String?) {
        trackerCategory = category
        tableView.reloadData()
    }
}

extension TrackerCreationViewController {
    private enum Constants {
        static let defaultCellHeight: CGFloat = 75
        static let defaultTableViewHeight: CGFloat = 149
        static let defaultButtonStackHeight: CGFloat = 60
    }
}
