import UIKit

extension UIColor {
    func randomColor() -> UIColor {
        let red = CGFloat.random(in: 0...1)
        let green = CGFloat.random(in: 0...1)
        let blue = CGFloat.random(in: 0...1)
        
        let color = UIColor(red: red, green: green, blue: blue, alpha: 1.0)
        return color
    }
}
