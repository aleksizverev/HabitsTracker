import UIKit

final class EmojiCell: UICollectionViewCell {
    private var subView: UIView = {
        let subView = UIView(frame: CGRect(x: 0, y: 0, width: 46, height: 46))
        subView.translatesAutoresizingMaskIntoConstraints = false
        subView.layer.cornerRadius = 16
        subView.layer.masksToBounds = true
        return subView
    }()
    private var emojiLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubviews()
        applyConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addSubviews() {
        contentView.addSubview(subView)
        subView.addSubview(emojiLabel)
    }
    private func applyConstraints() {
        NSLayoutConstraint.activate([
            subView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            subView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            subView.topAnchor.constraint(equalTo: contentView.topAnchor),
            subView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            emojiLabel.centerXAnchor.constraint(equalTo: subView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: subView.centerYAnchor)
        ])
    }
    
    func setEmoji(emoji: String) {
        emojiLabel.text = emoji
    }
    func didSelectEmoji() {
        subView.backgroundColor = UIColor(named: "YP Background")
    }
    func didDeselectEmoji() {
        subView.backgroundColor = .clear
    }
    func getCellEmoji() -> String {
        guard let emoji = emojiLabel.text else {
            return ""
        }
        return emoji
    }
}
