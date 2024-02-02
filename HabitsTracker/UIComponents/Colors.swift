import UIKit

final class Colors {
    let viewBackgroundColor = UIColor.systemBackground 
    
    let collectionViewTextColor = UIColor { (traits: UITraitCollection) -> UIColor in
        if traits.userInterfaceStyle == .light {
            return UIColor.black
        } else {
            return UIColor.white
        }
    }
    
    let buttonColor = UIColor { (traits: UITraitCollection) -> UIColor in
        if traits.userInterfaceStyle == .light {
            return UIColor(named: "YP Black")!
        } else {
            return UIColor.white
        }
    }
    
    let datePickerBackgoundColor = UIColor(named: "LightGray")
}
