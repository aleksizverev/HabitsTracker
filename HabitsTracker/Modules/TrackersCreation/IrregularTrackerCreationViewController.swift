import UIKit

final class IrregularTrackerCreationViewController: UIViewController {
    
    private var selectedColor: UIColor?
    
    private var selectedEmoji: String?
    
    private var tableViewCellTitleData: [String] = ["Category"]
    
    private var trackerSchedule: [Int] = Array(1...7)
    
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
    
    private let creationButtonsStack: UIStackView = {
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
    
    private let emojisCollectionView = UICollectionView(frame: .zero,
                                                        collectionViewLayout: UICollectionViewFlowLayout())
    private let colorsCollectionView = UICollectionView(frame: .zero,
                                                        collectionViewLayout: UICollectionViewFlowLayout())
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.layer.cornerRadius = 16
        scrollView.layer.masksToBounds = true
        scrollView.isScrollEnabled = true
        return scrollView
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.alignment = .fill
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "Tracker creation"
        
        tableView.dataSource = self
        tableView.delegate = self
        
        trackerTitleField.delegate = self
        
        setupEmojisCollectionView()
        setupColorsCollectionView()
        
        addSubviews()
        applyConstraints()
    }
    
    // MARK: - Selectors
    @objc private func didTapCancelButton() {
        self.dismiss(animated: true)
    }
    
    @objc private func didTypeText(sender: UITextField) {
        guard let title = sender.text else {
            return
        }
        trackerTitle = title
    }
    
    @objc private func didTapCreationButton() {
        guard let trackerTitle = trackerTitle else {
            return
        }
        guard let trackerCategory = trackerCategory else {
            return
        }
        
        let tracker = Tracker(id: UUID(),
                              title: trackerTitle,
                              color: selectedColor ?? UIColor().randomColor(),
                              emoji: selectedEmoji ?? "🚀",
                              schedule: trackerSchedule)
        
        NotificationCenter.default.post(name: NSNotification.Name("CategoriesUpdateNotification"),
                                        object: nil,
                                        userInfo: ["Tracker": tracker,
                                                   "Category": trackerCategory ])
        
        self.presentingViewController?.presentingViewController?.dismiss(animated: true)
    }
    
    private func didTapCategoryButton() {
        view.endEditing(true)
        let trackerCategoryVC = TrackerCategoryViewController()
        trackerCategoryVC.delegate = self
        present(UINavigationController(rootViewController: trackerCategoryVC), animated: true)
    }
    
    // MARK: - SetupFunctions
    private func setupEmojisCollectionView() {
        emojisCollectionView.translatesAutoresizingMaskIntoConstraints = false
        emojisCollectionView.dataSource = self
        emojisCollectionView.delegate = self
        emojisCollectionView.register(EmojiCell.self, forCellWithReuseIdentifier: "EmojiCell")
        emojisCollectionView.register(PropertiesCollectionViewSectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        emojisCollectionView.contentInset = UIEdgeInsets(top: 0, left: 3, bottom: 0, right: 3)
        emojisCollectionView.allowsMultipleSelection = false
        emojisCollectionView.isScrollEnabled = false
    }
    
    private func setupColorsCollectionView() {
        colorsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        colorsCollectionView.dataSource = self
        colorsCollectionView.delegate = self
        colorsCollectionView.register(ColorCell.self, forCellWithReuseIdentifier: "ColorCell")
        colorsCollectionView.register(PropertiesCollectionViewSectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        colorsCollectionView.contentInset = UIEdgeInsets(top: 0, left: 3, bottom: 0, right: 3)
        colorsCollectionView.allowsMultipleSelection = false
        colorsCollectionView.isScrollEnabled = false
    }
    
    private func addSubviews() {
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        
        [
            trackerTitleField,
            tableView,
            emojisCollectionView,
            colorsCollectionView,
            creationButtonsStack
        ].forEach { view in
            stackView.addArrangedSubview(view)
        }
        
        [cancelButton, creationButton].forEach { view in
            creationButtonsStack.addArrangedSubview(view)
        }
        
        stackView.setCustomSpacing(24, after: trackerTitleField)
        stackView.setCustomSpacing(32, after: tableView)
        stackView.setCustomSpacing(16, after: emojisCollectionView)
        stackView.setCustomSpacing(16, after: colorsCollectionView)
    }
    
    private func applyConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            stackView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            
            trackerTitleField.heightAnchor.constraint(equalToConstant: Constants.defaultCellHeight),
            
            tableView.heightAnchor.constraint(equalToConstant: Constants.defaultTableViewHeight),
            
            emojisCollectionView.heightAnchor.constraint(equalToConstant: Constants.defaultCollectionViewHeight),
            
            colorsCollectionView.heightAnchor.constraint(equalToConstant: Constants.defaultCollectionViewHeight),
            
            creationButtonsStack.heightAnchor.constraint(equalToConstant: Constants.defaultStackElementHeight),
            creationButtonsStack.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            creationButtonsStack.trailingAnchor.constraint(equalTo: stackView.trailingAnchor)
        ])
    }
    
    // MARK: - LogicFunctions
    private func setupCreationButtonColor() {
        if let trackerTitle = trackerTitle,
           let trackerCategory = trackerCategory,
           !trackerTitle.isEmpty && !trackerCategory.isEmpty {
            creationButton.backgroundColor = UIColor(named: "YP Black")
            creationButton.isEnabled = true
            return
        }
        creationButton.backgroundColor = UIColor(named: "YP Gray")
        creationButton.isEnabled = false
    }
}

