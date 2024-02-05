import UIKit

extension UIColor {
    func randomColor() -> UIColor {
        let red = CGFloat.random(in: 0...1)
        let green = CGFloat.random(in: 0...1)
        let blue = CGFloat.random(in: 0...1)
        
        let color = UIColor(red: red, green: green, blue: blue, alpha: 1.0)
        return color
    }
    
    func isEqualTo(color: UIColor) -> Bool {
        guard let components = self.cgColor.components,
              let comparedComponents = color.cgColor.components
        else {
            return false
        }
        
        if (abs(components[0] - comparedComponents[0]) <= 0.001) &&
            (abs(components[1] - comparedComponents[1]) <= 0.001) &&
            (abs(components[2] - comparedComponents[2]) <= 0.001) &&
            (abs(components[3] - comparedComponents[3]) <= 0.001) {
            return true
        }
        return false
    }
}
