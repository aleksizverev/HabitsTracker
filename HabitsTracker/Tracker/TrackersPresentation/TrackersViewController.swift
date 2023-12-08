import UIKit

final class TrackersListViewController: UIViewController {
    
    // MARK: - LogicVariables
   /* private var allCategories: [TrackerCategory] = [
        TrackerCategory(
            title: "Household",
            assignedTrackers: [
                Tracker(id: 1, title: "Pour the flowers", color: .magenta, emoji: "❤️", schedule: [1, 2, 3, 6, 7])
            ]
        ),
        TrackerCategory(
            title: "Happy things",
            assignedTrackers: [
                Tracker(id: 2, title: "The cat blocked the camera on call", color: .orange, emoji: "😻", schedule: [1, 3, 4, 5]),
                Tracker(id: 3, title: "Grandma sent postcard in Telegram", color: .red, emoji: "🌺",     schedule: [1, 3, 4, 5]),
                Tracker(id: 4, title: "Dates in April", color: .blue, emoji: "❤️",                      schedule: [2, 4, 5, 7])
            ]
        ),
        TrackerCategory(
            title: "Reading",
            assignedTrackers: [
                Tracker(id: 5, title: "Read some books", color: .brown, emoji: "📙", schedule: [1, 2, 3, 4, 5])
            ]
        ),
    ]
    private var allTrackers: [Tracker] = [
        Tracker(id: 1, title: "Pour the flowers", color: .magenta, emoji: "❤️", schedule: [1, 2, 3, 6, 7]),
        Tracker(id: 2, title: "The cat blocked the camera on call", color: .orange, emoji: "😻", schedule: [1, 3, 4, 5]),
        Tracker(id: 3, title: "Grandma sent postcard in Telegram", color: .red, emoji: "🌺",     schedule: [1, 3, 4, 5]),
        Tracker(id: 4, title: "Dates in April", color: .blue, emoji: "❤️",                      schedule: [2, 4, 5, 7]),
        Tracker(id: 5, title: "Read some books", color: .brown, emoji: "📙", schedule: [1, 2, 3, 4, 5])
    ]
    */
    
    let emojis: [String] = ["😀", "😎", "🚀", "⚽️", "🍕", "🎉", "🌟", "🎈", "🐶", "🍦", "🎸", "📚", "🚲", "🏖️", "🍩", "🎲", "🍭", "🖥️", "🌈", "🍔", "📱", "🛸", "🏕️", "🎨", "🌺", "🎁", "📷", "🍉", "🧩", "🎳"]

    private var allCategories: [TrackerCategory] = []
    private var allTrackers = [UUID: Tracker]()
    private var currentCategories: [TrackerCategory] = []
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
        
        setUpNavBar()
        setUpCollectionView()
        
        currentCategories = allCategories
        updateVisibleCategories(forDayOfTheWeek: getCurrentDayNaumber(date: Date()))
        
        addSubviews()
        applyConstraints()
    }
    
    private func setUpNavBar(){
        
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
    private func setUpCollectionView(){
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: "TrackerCell")
        collectionView.register(TrackerCellHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        collectionView.contentInset = UIEdgeInsets(top: 6, left: 16, bottom: 24, right: 16)
    }
    private func showEmptyScreen() {
        placeholderImageView.isHidden = false
        placeholderText.isHidden = false
    }
    private func hideEmptyScreen(){
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
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])}
    
    // MARK: - Selectors
    @objc
    private func createTrackerButtonDidTap(){
        let trackertypeChoiceVC = UINavigationController(rootViewController: TrackerTypeChoiceViewController())
        present(trackertypeChoiceVC, animated: true)
    }
    @objc
    private func datePickerValueChanged(_ sender: UIDatePicker){
        let senderDate = sender.date
        let weekDay = getCurrentDayNaumber(date: senderDate)
        currentDatePickerDateValue = senderDate
        updateVisibleCategories()
    }
    @objc
    func handleNotification(_ notification: Notification) {
        if let userData = notification.userInfo,
           let tracker = userData["Tracker"] as? Tracker {
            
            let newCategories = addNewCategory(toList: allCategories,
                                               named: "Important",
                                               assignedTrackers: [tracker])

            allTrackers[tracker.id] = tracker
            allCategories = newCategories
            updateVisibleCategories()
        }
    }
    
    // MARK: - LogicFunctions
    private func updateVisibleCategories(forDayOfTheWeek dayNumber: Int) {
        print(allCategories)
        currentCategories = []
        allCategories.forEach { category in
            category.assignedTrackers.forEach { tracker in
                if isTrackerSetForCurrentDatePickerValue(withID: tracker.id) {
                    currentCategories = addNewCategory(toList: currentCategories , named: category.title, assignedTrackers: [tracker])
                }
            }
        }
        print("DEBUG PRINT! Current categories: ", currentCategories)
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
        currentCategories = filteredCategories
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
        completedTrackers.filter {$0.id == id}
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
        /*,
        let tracker = allTrackers.filter {$0.id == id}  // remains empty here!!
        
        if !tracker.isEmpty {
            return tracker.schedule.contains(getCurrentDayNaumber(date: currentDatePickerDateValue))
        }
        return false
        */
    }
    private func isAllowedToBeCompletedToday() -> Bool {
        Date() >= currentDatePickerDateValue
    }
    
    func createTracker(title: String, categoryTitle: String, schedule: [Int]) {
        let tracker = Tracker(id: UUID(),
                              title: title,
                              color: randomColor(),
                              emoji: emojis[Int.random(in: 0...emojis.count)],
                              schedule: schedule)
        
        let newCategories = addNewCategory(toList: allCategories,
                                           named: categoryTitle,
                                           assignedTrackers: [tracker])
        
        allTrackers[tracker.id] = tracker
        allCategories = newCategories
        print("DEBUG PRINT! All categories: ", allCategories)
    
        NotificationCenter.default.post(name: NSNotification.Name("CategoriesUpdateNotification"), object: nil)
//        updateVisibleCategories()
    }
    
    // MARK: - Temporary functions
    private func randomColor() -> UIColor {
        // Generate random values for red, green, and blue components
        let red = CGFloat.random(in: 0...1)
        let green = CGFloat.random(in: 0...1)
        let blue = CGFloat.random(in: 0...1)
        
        // Create a new UIColor with the random components
        let color = UIColor(red: red, green: green, blue: blue, alpha: 1.0)
        return color
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
        
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: id, for: indexPath) as! TrackerCellHeader // TODO: remove!
        //        guard let categories = currentCategories else { return view }
        
        if currentCategories.isEmpty{ return view }
        view.titleLabel.text = currentCategories[indexPath.section].title
        
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
        if currentCategories.isEmpty {
            showEmptyScreen()
            return 1
        }
        hideEmptyScreen()
        return currentCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if !currentCategories.isEmpty{
            hideEmptyScreen()
            return currentCategories[section].assignedTrackers.count
        }
        showEmptyScreen()
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrackerCell", for: indexPath) as! TrackerCell // TODO: change!!
        
        if currentCategories.isEmpty { return cell}
        
        let tracker: Tracker = currentCategories[indexPath.section].assignedTrackers[indexPath.row]
        
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
