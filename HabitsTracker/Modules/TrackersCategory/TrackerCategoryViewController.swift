import UIKit

protocol TrackerCategoryViewControllerDelegate: AnyObject {
    func addCategory(category: String?)
}

final class TrackerCategoryViewController: UIViewController {
    weak var delegate: TrackerCategoryViewControllerDelegate?
    
    private var availableCategories: [String] = ["Important", "Not so important"]
    
    private var chosenCategory: String?
    
    private var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = UIColor(named: "YP Background")
        tableView.isScrollEnabled = false
        tableView.rowHeight = 75
        tableView.layer.cornerRadius = 16
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.separatorColor = UIColor(named: "YP Gray")
        tableView.allowsMultipleSelection = false
        tableView.tableHeaderView = UIView()
        return tableView
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Done", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 16
        button.backgroundColor = UIColor(named: "YP Black")
        button.addTarget(self, action: #selector(Self.didTapDoneButton), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Category"
        view.backgroundColor = .white
        
        tableView.dataSource = self
        tableView.delegate = self
        
        addSubviews()
        applyConstraints()
    }
    
    @objc private func didTapDoneButton() {
        delegate?.addCategory(category: chosenCategory)
        self.dismiss(animated: true)
    }
    
    private func addSubviews() {
        view.addSubview(tableView)
        view.addSubview(doneButton)
    }
    
    private func applyConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 149),
            
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    func setChosenCategory(category: String?) {
        chosenCategory = category
    }
}

extension TrackerCategoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return availableCategories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "CategoryCell")
        cell.backgroundColor = UIColor(named: "YP Background")
        cell.textLabel?.text = availableCategories[indexPath.row]
        cell.textLabel?.textColor = UIColor(named: "YP Black")
        cell.textLabel?.font = UIFont.systemFont(ofSize: 17)
        cell.selectionStyle = .none
        return cell
    }
}

extension TrackerCategoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chosenCategory = availableCategories[indexPath.row]
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .checkmark
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .none
        }
    }
}
