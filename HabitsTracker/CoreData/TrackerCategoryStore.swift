import UIKit
import CoreData

final class TrackerCategoryStore {
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
            let objects = self.fetchResultsController.fetchedObjects,
            let categories = try? objects.map({ try self.category(from: $0) }) else {
            return []
        }
        return categories
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
    
    func getCategoryWithTitle(title: String) -> TrackerCategoryCoreData {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCategoryCoreData.title), title)
        let category = try? context.fetch(request)
        guard let category = category?.first else {
            fatalError("Unable to fetch category")
        }
        return category
    }
    
    func category(from categoryCoreData: TrackerCategoryCoreData) -> TrackerCategory {
        guard let categoryTitle = categoryCoreData.title else {
            fatalError("Unable to convert category title")
        }
        
        guard let trackers = categoryCoreData.tracker else {
            return TrackerCategory(title: categoryTitle,
                                   assignedTrackers: [])
        }
        
        var assignedTrackers: [Tracker] = []
        trackers.forEach { tracker in
            guard let tracker = tracker as? TrackerCoreData else {
                fatalError()
            }
            assignedTrackers.append(Tracker(id: tracker.id!,
                                            title: tracker.title!,
                                            color: uiColorMarshalling.color(from: tracker.color!),
                                            emoji: tracker.emoji!,
                                            schedule: tracker.schedule!))
        }
        
        return TrackerCategory(title: categoryTitle,
                               assignedTrackers: assignedTrackers)
    }
    
    func setupCategoryDataBase() {
        /*
        let newTracker = TrackerCoreData(context: context)
        newTracker.id = UUID()
        newTracker.title = "Test Title"
        newTracker.emoji = "🚀"
        newTracker.color = uiColorMarshalling.hexString(from: UIColor().randomColor())
        newTracker.schedule = [1, 2, 3, 4, 5]
        */
         
        let tmpCategory1 = TrackerCategoryCoreData(context: context)
        tmpCategory1.title = "Important"
        
        let tmpCategory2 = TrackerCategoryCoreData(context: context)
        tmpCategory2.title = "Not so important"
        
        try? context.save()
    }
}
