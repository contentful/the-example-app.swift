
import Foundation
import UIKit
import CoreGraphics

class CredentialTextField: UITextField {

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        super.textRect(forBounds: bounds)
        return bounds.insetBy(dx: 17.0, dy: 0.0)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        super.editingRect(forBounds: bounds)
        return bounds.insetBy(dx: 17.0, dy: 0.0)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .white
        layer.borderWidth = 1.0
        layer.borderColor = UIColor(red: 0.74, green: 0.73, blue: 0.76, alpha: 1.0).cgColor
    }
}
