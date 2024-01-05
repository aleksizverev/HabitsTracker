import UIKit

struct Tracker: Hashable {
    let id: UUID
    let title: String
    let color: UIColor
    let emoji: String
    let schedule: [Int]
    
    func isScheduledForDayNumber(_ dayNum: Int) -> Bool {
        return schedule.contains(dayNum)
    }
}
