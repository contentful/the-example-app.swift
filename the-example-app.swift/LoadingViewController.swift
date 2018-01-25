
import Foundation
import UIKit

class LoadingViewController: UIViewController {

    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        modalPresentationStyle = .overFullScreen
        view.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .white)
        spinner.center = view.center
        view.addSubview(spinner)
        spinner.startAnimating()
    }
}