extension IrregularTrackerCreationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension IrregularTrackerCreationViewController: UITableViewDataSource {
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
        
        let listItem = UIImageView(image: UIImage(named: "ListItem"))
        listItem.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        cell.accessoryView = listItem
        
        return cell
    }
}

extension IrregularTrackerCreationViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            didTapCategoryButton()
        default:
            return
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension IrregularTrackerCreationViewController: TrackerCategoryViewControllerDelegate {
    func addCategory(category: String?) {
        trackerCategory = category
        tableView.reloadData()
    }
}

// MARK: - UICollectionViewDelegate
extension IrregularTrackerCreationViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == emojisCollectionView {
            guard let cell = collectionView.cellForItem(at: indexPath) as? EmojiCell else {
                return
            }
            selectedEmoji = cell.getCellEmoji()
            cell.didSelectEmoji()
        }
        if collectionView == colorsCollectionView {
            guard let cell = collectionView.cellForItem(at: indexPath) as? ColorCell else {
                return
            }
            let cellColor = habitColors[indexPath.row].withAlphaComponent(0.3).cgColor
            cell.layer.borderColor = cellColor
            cell.layer.borderWidth = 3
            cell.layer.cornerRadius = 8
            cell.layer.masksToBounds = true
            selectedColor = cell.getCellColor()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if collectionView == emojisCollectionView {
            guard let cell = collectionView.cellForItem(at: indexPath) as? EmojiCell else {
                return
            }
            cell.didDeselectEmoji()
            selectedEmoji = nil
        }
        if collectionView == colorsCollectionView {
            guard let cell = collectionView.cellForItem(at: indexPath) as? ColorCell else {
                return
            }
            cell.layer.borderColor = UIColor.clear.cgColor
            selectedColor = nil
        }
    }
}

// MARK: - UICollectionViewDataSource
extension IrregularTrackerCreationViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == emojisCollectionView {
            return habitEmojis.count
        }
        if collectionView == colorsCollectionView {
            return habitColors.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == emojisCollectionView {
            guard let cell = emojisCollectionView.dequeueReusableCell(
                withReuseIdentifier: "EmojiCell",
                for: indexPath) as? EmojiCell else {
                return EmojiCell()
            }
            cell.setEmoji(emoji: habitEmojis[indexPath.row])
            return cell
        }
        if collectionView == colorsCollectionView {
            guard let cell = colorsCollectionView.dequeueReusableCell(
                withReuseIdentifier: "ColorCell",
                for: indexPath) as? ColorCell else {
                return ColorCell()
            }
            cell.setColor(color: habitColors[indexPath.row])
            return cell
        }
        return UICollectionViewCell()
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension IrregularTrackerCreationViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 52, height: 52)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        var id: String
        
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            id = "header"
        default:
            id = ""
        }
        
        guard let view = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: id,
            for: indexPath) as? PropertiesCollectionViewSectionHeader else {
            return PropertiesCollectionViewSectionHeader()
        }
        
        if collectionView == emojisCollectionView {
            view.titleLabel.text = "Emoji"
        }
        if collectionView == colorsCollectionView {
            view.titleLabel.text = "Color"
        }
        return view
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        let indexPath = IndexPath(row: 0, section: section)
        let headerView = self.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath)
        
        return headerView.systemLayoutSizeFitting(
            CGSize(width: collectionView.frame.width,
                   height: UIView.layoutFittingExpandedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel)
    }
}

extension IrregularTrackerCreationViewController {
    private enum Constants {
        static let defaultCellHeight: CGFloat = 75
        static let defaultTableViewHeight: CGFloat = 74
        static let defaultCollectionViewHeight: CGFloat = 222
        static let defaultStackElementHeight: CGFloat = 60
        static let defaultStackElementWidth: CGFloat = 343
    }
}
