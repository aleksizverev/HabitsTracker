import UIKit

final class TrackersListViewController: UIViewController {
    private var categories: [TrackerCategory]? = [
        TrackerCategory(
            title: "Household",
            assignedTrackers: [
                Tracker(id: 1, title: "Pour the flowers", color: .magenta, emoji: "❤️", schedule: nil)
            ]
        ),
        TrackerCategory(
            title: "Happy things",
            assignedTrackers: [
                Tracker(id: 2, title: "The cat blocked the camera on call", color: .orange, emoji: "😻", schedule: nil),
                Tracker(id: 3, title: "Grandma sent postcard in Telegram", color: .red, emoji: "🌺", schedule: nil),
                Tracker(id: 4, title: "Dates in April", color: .blue, emoji: "❤️", schedule: nil)
            ]
        )
    ]
    private var completedTrackers: [TrackerRecord]?
    private var pageTitleLable: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Trackers"
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.textColor = UIColor(named: "YP Black")
        return label
    }()
    private var searchField: UISearchTextField = {
        let searchField = UISearchTextField()
        searchField.translatesAutoresizingMaskIntoConstraints = false
        searchField.placeholder = "Search"
        searchField.backgroundColor = UIColor(named: "YP Background")
        searchField.layer.cornerRadius = 10
        return searchField
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
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
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
        view.addSubview(searchField)
        view.addSubview(collectionView)
        view.addSubview(emptyPagePlaceholderImageView)
        view.addSubview(emptyPagePlaceholderText)
    }
    private func applyConstraints() {
        NSLayoutConstraint.activate([
            
            pageTitleLable.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            pageTitleLable.topAnchor.constraint(equalTo: view.topAnchor, constant: 88),
            
            searchField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchField.topAnchor.constraint(equalTo: pageTitleLable.bottomAnchor, constant: 7),
            
            emptyPagePlaceholderImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyPagePlaceholderImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            emptyPagePlaceholderText.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            emptyPagePlaceholderText.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            emptyPagePlaceholderText.topAnchor.constraint(equalTo: emptyPagePlaceholderImageView.bottomAnchor, constant: 8),
            
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: searchField.bottomAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -83), // TODO: change to safe area?
        ])}
    private func createNewCategory(named categoryName: String, assignedTrackers: [Tracker]?) {
        let category = TrackerCategory(title: categoryName, assignedTrackers: [])
        var newCategories = categories
        newCategories?.append(category)
        categories = newCategories
    }
    private func addNewTracker(tracker: Tracker, toCategory category: TrackerCategory) {
        guard let categories = categories else {
            return
        }
        
        categories.forEach { existingCategory in
            if existingCategory.title == category.title {
                var trackersList = existingCategory.assignedTrackers
                trackersList.append(tracker)
                createNewCategory(named: category.title, assignedTrackers: trackersList)
            } else {
                createNewCategory(named: category.title, assignedTrackers: [tracker])
            }
        }
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
        guard let categories = categories else { return view }
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
        guard let categories = categories else { return 1 }
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if let categories = categories {
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
        
        guard let categories = categories else { return cell }
        
        cell.setHabitDescriptionName(name: categories[section].assignedTrackers[row].title)
        cell.setHabitEmoji(emoji: categories[section].assignedTrackers[row].emoji)
        cell.setCellDescriptionViewBackgroundColor(color: categories[section].assignedTrackers[row].color)
        cell.setCompletionButtonTintColor(color: categories[section].assignedTrackers[row].color)
        
        return cell
    }
}
