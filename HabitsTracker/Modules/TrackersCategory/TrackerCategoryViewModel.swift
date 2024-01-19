import UIKit

final class TrackerCategoryViewModel {
    
    var onCategoriesListChange: (() -> Void)?
    var onCategoryCreationButtonTap: (() -> Void)?
    var onCategoryChoiceButtonTap: (() -> Void)?
    
    private let categoryStore: TrackerCategoryStore
    
    private(set) var availableCategories: [String] = [] {
        didSet {
            onCategoriesListChange?()
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
    
    func didTapCreationButton() {
        onCategoryCreationButtonTap?()
    }
    
    func didSelectCategory() {
        onCategoryChoiceButtonTap?()
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
