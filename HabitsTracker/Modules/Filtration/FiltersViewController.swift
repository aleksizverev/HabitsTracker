import UIKit

protocol FilterViewControllerDelegate: AnyObject {
    func applyFilter(filter: String?)
}

final class FiltersViewController: UIViewController {
    
    weak var delegate: FilterViewControllerDelegate?

    private(set) var availableFilters: [String] = ["All trackers",
                                                      "Trackers for today",
                                                      "Completed",
                                                      "Uncompleted"]
    private var chosenFilter: String = "All trackers"
    
    private var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.isScrollEnabled = true
        tableView.rowHeight = 75
        tableView.layer.cornerRadius = 16
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.separatorColor = UIColor(named: "YP Gray")
        tableView.allowsMultipleSelection = false
        tableView.tableHeaderView = UIView()
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Filters"
        view.backgroundColor = .white
        
        setupTableView()
    }
    
    // MARK: Setup methods
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(FilterCell.self, forCellReuseIdentifier: "FilterCell")
        
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 299)
        ])
    }
    
    // MARK: Update methods
    func setChosenFilter(withTitle filter: String) {
        chosenFilter = filter
    }
}

// MARK: UITableViewDataSource
extension FiltersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return availableFilters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FilterCell",
                                                       for: indexPath) as? FilterCell
        else {
            return UITableViewCell()
        }
        
        cell.setupCategoryCell(labelText: availableFilters[indexPath.row])
        cell.selectionStyle = .none
        
        if chosenFilter == availableFilters[indexPath.row] {
            cell.accessoryType = .checkmark
            cell.setSelected(true, animated: true)
        }
        
        return cell
    }
}

// MARK: UITableViewDelegate
extension FiltersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chosenFilter = availableFilters[indexPath.row]
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .checkmark
        }
        delegate?.applyFilter(filter: chosenFilter)
        self.dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .none
        }
    }
}
