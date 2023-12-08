import UIKit

final class TrackerCreationViewController: UIViewController, TrackerScheduleViewControllerDelegate {
    let emojis: [String] = ["😀", "😎", "🚀", "⚽️", "🍕", "🎉", "🌟", "🎈", "🐶", "🍦", "🎸", "📚", "🚲", "🏖️", "🍩", "🎲", "🍭", "🖥️", "🌈", "🍔", "📱", "🛸", "🏕️", "🎨", "🌺", "🎁", "📷", "🍉", "🧩", "🎳"]
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
    private var tableViewCellSubTitleData: String = ""
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
    
    private var trackerTitleField: UITextField = {
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
        textField.addTarget(self, action: #selector(Self.didTypeText), for: .editingChanged)
        
        return textField
    }()
    private var trackerCreationButtonsStack: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        return stackView
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
        button.addTarget(self, action: #selector(Self.didTapCancelButton), for: .touchUpInside)
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
        button.isEnabled = false
        button.addTarget(self, action: #selector(Self.didTapCreationButton), for: .touchUpInside)
        return button
    }()
    private var tableView: UITableView = {
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
    private func didTapScheduleButton() {
        view.endEditing(true)
        
        let trackerScheduleVC = TrackerScheduleViewController()
        trackerScheduleVC.delegate = self
        trackerScheduleVC.chosenSchedule = Set<Int>(trackerSchedule)
        present(UINavigationController(rootViewController: trackerScheduleVC), animated: true)
    }
    @objc
    private func didTypeText(sender: UITextField) {
        guard let title = sender.text else { return }
        trackerTitle = title
    }
    @objc
    private func didTapCreationButton(){
        guard let trackerTitle = trackerTitle else { return }
        if trackerSchedule.isEmpty {
            print("EMPTY SCHEDULE") // Debug print, to be removed in further sprints
        }
        
        let tracker = Tracker(id: UUID(),
                              title: trackerTitle,
                              color: randomColor(),
                              emoji: emojis[Int.random(in: 0..<emojis.count)],
                              schedule: trackerSchedule)
        
        NotificationCenter.default.post(name: NSNotification.Name("CategoriesUpdateNotification"),
                                        object: nil,
                                        userInfo: ["Tracker": tracker])
        
        self.dismiss(animated: true)
    }
    
    // temporary solution
    func randomColor() -> UIColor {
        let red = CGFloat.random(in: 0...1)
        let green = CGFloat.random(in: 0...1)
        let blue = CGFloat.random(in: 0...1)
        
        let color = UIColor(red: red, green: green, blue: blue, alpha: 1.0)
        return color
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
            trackerTitleField.heightAnchor.constraint(equalToConstant: 75),
            
            tableView.topAnchor.constraint(equalTo: trackerTitleField.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 149),
            
            trackerCreationButtonsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            trackerCreationButtonsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            trackerCreationButtonsStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            trackerCreationButtonsStack.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    // MARK: - LogicFunctions
    private func setupCreationButtonColor() {
        if let trackerTitle = trackerTitle,
           !trackerTitle.isEmpty && !trackerSchedule.isEmpty {
            creationButton.backgroundColor = UIColor(named: "YP Black")
            creationButton.isEnabled = true
            return
        }
        creationButton.backgroundColor = UIColor(named: "YP Gray")
        creationButton.isEnabled = false
    }
    
    
    // MARK: - TrackerScheduleViewControllerDelegate
    func addSchedule(schedule: [Int]) {
        trackerSchedule = schedule
        tableViewCellSubTitleData = ""
        
        for dayNum in schedule {
            if let name = weekdaysNames[dayNum] {
                tableViewCellSubTitleData += "\(name), "
            }
        }
        if !tableViewCellSubTitleData.isEmpty {
            tableViewCellSubTitleData = String(tableViewCellSubTitleData.dropLast(2))
        }
        tableView.reloadData()
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
        
        if indexPath.row == 1 {
            cell.detailTextLabel?.text = tableViewCellSubTitleData
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
        if indexPath.row == 1 {
            didTapScheduleButton()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
