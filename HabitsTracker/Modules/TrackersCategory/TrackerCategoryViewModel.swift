import UIKit

final class TrackerCategoryViewModel {
    
    var onChange: (() -> Void)?
    
    private let categoryStore: TrackerCategoryStore
    
    private(set) var availableCategories: [String] = [] {
        didSet {
            onChange?()
        }
    }
    
    init(categoryStore: TrackerCategoryStore) {
        self.categoryStore = categoryStore
        categoryStore.delegate = self
        availableCategories = getAvailableCategories()
    }
    
    func addNewCategory(category: String) {
        categoryStore.createNewCategory(withTitle: category)
    }
    
    private func getAvailableCategories() -> [String] {
        categoryStore.categories.map { $0.title }
    }
}

extension TrackerCategoryViewModel: TrackerCategoryStoreDelegate {
    func storeDidUpdate(_ store: TrackerCategoryStore) {
        availableCategories = getAvailableCategories()
    }
}
