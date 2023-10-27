import UIKit

final class TrackerCell: UICollectionViewCell {
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
        label.text = "1 day"
        return label
    }()
    private var completionButton: UIButton = {
        let button = UIButton.systemButton(with: UIImage(named: "CompletionButton")!, target: nil, action: nil) //TODO: remove force unwrap
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .cyan
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
    
    func setHabitDescriptionName(name: String) {
        habitDescriptionLabel.text = name
    }
    func setHabitEmoji(emoji: String) {
        emojiLabel.text = emoji
    }
    func setCellDescriptionViewBackgroundColor(color: UIColor) {
        cellDescriptionView.backgroundColor = color
    }
    func setCompletionButtonTintColor(color: UIColor){
        completionButton.tintColor = color
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
}
