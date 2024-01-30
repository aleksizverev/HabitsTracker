import UIKit
import CoreData

enum TrackerStorageErrors: Error {
    case getTrackerByIDError
    case trackerCastError
    case trackerIDError
    case trackerTitleError
    case trackerColorError
    case trackerEmojiError
    case trackerScheduleError
}

protocol TrackerStoreDelegate: AnyObject {
    func update()
}

final class TrackerStore: NSObject {
    private let context: NSManagedObjectContext
    
    private let uiColorMarshalling = UIColorMarshalling()
    
    private lazy var fetchResultsController: NSFetchedResultsController<TrackerCoreData> = {
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: false)]
        
        let fetchResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        try? fetchResultsController.performFetch()
        return fetchResultsController
    }()
    
    var trackers: [Tracker] {
        guard
            let objects = fetchResultsController.fetchedObjects,
            let trackers = try? objects.map({ try tracker(from: $0) })
        else {
            return []
        }
        return trackers
    }
    
    weak var delegate: TrackerStoreDelegate?
    
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
        
        self.fetchResultsController.delegate = self
    }
    
    func tracker(from tracker: TrackerCoreData) throws -> Tracker {
        guard let id = tracker.trackerID else { throw TrackerStorageErrors.trackerIDError }
        guard let title = tracker.title else { throw TrackerStorageErrors.trackerTitleError }
        guard let color = tracker.color else { throw TrackerStorageErrors.trackerColorError }
        guard let emoji = tracker.emoji else { throw TrackerStorageErrors.trackerEmojiError }
        guard let schedule = tracker.schedule else { throw TrackerStorageErrors.trackerScheduleError }
            
        return Tracker(id: id,
                       title: title,
                       color: uiColorMarshalling.color(from: color),
                       emoji: emoji,
                       schedule: schedule)
    }
    
    func createNewTracker(tracker: Tracker, to categoryCoreData: TrackerCategoryCoreData) {
        let newTracker = TrackerCoreData(context: context)
        newTracker.trackerID = tracker.id
        newTracker.title = tracker.title
        newTracker.emoji = tracker.emoji
        newTracker.color = uiColorMarshalling.hexString(from: tracker.color)
        newTracker.schedule = tracker.schedule
        
        categoryCoreData.addToTracker(newTracker)
        try? context.save()
    }
    
    func getTracker(withID id: UUID) throws -> TrackerCoreData {
        let request = TrackerCoreData.fetchRequest()
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCoreData.trackerID), id as CVarArg)
        let tracker = try? context.fetch(request)
        guard let tracker = tracker?.first else {
            throw TrackerStorageErrors.getTrackerByIDError
        }
        return tracker
    }
    
    func deleteTracker(withID id: UUID) throws {
        let tracker = try getTracker(withID: id)
        context.delete(tracker)
        try? context.save()
    }
    
    func changePinStateForTracker(withID id: UUID) throws {
        guard let tracker = try? getTracker(withID: id) else {
            throw TrackerStorageErrors.getTrackerByIDError
        }
        let state = tracker.isPinned
        tracker.isPinned = !state
        try? context.save()
    }
    
    func getPinnedTrackers() -> [Tracker] {
        let request = TrackerCoreData.fetchRequest()
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCoreData.isPinned), NSNumber(value: true))
        
        let trackers = try? context.fetch(request)
        
        guard let trackers = trackers else {
            return []
        }
        
        let pinnedTrackers = try? trackers.map({ try tracker(from: $0) })
        
        guard let pinnedTrackers = pinnedTrackers else {
            return []
        }
        
        return pinnedTrackers
    }
}

extension TrackerStore: NSFetchedResultsControllerDelegate {    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.update()
    }
}
