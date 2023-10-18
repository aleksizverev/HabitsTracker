import UIKit

final class TrackersListViewController: UIViewController {
    private var addTrackerButton: UIBarButtonItem = {
        let image = UIImage(named: "AddTrackerButton")
        let button = UIBarButtonItem(image: image, style: .plain, target: nil, action: nil)
        button.tintColor = UIColor(named: "YP Black")
        return button
    }()
    private var datePicker: UIBarButtonItem = {
        let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.locale = Locale(identifier: "fi")
        return UIBarButtonItem(customView: datePicker)
    }()
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
    private var emptyPagePlaceholderImageView: UIImageView = {
        let imageView = UIImageView()
        let image = UIImage(named: "TrackersListPlaceholder")
        imageView.image = image
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    private var emptyPagePlaceholderText: UILabel = {
        let label = UILabel()
        label.text = "What will we track?"
        label.textColor = UIColor(named: "YP Black")
        label.font = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
    
        setUpNavBar()
        addSubviews()
        applyConstraints()
    }
    
    private func setUpNavBar(){
        self.navigationItem.leftBarButtonItem = addTrackerButton
        self.navigationItem.leftBarButtonItem?.imageInsets = UIEdgeInsets(top: 0, left: -12, bottom: 0, right: 0)
        self.navigationItem.rightBarButtonItem = datePicker
    }
    private func addSubviews() {
        view.addSubview(pageTitleLable)
        view.addSubview(searchField)
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
        emptyPagePlaceholderText.topAnchor.constraint(equalTo: emptyPagePlaceholderImageView.bottomAnchor, constant: 8)

    ])}
}

