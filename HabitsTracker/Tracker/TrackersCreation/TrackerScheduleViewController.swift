import UIKit

protocol TrackerScheduleViewControllerDelegate: AnyObject {
    func addSchedule(schedule: [Int])
}

final class TrackerScheduleViewController: UIViewController {
    enum Weekdays: Int, CaseIterable {
        case Moday = 1
        case Tuesday = 2
        case Wednesday = 3
        case Thursday = 4
        case Friday = 5
        case Saturday = 6
        case Sunday = 7
    }
    
    weak var delegate: TrackerScheduleViewControllerDelegate?
    var chosenSchedule: Set<Int> = []

    private var newSchedule: Set<Int> = []
    private var doneButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Done", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.backgroundColor = UIColor(named: "YP Black")
        button.addTarget(self, action: #selector(Self.didTapDoneButton), for: .touchUpInside)
        return button
    }()
    private var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = UIColor(named: "YP Background")
        tableView.isScrollEnabled = false
        tableView.rowHeight = 75
        tableView.layer.cornerRadius = 16
        tableView.allowsSelection = false
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.separatorColor = UIColor(named: "YP Gray")
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "Schedule"
        
        newSchedule = chosenSchedule
        
        tableView.dataSource = self
        tableView.register(ScheduleCell.self, forCellReuseIdentifier: "ScheduleCell")
        
        addSubviews()
        applyConstraints()
    }
    
    @objc
    private func didTapDoneButton() {
        delegate?.addSchedule(schedule: newSchedule.sorted())
        self.dismiss(animated: true)
    }
    @objc
    private func onSwitchValueChanged(sender: UISwitch) {
        let tag = sender.tag
        switch sender.isOn {
        case true:
            newSchedule.insert(tag)
        case false:
            newSchedule.remove(tag)
        }
    }
    
    private func isCurrentDayInChosenSchedule(day: Int) -> Bool {
        chosenSchedule.contains(day)
    }
    
    
    private func addSubviews() {
        view.addSubview(doneButton)
        view.addSubview(tableView)
    }
    private func applyConstraints() {
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 525),
            
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
}

extension TrackerScheduleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Weekdays.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ScheduleCell",
                                                 for: indexPath) as? ScheduleCell
        else {
            return ScheduleCell()
        }
        
        cell.setupScheduleCell(labelText: String(describing: Weekdays.allCases[indexPath.row]),
                               switchTag: Weekdays.allCases[indexPath.row].rawValue)
        cell.switcher.addTarget(self,
                                action: #selector(Self.onSwitchValueChanged(sender:)),
                                for: .valueChanged)
        cell.switcher.isOn = isCurrentDayInChosenSchedule(day: Weekdays.allCases[indexPath.row].rawValue)
        
        if indexPath.row == (Weekdays.allCases.count - 1) {
            cell.separatorInset = UIEdgeInsets(top: 0, left: cell.bounds.size.width + 100, bottom: 0, right: 0)
        }
        return cell
    }
}
