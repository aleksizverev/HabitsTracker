import UIKit

final class TrackersListViewController: UIViewController {
    
    // MARK: - Stores
    let categoryStore = TrackerCategoryStore()
    
    let trackerStore = TrackerStore()
    
    let recordStore = TrackerRecordStore()
    
    private let myCalendar = Calendar(identifier: .gregorian)
    
    // MARK: - LogicVariables
    private let analyticsService = AnalyticsService()
    
    private var allCategories: [TrackerCategory] = []
    
    private var visibleCategories: [TrackerCategory] = []
    
    private var pinnedTrackers: [Tracker] = []
    
    private var chosenFilter: String?
    
    private var completedTrackers: [TrackerRecord] = []
    
    private lazy var currentDatePickerDateValue: Date = myCalendar.startOfDay(for: Date())
    
    private lazy var currentDayNumber: Int = getCurrentDayNaumber(date: currentDatePickerDateValue)
    
    // MARK: - UIVariables
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    private var searchController = UISearchController()
    
    private var staticView: UIView = {
        let staticView = UIView()
        staticView.translatesAutoresizingMaskIntoConstraints = false
        return staticView
    }()
    
    private var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.locale = Locale(identifier: "fi")
        datePicker.clipsToBounds = true
        datePicker.calendar.firstWeekday = 2
        datePicker.layer.cornerRadius = 8
        return datePicker
    }()
    
    private var colors = Colors()
    
    private lazy var placeholderImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage()
        imageView.isHidden = true
        return imageView
    }()
    
    private lazy var placeholderText: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor(named: "YP Black")
        label.font = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.medium)
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    private lazy var filtersButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Filters", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(named: "YP Blue")
        button.layer.cornerRadius = 16
        button.titleLabel?.font = .systemFont(ofSize: 17)
        button.addTarget(self, action: #selector(didTapFiltersButton), for: .touchUpInside)
        return button
    }()
    
    // MARK: - SetupFunctions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleNotification(_:)),
                                               name: NSNotification.Name("CategoriesUpdateNotification"),
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleEditNotification(_:)),
                                               name: NSNotification.Name("TrackerEditNotification"),
                                               object: nil)
        
        self.view.backgroundColor = colors.viewBackgroundColor
        
        trackerStore.delegate = self
        
        setupNavBar()
        setupCollectionView()
        
        completedTrackers = recordStore.records
        allCategories = categoryStore.categories
        pinnedTrackers = trackerStore.getPinnedTrackers()
        visibleCategories = allCategories
        updateVisibleCategories()
        
        addSubviews()
        applyConstraints()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        analyticsService.report(event: "close", params: ["screen": "Main"])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        analyticsService.report(event: "open", params: ["screen": "Main"])
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
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        datePicker.addTarget(self,
                             action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        
        let image = UIImage(named: "AddTrackerButton")
        let plusButton = UIBarButtonItem(image: image,
                                         style: .plain,
                                         target: self,
                                         action: #selector(Self.createTrackerButtonDidTap))
        plusButton.tintColor = colors.addTrackerButtonColor
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
    
    private func presentDeleteAlertController(forTrackerWithID id: UUID) {
        let alert = UIAlertController(
            title: "Are you sure?",
            message: "",
            preferredStyle: .actionSheet
        )
        alert.addAction(UIAlertAction(
            title: "Delete",
            style: .destructive,
            handler: { [weak self] _ in
                try? self?.trackerStore.deleteTracker(withID: id)
                self?.updateVisibleCategories()
                alert.dismiss(animated: true)
            }))
        alert.addAction(UIAlertAction(
            title: "Cancel",
            style: .cancel,
            handler: { _ in
                alert.dismiss(animated: true)
            }))
        present(alert, animated: true, completion: nil)
    }
    
    private func showEmptyScreen() {
        placeholderImageView.image = UIImage(named: "TrackersListPlaceholder")
        placeholderText.text = "What shall we track?"
        placeholderImageView.isHidden = false
        placeholderText.isHidden = false
    }
    
    private func hideEmptyScreen() {
        placeholderImageView.isHidden = true
        placeholderText.isHidden = true
    }
    
    private func showNoSearchResultsScreen() {
        placeholderImageView.image = UIImage(named: "NoSearchResults")
        placeholderText.text = "Nothing found"
        placeholderImageView.isHidden = false
        placeholderText.isHidden = false
    }
    
    private func hideNoSearchResultsScreen() {
        placeholderImageView.isHidden = true
        placeholderText.isHidden = true
    }
    
    private func showFiltersButton() {
        filtersButton.isHidden = false
    }
    
    private func hideFiltersButton() {
        filtersButton.isHidden = true
    }
    
    private func addSubviews() {
        view.addSubview(staticView)
        view.addSubview(collectionView)
        view.addSubview(placeholderImageView)
        view.addSubview(placeholderText)
        view.addSubview(filtersButton)
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
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            filtersButton.heightAnchor.constraint(equalToConstant: 50),
            filtersButton.widthAnchor.constraint(equalToConstant: 114),
            filtersButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filtersButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -15)
        ])}
    
    // MARK: - Selectors
    @objc private func createTrackerButtonDidTap() {
        analyticsService.report(event: "click", params: ["screen": "Main", "item": "add_track"])
        let trackertypeChoiceVC = UINavigationController(rootViewController: TrackerTypeChoiceViewController())
        present(trackertypeChoiceVC, animated: true)
    }
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        let senderDate = sender.date
        changeDatePickerValue(forDate: senderDate)
    }
    
    @objc private func didTapFiltersButton() {
        analyticsService.report(event: "click", params: ["screen": "Main", "item": "filter"])
        let filtersVC = FiltersViewController()
        filtersVC.delegate = self
        
        if let chosenFilter = chosenFilter {
            filtersVC.setChosenFilter(withTitle: chosenFilter)
        }
        
        present(UINavigationController(rootViewController: filtersVC), animated: true)
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
    
    @objc func handleEditNotification(_ notification: Notification) {
        if let userData = notification.userInfo,
           let tracker = userData["Tracker"] as? Tracker,
           let categoryTitle = userData["Category"] as? String {
            
            let categoryCoreData = try? categoryStore.getCategory(withTitle: categoryTitle)
            guard let categoryCoreData = categoryCoreData else {
                return
            }
            
            try? trackerStore.updateTracker(withID: tracker.id, usingDataFrom: tracker, inCategory: categoryCoreData)
            
            updateVisibleCategories()
        }
    }
    
    // MARK: - LogicFunctions
    private func changeDatePickerValue(forDate date: Date) {
        if chosenFilter == "Trackers for today" {
            chosenFilter = "All trackers"
        }
        
        currentDatePickerDateValue = myCalendar.startOfDay(for: date)
        currentDayNumber = getCurrentDayNaumber(date: date)
        updateVisibleCategories()
        applyChosenFilter()
    }
    
    private func updateVisibleCategories(forDayOfTheWeek dayNumber: Int) {
        visibleCategories = []
        allCategories.forEach { category in
            category.assignedTrackers.forEach { tracker in
                if tracker.isScheduledForDayNumber(currentDayNumber) && !isTrackerPinned(withID: tracker.id) {
                    visibleCategories = addNewCategory(toList: visibleCategories,
                                                       named: category.title,
                                                       assignedTrackers: [tracker])
                }
            }
        }
        updatePinnedCategories()
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
        
        var foundCategories: [TrackerCategory] = []
        allCategories.forEach { category in
            let foundTrackers = category.assignedTrackers.filter {
                $0.title.lowercased().contains(searchQuery) &&
                ($0.isScheduledForDayNumber(currentDayNumber) || isTrackerPinned(withID: $0.id))
            }
            if !foundTrackers.isEmpty {
                foundCategories = addNewCategory(toList: foundCategories, named: category.title, assignedTrackers: foundTrackers)
            }
        }
        visibleCategories = foundCategories
        collectionView.reloadData()
    }
    
    private func updatePinnedCategories() {
        pinnedTrackers = trackerStore.getPinnedTrackers()
        if !pinnedTrackers.isEmpty {
            let pinnedCategory = TrackerCategory(title: "Pinned trackers", assignedTrackers: pinnedTrackers)
            visibleCategories.insert(pinnedCategory, at: 0)
        }
        
        if pinnedTrackers.isEmpty {
            visibleCategories = visibleCategories.filter { category in
                category.title != "Pinned trackers"
            }
        }
        collectionView.reloadData()
    }
    
    private func addNewCategory(toList oldCategoriesList: [TrackerCategory],
                                named categoryName: String,
                                assignedTrackers trackers: [Tracker]?) -> [TrackerCategory] {
        var newTrackersList: [Tracker] = []
        oldCategoriesList.forEach { existingCategory in
            if existingCategory.title == categoryName {
                newTrackersList = existingCategory.assignedTrackers
            }
        }
        if let trackers = trackers {
            newTrackersList.append(contentsOf: trackers)
        }
        
        let category = TrackerCategory(title: categoryName, assignedTrackers: newTrackersList)
        
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
    
    private func isTrackerPinned(withID id: UUID) -> Bool {
        guard let tracker = try? trackerStore.getTracker(withID: id) else {
            return false
        }
        return tracker.isPinned
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        0
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
        view.titleLabel.textColor = colors.collectionViewTextColor
        
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
        UIEdgeInsets(top: 10, left: 0, bottom: 8, right: 0)
    }
}

// MARK: - UICollectionViewDataSource
extension TrackersListViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if !visibleCategories.isEmpty {
            hideNoSearchResultsScreen()
            hideEmptyScreen()
            return visibleCategories.count
        }
        
        if let searchQuery = searchController.searchBar.text?.lowercased(),
           !searchQuery.isEmpty {
            showNoSearchResultsScreen()
            return 0
        }
        
        if chosenFilter != "All trackers" {
            showNoSearchResultsScreen()
            return 0
        }
        
        showEmptyScreen()
        hideFiltersButton()
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if !visibleCategories.isEmpty {
            hideNoSearchResultsScreen()
            hideEmptyScreen()
            showFiltersButton()
            return visibleCategories[section].assignedTrackers.count
        }
        
        if let searchQuery = searchController.searchBar.text?.lowercased(),
           !searchQuery.isEmpty {
            showNoSearchResultsScreen()
            return 0
        }
        showEmptyScreen()
        hideFiltersButton()
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
                              isCompletionAlowed: isAllowedToBeCompletedToday(),
                              isPinnedState: isTrackerPinned(withID: tracker.id)
        )
        
        cell.delegate = self
        return cell
    }
}

