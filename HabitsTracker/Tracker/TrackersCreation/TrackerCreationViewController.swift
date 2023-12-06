import UIKit

final class TrackerCreationViewController: UIViewController, TrackerScheduleViewControllerDelegate {
    /*
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
     button.addTarget(self, action: #selector(Self.didTapScheduleButton), for: .touchUpInside)
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
     */
    
    private var trackerSchedule: [Int] = []
    private var weekdaysNames = [
        1: "Mon",
        2: "Tue",
        3: "Wed",
        4: "Thu",
        5: "Fri",
        6: "Sat",
        7: "Sun",
    ]
    
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
        return button
    }()
    
    private var tableViewCellTitleData: [String] = ["Category", "Schedule"]
    private var tableViewCellSubTitleData: String = ""
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
        
        addSubviews()
        applyConstraints()
    }
    
    // MARK: - Selectors
    @objc
    private func didTapCancelButton(){
        self.dismiss(animated: true)
    }
    @objc
    private func didTapScheduleButton(){
        let trackerScheduleVC = TrackerScheduleViewController()
        trackerScheduleVC.delegate = self
        trackerScheduleVC.chosenSchedule = Set<Int>(trackerSchedule)
        present(UINavigationController(rootViewController: trackerScheduleVC), animated: true)
    }
    
    // MARK: - SetupFunctions
    private func addSubviews() {
        view.addSubview(trackerTitleField)
        view.addSubview(trackerCreationButtonsStack)
        view.addSubview(tableView)
        
        trackerCreationButtonsStack.addArrangedSubview(cancelButton)
        trackerCreationButtonsStack.addArrangedSubview(creationButton)
        
        /*
         view.addSubview(trackerPropertiesStackView)
         trackerPropertiesStackView.addArrangedSubview(categoryButton)
         trackerPropertiesStackView.addArrangedSubview(scheduleButton)
         
         categoryButton.addSubview(separator)
         categoryButton.addSubview(listItem1)
         scheduleButton.addSubview(listItem2)
         */
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
            
            /*
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
             */
            
            trackerCreationButtonsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            trackerCreationButtonsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            trackerCreationButtonsStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            trackerCreationButtonsStack.heightAnchor.constraint(equalToConstant: 60)
        ])
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
