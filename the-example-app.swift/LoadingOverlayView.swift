
import Foundation
import UIKit

extension UIView {

    static func loadingOverlay(frame: CGRect) -> UIView {
        let view = UIView(frame: frame)
        view.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .white)
        spinner.center = view.center
        view.addSubview(spinner)
        spinner.startAnimating()
        return view
    }
}
