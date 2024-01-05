import UIKit

final class ColorCell: UICollectionViewCell {
    static let identifier = "ColorCell"
    
    let colorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.layer.cornerRadius = 8
        label.layer.masksToBounds = true
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubviews()
        applyConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func addSubviews() {
        contentView.addSubview(colorLabel)
    }
    
    private func applyConstraints() {
        NSLayoutConstraint.activate([
            colorLabel.heightAnchor.constraint(equalToConstant: 40),
            colorLabel.widthAnchor.constraint(equalToConstant: 40),
            colorLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func setColor(color: UIColor) {
        colorLabel.backgroundColor = color
    }
    
    func getCellColor() -> UIColor {
        guard let cellColor = colorLabel.backgroundColor else {
            return .white
        }
        return cellColor
    }
}
