import UIKit

/*
 План:
  + Дописать функции делегата FetchRequestController
  - При инициализации TrackerViewController запрашивать данные из БД и обновлять видимые категории
  - При нажатии на кнопку создания трекера должна вызываться функция addNewTracker в TrackerStore
  + Дописать функцию делегата TrackerStore (пока она должна вызывать обновление коллекции,
    позже - BatchUpdates)
 */

final class TrackersListViewController: UIViewController {
    
    // MARK: - Stores
    let categoryStore = TrackerCategoryStore()
    let trackerStore = TrackerStore()
    
    // MARK: - LogicVariables
    let emojis: [String] = ["😀", "😎", "🚀", "⚽️", "🍕", "🎉", "🌟", "🎈", "🐶", "🍦", "🎸", "📚", "🚲", "🏖️", "🍩", "🎲", "🍭", "🖥️", "🌈", "🍔", "📱", "🛸", "🏕️", "🎨", "🌺", "🎁", "📷", "🍉", "🧩", "🎳"]

    private var allCategories: [TrackerCategory] = []
    private var allTrackers = [UUID: Tracker]()
    private var visibleCategories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    private var currentDatePickerDateValue: Date = Date()
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
//        categoryStore.setupCategoryDataBase()
        
        allCategories = categoryStore.categories
        visibleCategories = allCategories
//        updateVisibleCategories(forDayOfTheWeek: getCurrentDayNaumber(date: Date()))
        collectionView.reloadData()
        
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
        currentDatePickerDateValue = senderDate
        updateVisibleCategories()
    }
    @objc func handleNotification(_ notification: Notification) {
        if let userData = notification.userInfo,
           let tracker = userData["Tracker"] as? Tracker,
           let categoryTitle = userData["Category"] as? String {
            
            /*
            let newCategories = addNewCategory(toList: allCategories,
                                               named: categoryTitle,
                                               assignedTrackers: [tracker])
            allCategories = newCategories
             */
            
            let categoryCoreData = categoryStore.getCategoryWithTitle(title: categoryTitle)
            
            trackerStore.addNewTracker(tracker: tracker, category: categoryCoreData)
            
            allTrackers[tracker.id] = tracker
            updateVisibleCategories()
        }
    }
    
    // MARK: - LogicFunctions
    private func updateVisibleCategories(forDayOfTheWeek dayNumber: Int) {
        print(allCategories)
        visibleCategories = []
        allCategories.forEach { category in
            category.assignedTrackers.forEach { tracker in
                if isTrackerSetForCurrentDatePickerValue(withID: tracker.id) {
                    visibleCategories = addNewCategory(toList: visibleCategories,
                                                       named: category.title,
                                                       assignedTrackers: [tracker])
                }
            }
        }
        print("DEBUG PRINT! Current categories: ", visibleCategories)
        collectionView.reloadData()
    }
    private func updateVisibleCategories() {
        guard
            let searchQuery = searchController.searchBar.text?.lowercased(),
            !searchQuery.isEmpty
        else {
            updateVisibleCategories(forDayOfTheWeek: getCurrentDayNaumber(date: currentDatePickerDateValue))
            return
        }
        
        var filteredCategories: [TrackerCategory] = []
        allCategories.forEach { category in
            let foundTrackers = category.assignedTrackers.filter {
                $0.title.lowercased().contains(searchQuery) &&
                isTrackerSetForCurrentDatePickerValue(withID: $0.id)
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
    private func isTrackerSetForCurrentDatePickerValue(withID id: UUID) -> Bool {
        if let tracker = allTrackers[id],
           tracker.schedule.contains(getCurrentDayNaumber(date: currentDatePickerDateValue)) {
            
            print("DEBUG PRINT! Tracker found")
            return true
        }
        return false
    }
    private func isAllowedToBeCompletedToday() -> Bool {
        Date() >= currentDatePickerDateValue
    }
    
    func createTracker(title: String, categoryTitle: String, schedule: [Int]) {
        let tracker = Tracker(id: UUID(),
                              title: title,
                              color: UIColor().randomColor(),
                              emoji: emojis[Int.random(in: 0...emojis.count)],
                              schedule: schedule)
        
        let newCategories = addNewCategory(toList: allCategories,
                                           named: categoryTitle,
                                           assignedTrackers: [tracker])
        
        allTrackers[tracker.id] = tracker
        allCategories = newCategories
        print("DEBUG PRINT! All categories: ", allCategories)
        
        NotificationCenter.default.post(name: NSNotification.Name("CategoriesUpdateNotification"), object: nil)
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
    }
    func removeTrackerCompletionForSelectedDate(id: UUID) {
        let newRecordList = completedTrackers.filter {
            ($0.id != id) ||
            ($0.id == id &&
             !myCalendar.isDate($0.date, equalTo: currentDatePickerDateValue, toGranularity: .day))
        }
        completedTrackers = newRecordList
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
        updateVisibleCategories(forDayOfTheWeek: getCurrentDayNaumber(date: currentDatePickerDateValue))
        collectionView.reloadData()
    }
}

extension TrackersListViewController: TrackerStoreDelegate {
    func store(_ store: TrackerStore, didUpdate update: TrackerStoreUpdate) {
        allCategories = categoryStore.categories
        collectionView.reloadData()
    }
}
