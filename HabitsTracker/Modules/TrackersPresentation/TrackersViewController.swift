import UIKit

final class TrackersListViewController: UIViewController {
    
    // MARK: - Stores
    let categoryStore = TrackerCategoryStore()
    let trackerStore = TrackerStore()
    let recordStore = TrackerRecordStore()
    
    // MARK: - LogicVariables
    let emojis: [String] = ["😀", "😎", "🚀", "⚽️", "🍕", "🎉", "🌟", "🎈", "🐶", "🍦", "🎸", "📚", "🚲", "🏖️", "🍩", "🎲", "🍭", "🖥️", "🌈", "🍔", "📱", "🛸", "🏕️", "🎨", "🌺", "🎁", "📷", "🍉", "🧩", "🎳"]
    
    private var allCategories: [TrackerCategory] = []
    private var visibleCategories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    private lazy var currentDatePickerDateValue: Date = myCalendar.startOfDay(for: Date())
    private lazy var currentDayNumber: Int = getCurrentDayNaumber(date: currentDatePickerDateValue)
    private let myCalendar = Calendar(identifier: .gregorian)
    
    // MARK: - UIVariables
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private var searchController = UISearchController()
    private var staticView: UIView = {
        let staticView = UIView()
        staticView.translatesAutoresizingMaskIntoConstraints = false
        staticView.backgroundColor = .white
        return staticView
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
        label.text = "What shall we track?"
        label.textColor = UIColor(named: "YP Black")
        label.font = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.medium)
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    // MARK: - SetupFunctions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleNotification(_:)),
                                               name: NSNotification.Name("CategoriesUpdateNotification"),
                                               object: nil)
        
        self.view.backgroundColor = .white
        
        trackerStore.delegate = self
        
        setupNavBar()
        setupCollectionView()
        categoryStore.setupCategoryDataBase()
        
        completedTrackers = recordStore.records
        allCategories = categoryStore.categories
        visibleCategories = allCategories
        updateVisibleCategories()
        
        addSubviews()
        applyConstraints()
    }
    
    private func setupNavBar() {
        
        self.navigationItem.searchController = searchController
        self.navigationItem.searchController?.searchResultsUpdater = self
        self.navigationItem.searchController?.delegate = self
        self.navigationItem.searchController?.hidesNavigationBarDuringPresentation = false
        self.navigationItem.searchController?.obscuresBackgroundDuringPresentation = false
        self.navigationItem.hidesSearchBarWhenScrolling = false
        
        self.navigationItem.title = "Trackers"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        let datePicker = UIDatePicker()
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.locale = Locale(identifier: "fi")
        datePicker.clipsToBounds = true
        datePicker.calendar.firstWeekday = 2
        datePicker.addTarget(self,
                             action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        
        let image = UIImage(named: "AddTrackerButton")
        let plusButton = UIBarButtonItem(image: image,
                                         style: .plain,
                                         target: self,
                                         action: #selector(Self.createTrackerButtonDidTap))
        plusButton.tintColor = UIColor(named: "YP Black")
        self.navigationItem.leftBarButtonItem = plusButton
        self.navigationItem.leftBarButtonItem?.imageInsets = UIEdgeInsets(top: 0, left: -12, bottom: 0, right: 0)
    }
    private func setupCollectionView() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: "TrackerCell")
        collectionView.register(TrackersCollectionViewSectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        collectionView.contentInset = UIEdgeInsets(top: 6, left: 16, bottom: 24, right: 16)
    }
    private func showEmptyScreen() {
        placeholderImageView.isHidden = false
        placeholderText.isHidden = false
    }
    private func hideEmptyScreen() {
        placeholderImageView.isHidden = true
        placeholderText.isHidden = true
    }
    private func addSubviews() {
        view.addSubview(staticView)
        view.addSubview(collectionView)
        view.addSubview(placeholderImageView)
        view.addSubview(placeholderText)
    }
    private func applyConstraints() {
        NSLayoutConstraint.activate([
            placeholderImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            placeholderText.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            placeholderText.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            placeholderText.topAnchor.constraint(equalTo: placeholderImageView.bottomAnchor, constant: 8),
            
            staticView.topAnchor.constraint(equalTo: view.topAnchor),
            staticView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            staticView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            staticView.heightAnchor.constraint(equalToConstant: 186),
            
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: staticView.bottomAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])}
    
    // MARK: - Selectors
    @objc private func createTrackerButtonDidTap() {
        let trackertypeChoiceVC = UINavigationController(rootViewController: TrackerTypeChoiceViewController())
        present(trackertypeChoiceVC, animated: true)
    }
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        let senderDate = sender.date
        currentDatePickerDateValue = myCalendar.startOfDay(for: senderDate)
        currentDayNumber = getCurrentDayNaumber(date: senderDate)
        updateVisibleCategories()
    }
    @objc func handleNotification(_ notification: Notification) {
        if let userData = notification.userInfo,
           let tracker = userData["Tracker"] as? Tracker,
           let categoryTitle = userData["Category"] as? String {
        
            let categoryCoreData = try? categoryStore.getCategory(withTitle: categoryTitle)
            guard let categoryCoreData = categoryCoreData else {
                return
            }
            trackerStore.createNewTracker(tracker: tracker, to: categoryCoreData)
            updateVisibleCategories()
        }
    }
    
    // MARK: - LogicFunctions
    private func updateVisibleCategories(forDayOfTheWeek dayNumber: Int) {
        visibleCategories = []
        allCategories.forEach { category in
            category.assignedTrackers.forEach { tracker in
                if tracker.isScheduledForDayNumber(currentDayNumber) {
                    visibleCategories = addNewCategory(toList: visibleCategories,
                                                       named: category.title,
                                                       assignedTrackers: [tracker])
                }
            }
        }
        collectionView.reloadData()
    }
    private func updateVisibleCategories() {
        guard
            let searchQuery = searchController.searchBar.text?.lowercased(),
            !searchQuery.isEmpty
        else {
            updateVisibleCategories(forDayOfTheWeek: currentDayNumber)
            return
        }
        
        var filteredCategories: [TrackerCategory] = []
        allCategories.forEach { category in
            let foundTrackers = category.assignedTrackers.filter {
                $0.title.lowercased().contains(searchQuery) &&
                $0.isScheduledForDayNumber(currentDayNumber)
            }
            if !foundTrackers.isEmpty {
                filteredCategories = addNewCategory(toList: filteredCategories, named: category.title, assignedTrackers: foundTrackers)
            }
        }
        visibleCategories = filteredCategories
        collectionView.reloadData()
    }
    private func addNewCategory(toList oldCategoriesList: [TrackerCategory],
                                named categoryName: String,
                                assignedTrackers trackers: [Tracker]?) -> [TrackerCategory] {
        /*
         If category already exists, then we don't need to create a new one. We have to check the list
         of trackers and update it(if it's empty). Otherwise, do nothing.
         */
        var newTrackersList: [Tracker] = []
        oldCategoriesList.forEach { existingCategory in
            if existingCategory.title == categoryName {
                newTrackersList = existingCategory.assignedTrackers
            }
        }
        if let trackers = trackers {
            newTrackersList.append(contentsOf: trackers)
        }
        
        /* Creates new category */
        let category = TrackerCategory(title: categoryName, assignedTrackers: newTrackersList)
        
        /*
         Creates new category list. First, adds all categories which name is not the same as new one.
         After all, adds new/update category
         */
        var newCategoriesList: [TrackerCategory] = []
        oldCategoriesList.forEach { existingCategory in
            if existingCategory.title != categoryName {
                newCategoriesList.append(existingCategory)
            }
        }
        newCategoriesList.append(category)
        return newCategoriesList
    }
    private func getRecordsForTracker(withId id: UUID) -> [TrackerRecord] {
        completedTrackers.filter { $0.id == id }
    }
    private func getCurrentDayNaumber(date: Date) -> Int {
        var weekDay = myCalendar.component(.weekday, from: date)
        weekDay -= 1
        
        if weekDay == 0 {
            weekDay = 7
        }
        return weekDay
    }
    private func isTrackerCompletedToday(withID id: UUID) -> Bool {
        getRecordsForTracker(withId: id).contains {
            myCalendar.isDate($0.date, equalTo: currentDatePickerDateValue, toGranularity: .day)
        }
    }
    private func isAllowedToBeCompletedToday() -> Bool {
        Date() >= currentDatePickerDateValue
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension TrackersListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 167, height: 148)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 9
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
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
            for: indexPath) as? TrackersCollectionViewSectionHeader else {
            return TrackersCollectionViewSectionHeader()
        }
        
        if visibleCategories.isEmpty {
            return view
        }
        view.titleLabel.text = visibleCategories[indexPath.section].title
        
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 10, left: 0, bottom: 16, right: 0)
    }
}