// MARK: - UISearchResultsUpdating
extension TrackersListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        applyChosenFilter()
    }
}

// MARK: - UISearchControllerDelegate
extension TrackersListViewController: UISearchControllerDelegate {
    func willDismissSearchController(_ searchController: UISearchController) {
        applyChosenFilter()
        print(visibleCategories)
    }
}

// MARK: - TrackerCellDelegate
extension TrackersListViewController: TrackerCellDelegate {
    func changePinState(id: UUID) {
        try? trackerStore.changePinStateForTracker(withID: id)
        updateVisibleCategories()
    }
    
    func editTracker(id: UUID, counter: Int) {
        analyticsService.report(event: "click", params: ["screen": "Main", "item": "edit"])
        guard let tracker = try? trackerStore.tracker(from: trackerStore.getTracker(withID: id)) else {
            return
        }
        
        guard let trackerCategory = try? trackerStore.getTrackerCategory(withID: id) else {
            return
        }
        
        present(UINavigationController(rootViewController: TrackerEditingViewController(
            id: id,
            title: tracker.title,
            category: trackerCategory,
            schedule: tracker.schedule,
            emoji: tracker.emoji,
            color: tracker.color,
            counter: counter
        )),
                animated: true)
    }
    
    func deleteTracker(id: UUID) {
        analyticsService.report(event: "click", params: ["screen": "Main", "item": "delete"])
        presentDeleteAlertController(forTrackerWithID: id)
    }
    
