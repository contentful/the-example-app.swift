
import Foundation
import UIKit
import CoreGraphics

class CredentialTextField: UITextField {

    static let xInset: CGFloat = 16.0

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        super.textRect(forBounds: bounds)
        return bounds.insetBy(dx: CredentialTextField.xInset, dy: 0.0)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        super.editingRect(forBounds: bounds)
        return bounds.insetBy(dx: CredentialTextField.xInset, dy: 0.0)
    }
}
