import UIKit
import CoreData

final class TrackerRecordStore {
    private let context: NSManagedObjectContext
    private lazy var fetchResultsController: NSFetchedResultsController<TrackerRecordCoreData> = {
        let fetchRequest = TrackerRecordCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        let fetchRequestResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        try? fetchRequestResultsController.performFetch()
        return fetchRequestResultsController
    }()
    
    var records: [TrackerRecord] {
        guard
            let objects = fetchResultsController.fetchedObjects,
            let records = try? objects.map({ try record(from: $0)})
        else {
            return []
        }
        return records
    }
    
    convenience init() {
        guard let delegate = (UIApplication.shared.delegate as? AppDelegate) else {
            fatalError("Unable to get context")
        }
        let context = delegate.persistentContainer.viewContext
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func addNewRecord(forTrackerWithID id: UUID, date: Date, to trackerCoreData: TrackerCoreData) {
        let newRecord = TrackerRecordCoreData(context: context)
        newRecord.id = id
        newRecord.date = date
        trackerCoreData.addToRecord(newRecord)
        try? context.save()
    }
    
    func record(from recordCoreData: TrackerRecordCoreData) -> TrackerRecord {
        guard let trackerID = recordCoreData.id else {
            fatalError("Unable to get tracker id")
        }
        
        guard let recordDate = recordCoreData.date else {
            fatalError("Unable to get record date")
        }
        
        return TrackerRecord(id: trackerID, date: recordDate)
    }
}
