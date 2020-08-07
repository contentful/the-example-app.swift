
import Foundation
import UIKit

class LayoutHeroImageTableViewCell: UITableViewCell, CellConfigurable {
    
    func configure(item: LayoutHeroImage) {
        titleLabel.text = item.headline

        if let backgroundImage = item.backgroundImage {
            backgroundImageView.setImageToNaturalHeight(fromAsset: backgroundImage)
        }
    }

    func resetAllContent() {
        titleLabel.text = nil
        backgroundImageView.image = nil
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.textColor = .white
            titleLabel.font = UIFont.systemFont(ofSize: 28.0, weight: .bold)
        }
    }

    @IBOutlet weak var imageOverlayView: UIView! {
        didSet {
            imageOverlayView.backgroundColor = UIColor(red: 0.24, green: 0.24, blue: 0.25, alpha: 0.8)
            imageOverlayView.layer.cornerRadius = 15.0
            imageOverlayView.clipsToBounds = true
        }
    }

    @IBOutlet weak var backgroundImageView: UIImageView!  {
        didSet {
            backgroundImageView.layer.cornerRadius = 15.0
            backgroundImageView.contentMode = .center
            backgroundImageView.clipsToBounds = true
        }
    }
}
