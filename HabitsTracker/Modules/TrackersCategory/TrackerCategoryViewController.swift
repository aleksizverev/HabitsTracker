import UIKit

protocol TrackerCategoryViewControllerDelegate: AnyObject {
    func addCategory(category: String?)
}

final class TrackerCategoryViewController: UIViewController {
    weak var delegate: TrackerCategoryViewControllerDelegate?
    
    private var viewModel: TrackerCategoryViewModel!
    
    private var chosenCategory: String?
    
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
    
    private lazy var creationButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Create new category", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 16
        button.backgroundColor = UIColor(named: "YP Black")
        button.addTarget(self, action: #selector(Self.didTapCategoryCreationButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var placeholderImageView: UIImageView = {
        let imageView = UIImageView()
        let image = UIImage(named: "TrackersListPlaceholder")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = image
        imageView.isHidden = true
        return imageView
    }()
    
    private lazy var placeholderText: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Habits and events can be categorized"
        label.textColor = UIColor(named: "YP Black")
        label.font = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.medium)
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Category"
        view.backgroundColor = .white
        
        viewModel = TrackerCategoryViewModel(categoryStore: TrackerCategoryStore())
        viewModel.onChange = tableView.reloadData
        
        setupEmptyScreen()
        setupCreationButton()
        setupTableView()
    }
    
    // MARK: Objc methods
    @objc private func didTapCategoryCreationButton() {
        let categoryCreationVC = TrackerCategoryCreationViewController()
        categoryCreationVC.delegate = self
        present(UINavigationController(rootViewController: categoryCreationVC), animated: true)
    }
    
    @objc private func didTapCategoryButton() {
        delegate?.addCategory(category: chosenCategory)
        self.dismiss(animated: true)
    }
    
    // MARK: Setup methods
    private func setupEmptyScreen() {
        view.addSubview(placeholderImageView)
        view.addSubview(placeholderText)
        NSLayoutConstraint.activate([
            placeholderImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            placeholderText.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            placeholderText.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            placeholderText.topAnchor.constraint(equalTo: placeholderImageView.bottomAnchor, constant: 8)
        ])
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(CategoryCell.self, forCellReuseIdentifier: "CategoryCell")
        
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(greaterThanOrEqualTo: creationButton.topAnchor, constant: -47)
        ])
    }
    
    private func setupCreationButton() {
        view.addSubview(creationButton)
        NSLayoutConstraint.activate([
            creationButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            creationButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            creationButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            creationButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    // MARK: Support methods
    private func showEmptyScreen() {
        placeholderImageView.isHidden = false
        placeholderText.isHidden = false
        tableView.isHidden = true
    }
    
    private func hideEmptyScreen() {
        placeholderImageView.isHidden = true
        placeholderText.isHidden = true
        tableView.isHidden = false
    }
    
    // MARK: Update methods
    func setChosenCategory(category: String?) {
        chosenCategory = category
    }
    
    func updateTableView() {
        tableView.reloadData()
    }
}

// MARK: UITableViewDataSource
extension TrackerCategoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let availableCategoriesCnt = viewModel.availableCategories.count
        if availableCategoriesCnt == 0 {
            showEmptyScreen()
        } else {
            hideEmptyScreen()
        }
        return availableCategoriesCnt
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell",
                                                       for: indexPath) as? CategoryCell
        else {
            return UITableViewCell()
        }
        cell.setupCategoryCell(labelText: viewModel.availableCategories[indexPath.row])
        cell.selectionStyle = .none
        return cell
    }
}

// MARK: UITableViewDelegate
extension TrackerCategoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chosenCategory = viewModel.availableCategories[indexPath.row]
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .checkmark
        }
        self.didTapCategoryButton()
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .none
        }
    }
}

// MARK: TrackerCategoryCreationViewControllerDelegate
extension TrackerCategoryViewController: TrackerCategoryCreationViewControllerDelegate {
    func addNewCategory(category: String) {
        viewModel.addNewCategory(category: category)
    }
}
