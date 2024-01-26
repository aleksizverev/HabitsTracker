import UIKit

protocol TrackerCategoryViewModelProtocol {
    var delegate: TrackerCategoryViewControllerDelegate? { get set }
    var onCategoriesListChange: (() -> Void)? { get set }
    var onCategoryCreationButtonTap: (() -> Void)? { get set }
    var onCategoryChoiceButtonTap: (() -> Void)? { get set }
    var availableCategories: [String] { get }
    func addNewCategory(category: String)
    func setChosenCategory(withTitle category: String)
    func getChosenCategory() -> String?
    func didTapCreationButton()
    func didSelectCategory()
}

final class TrackerCategoryViewModel: TrackerCategoryViewModelProtocol {
    
    weak var delegate: TrackerCategoryViewControllerDelegate?
    
    var onCategoriesListChange: (() -> Void)?
    var onCategoryCreationButtonTap: (() -> Void)?
    var onCategoryChoiceButtonTap: (() -> Void)?
    
    private let categoryStore: TrackerCategoryStore
    private var chosenCategory: String?
    
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
    
    func setChosenCategory(withTitle category: String) {
        chosenCategory = category
    }
    
    func getChosenCategory() -> String? {
        chosenCategory
    }
    
    func didTapCreationButton() {
        onCategoryCreationButtonTap?()
    }
    
    func didSelectCategory() {
        delegate?.addCategory(category: chosenCategory)
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
