import UIKit

final class TrackerEditingViewController: UIViewController {
    private var weekdaysNames = [
        1: "Mon",
        2: "Tue",
        3: "Wed",
        4: "Thu",
        5: "Fri",
        6: "Sat",
        7: "Sun"
    ]
    
    private var counterLable: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    private var tableViewCellTitleData: [String] = ["Category", "Schedule"]
    
    private var tableViewCellScheduleSubTitleData: String = ""
    
    private let trackerID: UUID
    
    private var trackerColor: UIColor {
        didSet {
            setupCreationButtonState()
        }
    }
    
    private var trackerEmoji: String {
        didSet {
            setupCreationButtonState()
        }
    }
    
    private var trackerSchedule: [Int] = [] {
        didSet {
            setupCreationButtonState()
        }
    }
    
    private var trackerTitle: String {
        didSet {
            setupCreationButtonState()
        }
    }
    
    private var trackerCategory: String {
        didSet {
            setupCreationButtonState()
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
    
    private lazy var saveButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Save", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.backgroundColor = UIColor(named: "YP Gray")
        button.isEnabled = false
        button.addTarget(self, action: #selector(didTapSaveButton), for: .touchUpInside)
        return button
    }()
    
    private let creationButtonsStack: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        return stackView
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
    
    private let emojisCollectionView = UICollectionView(frame: .zero,
                                                        collectionViewLayout: UICollectionViewFlowLayout())
    
    private let colorsCollectionView = UICollectionView(frame: .zero,
                                                        collectionViewLayout: UICollectionViewFlowLayout())
    
    init(id: UUID, title: String, category: String, schedule: [Int], emoji: String, color: UIColor, counter: Int) {
        trackerID = id
        trackerTitle = title
        trackerCategory = category
        trackerEmoji = emoji
        trackerSchedule = schedule
        trackerTitle = title
        trackerColor = color
        
        super.init(nibName: nil, bundle: nil)
        
        addSchedule(schedule: trackerSchedule)
        trackerTitleField.text = title
        updateHabitStatisticsLabelDays(counter: counter)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "Tracker editing"
        
        trackerTitleField.delegate = self
        
        setupTableView()
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
    
    @objc private func didTapSaveButton() {
        
        let tracker = Tracker(id: trackerID,
                              title: trackerTitle,
                              color: trackerColor,
                              emoji: trackerEmoji,
                              schedule: trackerSchedule)
        
        NotificationCenter.default.post(name: NSNotification.Name("TrackerEditNotification"),
                                        object: nil,
                                        userInfo: ["Tracker": tracker,
                                                   "Category": trackerCategory ])
        
        self.presentingViewController?.dismiss(animated: true)
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
        let viewModel = TrackerCategoryViewModel(categoryStore: TrackerCategoryStore())
        viewModel.delegate = self
        viewModel.setChosenCategory(withTitle: trackerCategory)
        let trackerCategoryVC = TrackerCategoryViewController(viewModel: viewModel)
        present(UINavigationController(rootViewController: trackerCategoryVC), animated: true)
    }
    
    // MARK: - SetupFunctions
    private func updateHabitStatisticsLabelDays(counter: Int) {
        counterLable.text = counter == 1
        ? String(counter) + " day"
        : String(counter) + " days"
    }
    
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
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func setupCreationButtonState() {
        if !trackerTitle.isEmpty && !trackerSchedule.isEmpty && !trackerCategory.isEmpty {
            saveButton.backgroundColor = UIColor(named: "YP Black")
            saveButton.isEnabled = true
            return
        }
        saveButton.backgroundColor = UIColor(named: "YP Gray")
        saveButton.isEnabled = false
    }
    
    private func addSubviews() {
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        
        [
            counterLable,
            trackerTitleField,
            tableView,
            emojisCollectionView,
            colorsCollectionView,
            creationButtonsStack
        ].forEach { view in
            stackView.addArrangedSubview(view)
        }
        
        [cancelButton, saveButton].forEach { view in
            creationButtonsStack.addArrangedSubview(view)
        }
        
        stackView.setCustomSpacing(16, after: counterLable)
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
            
            counterLable.heightAnchor.constraint(equalToConstant: 38),
            
            trackerTitleField.heightAnchor.constraint(equalToConstant: Constants.defaultCellHeight),
            
            tableView.heightAnchor.constraint(equalToConstant: Constants.defaultTableViewHeight),
            
            emojisCollectionView.heightAnchor.constraint(equalToConstant: Constants.defaultCollectionViewHeight),
            
            colorsCollectionView.heightAnchor.constraint(equalToConstant: Constants.defaultCollectionViewHeight),
            
            creationButtonsStack.heightAnchor.constraint(equalToConstant: Constants.defaultStackElementHeight),
            creationButtonsStack.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            creationButtonsStack.trailingAnchor.constraint(equalTo: stackView.trailingAnchor)
        ])
    }
}

// MARK: - UITextFieldDelegate
extension TrackerEditingViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - UITableViewDataSource
extension TrackerEditingViewController: UITableViewDataSource {
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

extension TrackerEditingViewController: UITableViewDelegate {
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
extension TrackerEditingViewController: TrackerScheduleViewControllerDelegate {
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

extension TrackerEditingViewController: TrackerCategoryViewControllerDelegate {
    func addCategory(category: String?) {
        trackerCategory = category ?? ""
        tableView.reloadData()
    }
}

extension TrackerEditingViewController {
    private enum Constants {
        static let defaultCellHeight: CGFloat = 75
        static let defaultTableViewHeight: CGFloat = 149
        static let defaultCollectionViewHeight: CGFloat = 222
        static let defaultStackElementHeight: CGFloat = 60
        static let defaultStackElementWidth: CGFloat = 343
    }
}

// MARK: - UICollectionViewDelegate
extension TrackerEditingViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == emojisCollectionView {
            guard let cell = collectionView.cellForItem(at: indexPath) as? EmojiCell else {
                return
            }
            trackerEmoji = cell.getCellEmoji()
            cell.didSelectEmoji()
        }
        if collectionView == colorsCollectionView {
            guard let cell = collectionView.cellForItem(at: indexPath) as? ColorCell else {
                return
            }
            let cellColor = habitColors[indexPath.row].withAlphaComponent(0.3).cgColor
            cell.didSelectColor(color: cellColor)
            trackerColor = cell.getCellColor()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if collectionView == emojisCollectionView {
            guard let cell = collectionView.cellForItem(at: indexPath) as? EmojiCell else {
                return
            }
            cell.didDeselectEmoji()
            trackerEmoji = ""
        }
        if collectionView == colorsCollectionView {
            guard let cell = collectionView.cellForItem(at: indexPath) as? ColorCell else {
                return
            }
            cell.didDeselectColor()
            trackerColor = UIColor()
        }
    }
}

// MARK: - UICollectionViewDataSource
extension TrackerEditingViewController: UICollectionViewDataSource {
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
            
            if trackerEmoji == habitEmojis[indexPath.row] {
                emojisCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: .left)
                cell.didSelectEmoji()
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
            
            if trackerColor.isEqualTo(color: habitColors[indexPath.row]) {
                colorsCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: .left)
                cell.didSelectColor(color: trackerColor.withAlphaComponent(0.3).cgColor)
            }
            
            cell.setColor(color: habitColors[indexPath.row])
            return cell
        }
        return UICollectionViewCell()
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension TrackerEditingViewController: UICollectionViewDelegateFlowLayout {
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
