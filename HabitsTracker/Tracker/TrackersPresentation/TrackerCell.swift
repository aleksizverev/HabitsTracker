import UIKit

protocol TrackerCellDelegate: AnyObject {
    func recordTrackerCompletionForSelectedDate(id: UInt)
    func removeTrackerCompletionForSelectedDate(id: UInt)
}

final class TrackerCell: UICollectionViewCell {
    weak var delegate: TrackerCellDelegate?
    
    private var completionCounter: Int = 0 {
        didSet {
            updateHabitStatisticsLabelDays()
        }
    }
    private var isCompletedToday: Bool = false {
        didSet {
            updateCompletionButtonState()
        }
    }
    private var trackerId: UInt = 0
    private var cellDescriptionView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        
        return view
    }()
    private var habitDescriptionLabel: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .white
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        var paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.26
        label.attributedText = NSMutableAttributedString(string: "Default text", attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
        
        return label
    }()
    private var emojiLabel: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    private var statisticsLabel: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor(named: "YP Black")
        label.text = "0 days"
        return label
    }()
    private var completionButton: UIButton = {
        let image = UIImage(systemName: "plus")
        let button = UIButton.systemButton(
            with: image!,
            target: self,
            action: #selector(Self.completionButtonDidTap))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 20
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubviews()
        applyConstraints()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    private func completionButtonDidTap() {
        if !isCompletedToday {
            completionCounter += 1
            isCompletedToday = true
            delegate?.recordTrackerCompletionForSelectedDate(id: trackerId)
        } else {
            completionCounter -= 1
            isCompletedToday = false
            delegate?.removeTrackerCompletionForSelectedDate(id: trackerId)
        }
    }
    private func addSubviews() {
        contentView.addSubview(cellDescriptionView)
        contentView.addSubview(statisticsLabel)
        contentView.addSubview(completionButton)
        
        cellDescriptionView.addSubview(habitDescriptionLabel)
        cellDescriptionView.addSubview(emojiLabel)
    }
    private func applyConstraints() {
        NSLayoutConstraint.activate([
            
            cellDescriptionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cellDescriptionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cellDescriptionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cellDescriptionView.heightAnchor.constraint(equalToConstant: 90),
            
            emojiLabel.leadingAnchor.constraint(equalTo: cellDescriptionView.leadingAnchor, constant: 12),
            emojiLabel.topAnchor.constraint(equalTo: cellDescriptionView.topAnchor, constant: 12),
            
            habitDescriptionLabel.leadingAnchor.constraint(equalTo: cellDescriptionView.leadingAnchor, constant: 12),
            habitDescriptionLabel.trailingAnchor.constraint(equalTo: cellDescriptionView.trailingAnchor, constant: -12),
            habitDescriptionLabel.topAnchor.constraint(greaterThanOrEqualTo: emojiLabel.bottomAnchor, constant: 8),
            habitDescriptionLabel.bottomAnchor.constraint(equalTo: cellDescriptionView.bottomAnchor, constant: -12),
            
            
            statisticsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            statisticsLabel.topAnchor.constraint(equalTo: cellDescriptionView.bottomAnchor, constant: 16),
            
            completionButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            completionButton.centerYAnchor.constraint(equalTo: statisticsLabel.centerYAnchor),
        ])
    }
    private func updateHabitStatisticsLabelDays(){
        statisticsLabel.text = completionCounter == 1
        ? String(completionCounter) + " day"
        : String(completionCounter) + " days"
    }
    private func updateCompletionButtonState() {
        if isCompletedToday {
            completionButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
            completionButton.alpha = 1
        } else {
            completionButton.setImage(UIImage(systemName: "plus"), for: .normal)
            completionButton.alpha = 0.3
        }
    }
    
    func setUpTrackerCell(descriptionName: String,
                          emoji: String,
                          descriptionViewBackgroundColor: UIColor,
                          completionButtonTintColor: UIColor,
                          trackerID: UInt,
                          counter: Int,
                          completionFlag: Bool) {
        habitDescriptionLabel.text = descriptionName
        emojiLabel.text = emoji
        cellDescriptionView.backgroundColor = descriptionViewBackgroundColor
        completionButton.tintColor = completionButtonTintColor
        completionCounter = counter
        trackerId = trackerID
        isCompletedToday = completionFlag
    }
}
