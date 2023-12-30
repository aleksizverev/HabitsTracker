import UIKit
import CoreData

enum CategoryStoreErrors: Error {
    case categoryRetrievalError
    case cateryCastError
}

final class TrackerCategoryStore: NSObject {
    private let context: NSManagedObjectContext
    private let uiColorMarshalling = UIColorMarshalling()
    
    private lazy var fetchResultsController: NSFetchedResultsController<TrackerCategoryCoreData> = {
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: false)]
        
        let fetchResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        try? fetchResultsController.performFetch()
        return fetchResultsController
    }()
    
    var categories: [TrackerCategory] {
        guard
            let objects = fetchResultsController.fetchedObjects,
            let categories = try? objects.map({ try category(from: $0) }) else {
            return []
        }
        return categories
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
    
    func getCategory(withTitle title: String) throws -> TrackerCategoryCoreData {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format: "%K == %@",
                                        #keyPath(TrackerCategoryCoreData.title), title)
        let category = try? context.fetch(request)
        guard let category = category?.first else {
            throw CategoryStoreErrors.categoryRetrievalError
        }
        return category
    }
    
    func category(from categoryCoreData: TrackerCategoryCoreData) throws -> TrackerCategory {
        guard let categoryTitle = categoryCoreData.title else {
            throw CategoryStoreErrors.cateryCastError
        }
        
        guard let trackers = categoryCoreData.tracker else {
            return TrackerCategory(title: categoryTitle,
                                   assignedTrackers: [])
        }
        
        var assignedTrackers: [Tracker] = []
        try? trackers.forEach { tracker in
            guard let tracker = tracker as? TrackerCoreData else {
                throw TrackerStorageErrors.trackerCastError
            }
            guard
                let id = tracker.trackerID,
                let title = tracker.title,
                let color = tracker.color,
                let emoji = tracker.emoji,
                let schedule = tracker.schedule
            else {
                throw TrackerStorageErrors.trackerRetrievalError
            }
            assignedTrackers.append(Tracker(id: id,
                                            title: title,
                                            color: uiColorMarshalling.color(from: color),
                                            emoji: emoji,
                                            schedule: schedule))
        }
        
        return TrackerCategory(title: categoryTitle,
                               assignedTrackers: assignedTrackers)
    }
    
    func setupCategoryDataBase() {
        let tmpCategory1 = TrackerCategoryCoreData(context: context)
        tmpCategory1.title = "Important"
        
        let tmpCategory2 = TrackerCategoryCoreData(context: context)
        tmpCategory2.title = "Not so important"
        
        try? context.save()
    }
}
