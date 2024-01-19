import UIKit
import CoreData

enum CategoryStoreErrors: Error {
    case categoryRetrievalError
    case categoryTitleError
}

protocol TrackerCategoryStoreDelegate: AnyObject {
    func storeDidUpdate(_ store: TrackerCategoryStore)
}

final class TrackerCategoryStore: NSObject {
    weak var delegate: TrackerCategoryStoreDelegate?
    
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
        fetchResultsController.delegate = self
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
            throw CategoryStoreErrors.categoryTitleError
        }
        
        guard let trackers = categoryCoreData.tracker else {
            return TrackerCategory(title: categoryTitle,
                                   assignedTrackers: [])
        }
        
        var assignedTrackers: [Tracker] = []
        try? trackers.forEach { tracker in
            guard let tracker = tracker as? TrackerCoreData else { throw TrackerStorageErrors.trackerCastError }
            guard let id = tracker.trackerID else { throw TrackerStorageErrors.trackerIDError }
            guard let title = tracker.title else { throw TrackerStorageErrors.trackerTitleError }
            guard let color = tracker.color else { throw TrackerStorageErrors.trackerColorError }
            guard let emoji = tracker.emoji else { throw TrackerStorageErrors.trackerEmojiError }
            guard let schedule = tracker.schedule else { throw TrackerStorageErrors.trackerScheduleError }
            
            assignedTrackers.append(Tracker(id: id,
                                            title: title,
                                            color: uiColorMarshalling.color(from: color),
                                            emoji: emoji,
                                            schedule: schedule))
        }
        
        return TrackerCategory(title: categoryTitle,
                               assignedTrackers: assignedTrackers)
    }
    
    func createNewCategory(withTitle title: String) {
        let newCategory = TrackerCategoryCoreData(context: context)
        newCategory.title = title
        try? context.save()
    }
    
    func setupCategoryDataBase() {
        let tmpCategory1 = TrackerCategoryCoreData(context: context)
        tmpCategory1.title = "Important"
        
        let tmpCategory2 = TrackerCategoryCoreData(context: context)
        tmpCategory2.title = "Not so important"
        
        try? context.save()
    }
}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.storeDidUpdate(self)
    }
}