// MARK: - UICollectionViewDataSource
extension TrackersListViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if visibleCategories.isEmpty {
            showEmptyScreen()
            return 1
        }
        hideEmptyScreen()
        return visibleCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if !visibleCategories.isEmpty {
            hideEmptyScreen()
            return visibleCategories[section].assignedTrackers.count
        }
        showEmptyScreen()
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let tracker: Tracker = visibleCategories[indexPath.section].assignedTrackers[indexPath.row]
        
        guard var cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "TrackerCell",
            for: indexPath) as? TrackerCell
        else {
            var cell = TrackerCell()
            cell = setupTrackerCell(cell: cell, using: tracker)
            return TrackerCell()
        }
        
        cell = setupTrackerCell(cell: cell, using: tracker)
        return cell
    }
    
    private func setupTrackerCell(cell: TrackerCell, using tracker: Tracker) -> TrackerCell {
        if visibleCategories.isEmpty {
            return cell
        }
        
        cell.setupTrackerCell(descriptionName: tracker.title,
                              emoji: tracker.emoji,
                              descriptionViewBackgroundColor: tracker.color,
                              completionButtonTintColor: tracker.color,
                              trackerID: tracker.id,
                              counter: getRecordsForTracker(withId: tracker.id).count,
                              completionFlag: isTrackerCompletedToday(withID: tracker.id),
                              isCompletionAlowed: isAllowedToBeCompletedToday())
        
        cell.delegate = self
        return cell
    }
}

