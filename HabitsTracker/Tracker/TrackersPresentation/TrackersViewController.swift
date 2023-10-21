import UIKit

final class TrackersListViewController: UIViewController {
    private var pageTitleLable: UILabel = {
        let label = UILabel()
        label.text = "Trackers"
        label.font = UIFont.systemFont(ofSize: 34, weight: UIFont.Weight.bold)
        label.textColor = UIColor(named: "YP Black")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private var searchField: UISearchTextField = {
        let searchField = UISearchTextField()
        searchField.placeholder = "Search"
        searchField.backgroundColor = UIColor(red: 0.463, green: 0.463, blue: 0.502, alpha: 0.12)
        searchField.layer.cornerRadius = 10
        searchField.translatesAutoresizingMaskIntoConstraints = false
        return searchField
    }()
    private lazy var emptyPagePlaceholderImageView: UIImageView = {
        let imageView = UIImageView()
        let image = UIImage(named: "TrackersListPlaceholder")
        imageView.image = image
        imageView.isHidden = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    private lazy var emptyPagePlaceholderText: UILabel = {
        let label = UILabel()
        label.text = "What will we track?"
        label.textColor = UIColor(named: "YP Black")
        label.font = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.medium)
        label.textAlignment = .center
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
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
        datePicker.locale = Locale(identifier: "ru_Ru")
        datePicker.clipsToBounds = true
        datePicker.calendar.firstWeekday = 2
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
    }
    private func setUpCollectionView(){
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: "TrackerCell")
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
            
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.topAnchor.constraint(equalTo: searchField.bottomAnchor, constant: 10),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -83), // change to safe area?
        ])}
}

// MARK: - UICollectionViewDelegateFlowLayout
extension TrackersListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 167, height: 90)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 9
    }
    
}

// MARK: - UICollectionViewDataSource
extension TrackersListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let cellsAmout = 4
        if cellsAmout > 0 {
            return cellsAmout
        } else {
            setUpEmptyScreen()
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrackerCell", for: indexPath)
        cell.contentView.backgroundColor = .orange
        return cell
    }
}
