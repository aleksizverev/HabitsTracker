import UIKit

final class TrackerCell: UICollectionViewCell {
    private var habitDescriptionLabel: UILabel = {
        var label = UILabel()
        label.text = "Default text"
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private var emojiLabel: UILabel = {
        var label = UILabel()
        label.text = "🎃"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true
        
        addSubviews()
        applyConstraints()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addSubviews() {
        contentView.addSubview(habitDescriptionLabel)
        contentView.addSubview(emojiLabel)
    }
    private func applyConstraints() {
        NSLayoutConstraint.activate([
            habitDescriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            habitDescriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            habitDescriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            
            emojiLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            emojiLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12)
        ])
    }
}