// MARK: - TrackerCellDelegate
extension TrackersListViewController: TrackerCellDelegate {
    func recordTrackerCompletionForSelectedDate(id: UUID) {
        var newRecordList = completedTrackers
        newRecordList.append(TrackerRecord(id: id, date: currentDatePickerDateValue))
        completedTrackers = newRecordList
        
        let tracker = try? trackerStore.getTracker(withID: id)
        guard let tracker = tracker else {
            return
        }
        recordStore.addNewRecord(forTrackerWithID: id, date: currentDatePickerDateValue, to: tracker)
    }
    func removeTrackerCompletionForSelectedDate(id: UUID) {
        let newRecordList = completedTrackers.filter {
            ($0.id != id) ||
            ($0.id == id &&
             !myCalendar.isDate($0.date, equalTo: currentDatePickerDateValue, toGranularity: .day))
        }
        completedTrackers = newRecordList
        try? recordStore.deleteRecord(forTrackerWithID: id, date: currentDatePickerDateValue)
    }
}

// MARK: - UISearchResultsUpdating
extension TrackersListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        updateVisibleCategories()
    }
}

// MARK: - UISearchControllerDelegate
extension TrackersListViewController: UISearchControllerDelegate {
    func willDismissSearchController(_ searchController: UISearchController) {
        updateVisibleCategories(forDayOfTheWeek: currentDayNumber)
        collectionView.reloadData()
    }
}

extension TrackersListViewController: TrackerStoreDelegate {
    func update() {
        allCategories = categoryStore.categories
        collectionView.reloadData()
    }
}
