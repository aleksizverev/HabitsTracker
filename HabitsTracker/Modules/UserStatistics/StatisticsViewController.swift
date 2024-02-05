import UIKit

final class StatisticsViewController: UIViewController {
    
    let trackerRecordStore = TrackerRecordStore()
    
    private var cellView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var counterLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.textAlignment = .natural
        return label
    }()
    
    private var statisticsTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .natural
        label.text = "Trackers completed"
        return label
    }()
    
    private lazy var placeholderImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "NoStatistics")
        imageView.isHidden = true
        return imageView
    }()
    
    private lazy var placeholderText: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor(named: "YP Black")
        label.font = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.medium)
        label.text = "Nothing to analyse"
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.systemBackground
        
        navigationItem.title = "Statistics"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        trackerRecordStore.delegate = self
        
        setupStatisticCard()
        setupEmptyScreen()
        
        updateStatisticsCard(counter: trackerRecordStore.getRecordsAmount())
    }
    
    private func setupStatisticCard() {
        cellView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width - 32, height: 90))
        cellView.translatesAutoresizingMaskIntoConstraints = false
        cellView.backgroundColor = .clear
        cellView.layer.cornerRadius = 16
        cellView.layer.masksToBounds = true
        cellView.clipsToBounds = true
    
        view.addSubview(cellView)
        NSLayoutConstraint.activate([
            cellView.topAnchor.constraint(equalTo: view.topAnchor, constant: 208),
            cellView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cellView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            cellView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            cellView.heightAnchor.constraint(equalToConstant: 90)
        ])
        addGradientBorder(to: cellView)
        
        cellView.addSubview(counterLabel)
        NSLayoutConstraint.activate([
            counterLabel.leadingAnchor.constraint(equalTo: cellView.leadingAnchor, constant: 12),
            counterLabel.trailingAnchor.constraint(equalTo: cellView.trailingAnchor, constant: -12),
            counterLabel.topAnchor.constraint(equalTo: cellView.topAnchor, constant: 12),
            counterLabel.heightAnchor.constraint(equalToConstant: 41)
        ])
        
        cellView.addSubview(statisticsTitleLabel)
        NSLayoutConstraint.activate([
            statisticsTitleLabel.leadingAnchor.constraint(equalTo: cellView.leadingAnchor, constant: 12),
            statisticsTitleLabel.trailingAnchor.constraint(equalTo: cellView.trailingAnchor, constant: -12),
            statisticsTitleLabel.topAnchor.constraint(greaterThanOrEqualTo: counterLabel.bottomAnchor, constant: 7),
            statisticsTitleLabel.heightAnchor.constraint(equalToConstant: 18)
        ])
    }
    
    private func setupEmptyScreen() {
        view.addSubview(placeholderImageView)
        view.addSubview(placeholderText)
        
        NSLayoutConstraint.activate([
            placeholderImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            placeholderText.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            placeholderText.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            placeholderText.topAnchor.constraint(equalTo: placeholderImageView.bottomAnchor, constant: 8)
        ])
    }
    
    private func updateStatisticsCard(counter: Int) {
        if counter != 0 {
            hideEmptyScreen()
            counterLabel.text = String(counter)
            statisticsTitleLabel.text = counter == 1
            ? "Tracker completed"
            : "Trackers completed"
            return
        }
        showEmptyScreen()
    }
    
    private func addGradientBorder(to view: UIView) {
        let gradient = CAGradientLayer()
        gradient.frame = CGRect(origin: CGPointZero, size: view.frame.size)
        gradient.colors = [UIColor(named: "YP Gradient Red")!.cgColor,
                           UIColor(named: "YP Gradient Green")!.cgColor,
                           UIColor(named: "YP Gradient Blue")!.cgColor]
        
        let shape = CAShapeLayer()
        shape.lineWidth = 2
        shape.path = UIBezierPath(roundedRect: view.bounds,
                                  cornerRadius: view.layer.cornerRadius).cgPath
        shape.strokeColor = UIColor.black.cgColor
        shape.fillColor = UIColor.clear.cgColor
        gradient.mask = shape
        
        view.layer.addSublayer(gradient)
    }
    
    private func showEmptyScreen() {
        placeholderImageView.isHidden = false
        placeholderText.isHidden = false
        cellView.isHidden = true
        statisticsTitleLabel.isHidden = true
        counterLabel.isHidden = true
    }
    
    private func hideEmptyScreen() {
        placeholderImageView.isHidden = true
        placeholderText.isHidden = true
        cellView.isHidden = false
        statisticsTitleLabel.isHidden = false
        counterLabel.isHidden = false
    }
}

extension StatisticsViewController: TrackerRecordStoreDelegate {
    func updateCompletionStatistics(completedTrackersCnt: Int) {
        updateStatisticsCard(counter: completedTrackersCnt)
    }
}
