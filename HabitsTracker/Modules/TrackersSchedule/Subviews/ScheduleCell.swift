import UIKit

final class ScheduleCell: UITableViewCell {
    private let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let switcher: UISwitch = {
        let switcher = UISwitch()
        switcher.translatesAutoresizingMaskIntoConstraints = false
        switcher.onTintColor = UIColor(named: "YP Blue")
        return switcher
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = UIColor(named: "YP Background")
        
        addSubviews()
        applyConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupScheduleCell(labelText: String, switchTag: Int) {
        label.text = labelText
        switcher.tag = switchTag
    }
    
    private func addSubviews() {
        contentView.addSubview(label)
        contentView.addSubview(switcher)
    }
    
    private func applyConstraints() {
        NSLayoutConstraint.activate([
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            switcher.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            switcher.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }
}
