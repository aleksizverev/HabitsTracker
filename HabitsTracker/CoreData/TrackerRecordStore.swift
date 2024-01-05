import UIKit
import CoreData

enum TrackerRecordStoreErrors: Error {
    case recordRetrievalError
    case recordCastError
    case recordDeletionError
    case recordDateError
    case recordTrackerIDError
}

final class TrackerRecordStore: NSObject {
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
            let records = try? objects.map({ try record(from: $0) })
        else {
            return []
        }
        return records
    }
    
    convenience override init() {
        guard let delegate = (UIApplication.shared.delegate as? AppDelegate) else {
            fatalError("Unable to get context")
        }
        let context = delegate.persistentContainer.viewContext
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
    }
    
    func addNewRecord(forTrackerWithID id: UUID, date: Date, to trackerCoreData: TrackerCoreData) {
        let newRecord = TrackerRecordCoreData(context: context)
        newRecord.trackerID = id
        newRecord.date = date
        trackerCoreData.addToRecord(newRecord)
        try? context.save()
    }
    
    func getRecord(forTrackerWithID id: UUID, date: Date) throws -> TrackerRecordCoreData {
        let request = TrackerRecordCoreData.fetchRequest()
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format: "%K == %@ AND %K == %@",
                                        #keyPath(TrackerRecordCoreData.trackerID), id as CVarArg,
                                        #keyPath(TrackerRecordCoreData.date), date as NSDate
        )
        let record = try? context.fetch(request)
        guard let record = record?.first else {
            throw CategoryStoreErrors.categoryRetrievalError
        }
        return record
    }
    
    func deleteRecord(forTrackerWithID id: UUID, date: Date) throws {
        let record = try getRecord(forTrackerWithID: id, date: date)
        context.delete(record)
        try? context.save()
    }
    
    func record(from recordCoreData: TrackerRecordCoreData) throws -> TrackerRecord {
        guard let trackerID = recordCoreData.trackerID else {
            throw TrackerRecordStoreErrors.recordTrackerIDError
        }
        
        guard let recordDate = recordCoreData.date else {
            throw TrackerRecordStoreErrors.recordDateError
        }
        
        return TrackerRecord(id: trackerID, date: recordDate)
    }
}
