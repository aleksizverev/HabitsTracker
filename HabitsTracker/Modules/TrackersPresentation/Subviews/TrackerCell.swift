import UIKit

protocol TrackerCellDelegate: AnyObject {
    func recordTrackerCompletionForSelectedDate(id: UUID)
    func removeTrackerCompletionForSelectedDate(id: UUID)
    func changePinState(id: UUID)
    func editTracker(id: UUID, counter: Int)
    func deleteTracker(id: UUID)
}

final class TrackerCell: UICollectionViewCell {
    let colors = Colors()
    
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
    
    private var isPinned: Bool = false
    
    private var isAllowedToBeCompletedToday: Bool = false
    
    private var trackerId: UUID = UUID()
    
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
    
    private lazy var completionButton: UIButton = {
        let button = UIButton(type: .custom)
        button.addTarget(self,
                         action: #selector(Self.completionButtonDidTap),
                         for: .touchUpInside)
        button.setImage(UIImage(systemName: "plus") ?? UIImage(), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 16
        button.tintColor = colors.completeTrackerButtonColor
        return button
    }()
    
    private lazy var pinImageView: UIImageView = {
        let image = UIImage(named: "Pin")
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubviews()
        applyConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func completionButtonDidTap() {
        if !isAllowedToBeCompletedToday {
            return
        }

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
        cellDescriptionView.addSubview(pinImageView)
    }
    
    private func applyConstraints() {
        NSLayoutConstraint.activate([
            
            cellDescriptionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cellDescriptionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cellDescriptionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cellDescriptionView.heightAnchor.constraint(equalToConstant: 90),
            
            emojiLabel.leadingAnchor.constraint(equalTo: cellDescriptionView.leadingAnchor, constant: 12),
            emojiLabel.topAnchor.constraint(equalTo: cellDescriptionView.topAnchor, constant: 12),
            
            pinImageView.trailingAnchor.constraint(equalTo: cellDescriptionView.trailingAnchor, constant: -4),
            pinImageView.topAnchor.constraint(equalTo: cellDescriptionView.topAnchor, constant: 12),
            
            habitDescriptionLabel.leadingAnchor.constraint(equalTo: cellDescriptionView.leadingAnchor, constant: 12),
            habitDescriptionLabel.trailingAnchor.constraint(equalTo: cellDescriptionView.trailingAnchor, constant: -12),
            habitDescriptionLabel.topAnchor.constraint(greaterThanOrEqualTo: emojiLabel.bottomAnchor, constant: 8),
            habitDescriptionLabel.bottomAnchor.constraint(equalTo: cellDescriptionView.bottomAnchor, constant: -12),
            
            statisticsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            statisticsLabel.topAnchor.constraint(equalTo: cellDescriptionView.bottomAnchor, constant: 16),
            
            completionButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            completionButton.centerYAnchor.constraint(equalTo: statisticsLabel.centerYAnchor),
            completionButton.widthAnchor.constraint(equalToConstant: 34),
            completionButton.heightAnchor.constraint(equalToConstant: 34)
        ])
    }
    
    private func showPin() {
        pinImageView.isHidden = false
    }
    
    private func hidePin() {
        pinImageView.isHidden = true
    }
    
    private func updateHabitStatisticsLabelDays() {
        statisticsLabel.text = String.localizedStringWithFormat(
            NSLocalizedString("numberOfDays", comment: "Tracker complations counter"),
            completionCounter
        )
    }
    
    private func updateCompletionButtonState() {
        if isCompletedToday {
            completionButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
            completionButton.alpha = 0.3
        } else {
            completionButton.setImage(UIImage(systemName: "plus"), for: .normal)
            completionButton.alpha = 1
        }
    }
    
    func setupTrackerCell(descriptionName: String,
                          emoji: String,
                          descriptionViewBackgroundColor: UIColor,
                          completionButtonTintColor: UIColor,
                          trackerID: UUID,
                          counter: Int,
                          completionFlag: Bool,
                          isCompletionAlowed: Bool,
                          isPinnedState: Bool
    ) {
        
        habitDescriptionLabel.text = descriptionName
        emojiLabel.text = emoji
        
        let interaction = UIContextMenuInteraction(delegate: self)
        cellDescriptionView.addInteraction(interaction)
        cellDescriptionView.backgroundColor = descriptionViewBackgroundColor
        
        completionButton.backgroundColor = completionButtonTintColor
        completionCounter = counter
        
        trackerId = trackerID
        
        isCompletedToday = completionFlag
        isAllowedToBeCompletedToday = isCompletionAlowed
        
        isPinned = isPinnedState
        isPinnedState ? showPin() : hidePin()
    }
}

extension TrackerCell: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(actionProvider: { [weak self] _ in
        
            guard let self = self else {
                return UIMenu()
            }
            
            let pinAction = UIAction(title: isPinned ? "Unpin" : "Pin") { _ in
                self.delegate?.changePinState(id: self.trackerId)
            }
            let editAction = UIAction(title: "Edit") { _ in
                self.delegate?.editTracker(id: self.trackerId, counter: self.completionCounter)
            }
            let deleteAction = UIAction(title: "Delete", attributes: .destructive) { _ in
                self.delegate?.deleteTracker(id: self.trackerId)
            }
            
            return UIMenu(title: "", children: [pinAction, editAction, deleteAction])
        })
    }
}