    func recordTrackerCompletionForSelectedDate(id: UUID) {
        analyticsService.report(event: "click", params: ["screen": "Main", "item": "track"])
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

// MARK: - TrackerStoreDelegate
extension TrackersListViewController: TrackerStoreDelegate {
    func update() {
        allCategories = categoryStore.categories
        collectionView.reloadData()
    }
}

extension TrackersListViewController: FilterViewControllerDelegate {
    private func filterCategoriesByCompletion() {
        updateVisibleCategories()
        visibleCategories = visibleCategories.map { category in
            let filteredTerackers = category.assignedTrackers.filter { tracker in
                isTrackerCompletedToday(withID: tracker.id)
            }
            return TrackerCategory(title: category.title, assignedTrackers: filteredTerackers)
        }
        
        visibleCategories = visibleCategories.filter { category in
            !category.assignedTrackers.isEmpty
        }
        collectionView.reloadData()
    }
    
    private func filterCategoriesByUncompletion() {
        updateVisibleCategories()
        visibleCategories = visibleCategories.map { category in
            let filteredTerackers = category.assignedTrackers.filter { tracker in
                !isTrackerCompletedToday(withID: tracker.id)
            }
            return TrackerCategory(title: category.title, assignedTrackers: filteredTerackers)
        }
        
        visibleCategories = visibleCategories.filter { category in
            !category.assignedTrackers.isEmpty
        }
        collectionView.reloadData()
    }
    
    private func applyChosenFilter() {
        switch chosenFilter {
        case "All Trackers":
            updateVisibleCategories()
        case "Trackers for today":
            datePicker.setDate(Date(), animated: true)
            changeDatePickerValue(forDate: Date())
        case "Completed":
            filterCategoriesByCompletion()
        case "Uncompleted":
            filterCategoriesByUncompletion()
        default:
            updateVisibleCategories()
        }
    }
    
    func applyFilter(filter: String?) {
        chosenFilter = filter
        applyChosenFilter()
    }
}
