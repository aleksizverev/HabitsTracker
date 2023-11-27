import UIKit

final class TrackersListViewController: UIViewController {
    private var allCategories: [TrackerCategory]? = [
        TrackerCategory(
            title: "Household",
            assignedTrackers: [
                Tracker(id: 1, title: "Pour the flowers", color: .magenta, emoji: "❤️", schedule: [1, 2, 5])
            ]
        ),
        TrackerCategory(
            title: "Happy things",
            assignedTrackers: [
                Tracker(id: 2, title: "The cat blocked the camera on call", color: .orange, emoji: "😻", schedule: [2, 3, 5]),
                Tracker(id: 3, title: "Grandma sent postcard in Telegram", color: .red, emoji: "🌺",     schedule: [4, 5, 7]),
                Tracker(id: 4, title: "Dates in April", color: .blue, emoji: "❤️",                      schedule: [6, 7, 1])
            ]
        )
    ]
    private var currentCategories: [TrackerCategory]?
    private var completedTrackers: [TrackerRecord]?
    private var pageTitleLable: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Trackers"
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.textColor = UIColor(named: "YP Black")
        return label
    }()
    private var searchBar: UISearchBar = {
        let bar = UISearchBar()
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.placeholder = "Search"
        bar.backgroundColor = .white
        bar.searchBarStyle = .minimal
        return bar
    }()
    private lazy var emptyPagePlaceholderImageView: UIImageView = {
        let imageView = UIImageView()
        let image = UIImage(named: "TrackersListPlaceholder")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = image
        imageView.isHidden = true
        return imageView
    }()
    private lazy var emptyPagePlaceholderText: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "What will we track?"
        label.textColor = UIColor(named: "YP Black")
        label.font = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.medium)
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        setUpNavBar()
        setUpCollectionView()
        
        loadCategoriesForToday()
        
        addSubviews()
        applyConstraints()
    }
    
    @objc
    private func createTrackerButtonDidTap(){
        let trackertypeChoiceVC = UINavigationController(rootViewController: TrackerTypeChoiceViewController())
        present(trackertypeChoiceVC, animated: true)
    }
    
    
    private func setUpNavBar(){
        let image = UIImage(named: "AddTrackerButton")
        let button = UIBarButtonItem(image: image,
                                     style: .plain,
                                     target: self,
                                     action: #selector(Self.createTrackerButtonDidTap))
        button.tintColor = UIColor(named: "YP Black")
        self.navigationItem.leftBarButtonItem = button
        self.navigationItem.leftBarButtonItem?.imageInsets = UIEdgeInsets(top: 0, left: -12, bottom: 0, right: 0)
        
        let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.locale = Locale(identifier: "fi")
        datePicker.clipsToBounds = true
        datePicker.calendar.firstWeekday = 2
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
    }
    private func setUpSearchBar(){
        searchBar.delegate = self
    }
    private func setUpCollectionView(){
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: "TrackerCell")
        collectionView.register(TrackerCellHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        collectionView.contentInset = UIEdgeInsets(top: 24, left: 16, bottom: 24, right: 16)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
    }
    private func setUpEmptyScreen(){
        emptyPagePlaceholderImageView.isHidden = false
        emptyPagePlaceholderText.isHidden = false
    }
    private func addSubviews() {
        view.addSubview(pageTitleLable)
        view.addSubview(searchBar)
        view.addSubview(collectionView)
        view.addSubview(emptyPagePlaceholderImageView)
        view.addSubview(emptyPagePlaceholderText)
    }
    private func applyConstraints() {
        NSLayoutConstraint.activate([
            
            pageTitleLable.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            pageTitleLable.topAnchor.constraint(equalTo: view.topAnchor, constant: 88),
            
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            searchBar.topAnchor.constraint(equalTo: pageTitleLable.bottomAnchor),
            
            emptyPagePlaceholderImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyPagePlaceholderImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            emptyPagePlaceholderText.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            emptyPagePlaceholderText.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            emptyPagePlaceholderText.topAnchor.constraint(equalTo: emptyPagePlaceholderImageView.bottomAnchor, constant: 8),
            
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])}
    private func getCurrentDayNaumber(date: Date) -> Int {
        let myCalendar = Calendar(identifier: .gregorian)
        let weekDay = myCalendar.component(.weekday, from: date)
        return weekDay
    }
    
    @objc
    private func datePickerValueChanged(_ sender: UIDatePicker){
        let senderDate = sender.date
        let weekDay = getCurrentDayNaumber(date: senderDate)
        updateCurrentCategories(forDayOfTheWeek: weekDay)
        performAnimatedCollectionUpdates()
    }
    
    private func loadCategoriesForToday() {
        updateCurrentCategories(forDayOfTheWeek: getCurrentDayNaumber(date: Date()))
        collectionView.reloadData()
    }
    
    private func updateCurrentCategories(forDayOfTheWeek dayNumber: Int){
        currentCategories = []
        allCategories?.forEach { category in
            category.assignedTrackers.forEach { tracker in
                if let schedule = tracker.schedule,
                   schedule.contains(dayNumber){
                    currentCategories = addNewCategory(toList: currentCategories ?? [], named: category.title, assignedTrackers: [tracker])
                }
            }
        }
    }
    
    private func performAnimatedCollectionUpdates() {
        guard let currentCategories = currentCategories else {
            collectionView.reloadData()
            return
        }
        collectionView.reloadData()
        //нужно брать данные allCategories но индексы из currentCategories?
//        collectionView.performBatchUpdates {
//            var indexes: [IndexPath] = []
//            currentCategories.indices.forEach { catNum in
//                currentCategories[catNum].assignedTrackers.indices.forEach { trackerNum in
//                    indexes.append(IndexPath(item: trackerNum, section: catNum))
//                }
//            }
//            collectionView.insertItems(at: indexes)
//        }
    }

    private func addNewCategory(toList oldCategoriesList: [TrackerCategory],
                                named categoryName: String,
                                assignedTrackers trackers: [Tracker]?) -> [TrackerCategory] {
        /*
         If category already exists, then we don't need to create a new one. We have to check the list
         of trackers and update it(if it's empty). Otherwise, do nothing. It's important no to forget
         to do Batch Updates after creation of new categories list.
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
         After all adds new/update category
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

    func printText(text: String) {
        print("Editing began")
    }
}

// MARK: - UISearchBarDelegatesdfdskljkl
extension TrackersListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        printText(text: searchText) // no reaction!
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {

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
        
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: id, for: indexPath) as! TrackerCellHeader
        guard let categories = currentCategories else { return view }
        view.titleLabel.text = categories[indexPath.section].title

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
        guard let categories = currentCategories else { return 1 }
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if let categories = currentCategories {
            if !categories.isEmpty{
                return categories[section].assignedTrackers.count
            }
        }
        setUpEmptyScreen()
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let section = indexPath.section
        let row = indexPath.row
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrackerCell", for: indexPath) as! TrackerCell // TODO: change!!
        
        guard let categories = currentCategories else { return cell }
        
        cell.setHabitDescriptionName(name: categories[section].assignedTrackers[row].title)
        cell.setHabitEmoji(emoji: categories[section].assignedTrackers[row].emoji)
        cell.setCellDescriptionViewBackgroundColor(color: categories[section].assignedTrackers[row].color)
        cell.setCompletionButtonTintColor(color: categories[section].assignedTrackers[row].color)
        
        return cell
    }
}
