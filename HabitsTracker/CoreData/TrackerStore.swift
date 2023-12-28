import UIKit
import CoreData

struct TrackerStoreUpdate {
    struct Move: Hashable {
        let oldIndex: Int
        let newIndex: Int
    }
    let insertedIndexes: IndexSet
}

protocol TrackerStoreDelegate: AnyObject {
    func store(
        _ store: TrackerStore,
        didUpdate update: TrackerStoreUpdate
    )
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
        
//        fetchResultsController.delegate = self
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
    }
    
    func tracker(from tracker: TrackerCoreData) -> Tracker { // TODO: remove force unwrap
        return Tracker(id: tracker.id!,
                       title: tracker.title!,
                       color: uiColorMarshalling.color(from: tracker.color!),
                       emoji: tracker.emoji!,
                       schedule: tracker.schedule!)
    }
    
    func createNewTracker(tracker: Tracker, to categoryCoreData: TrackerCategoryCoreData) {
        let newTracker = TrackerCoreData(context: context)
        newTracker.id = tracker.id
        newTracker.title = tracker.title
        newTracker.emoji = tracker.emoji
        newTracker.color = uiColorMarshalling.hexString(from: tracker.color)
        newTracker.schedule = tracker.schedule
        
        categoryCoreData.addToTracker(newTracker)
        
        delegate?.store(self, didUpdate: TrackerStoreUpdate(insertedIndexes: IndexSet()))
        try? context.save()
    }
}



/*

private var insertedIndexes: IndexSet?

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexes = IndexSet()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.store(
            self,
            didUpdate: TrackerStoreUpdate(
                insertedIndexes: insertedIndexes!
            )
        )
        insertedIndexes = nil
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            guard let indexPath = newIndexPath else { fatalError() }
            insertedIndexes?.insert(indexPath.item)
        @unknown default:
            fatalError()
        }
    }
}
*/
