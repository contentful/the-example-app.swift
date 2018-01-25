
import Foundation
import UIKit
import AlamofireImage
import Contentful

extension UIImageView {

    func setImageToNaturalHeight(fromAsset asset: Asset,
                                 additionalOptions: [ImageOption] = [],
                                 heightConstraint: NSLayoutConstraint? = nil) {
        
        // Get the current width of the cell and see if it is wider than the screen.
        guard let width = asset.file?.details?.imageInfo?.width else { return }
        guard let height = asset.file?.details?.imageInfo?.height else { return }

        // Use scale to get the pixel size of the image view.
        let scale = UIScreen.main.scale
        let viewWidthInPx = Double(frame.width * scale)
        let percentageDifference = viewWidthInPx / width

        let viewHeightInPoints = height * percentageDifference / Double(scale)
        let viewHeightInPx = viewHeightInPoints * Double(scale)

        heightConstraint?.constant = CGFloat(viewHeightInPoints)

        let imageOptions: [ImageOption] = [
            .formatAs(.jpg(withQuality: .asPercent(100))),
            .width(UInt(viewWidthInPx)),
            .height(UInt(viewHeightInPx)),
        ] + additionalOptions

        let url = try! asset.url(with: imageOptions)

        // Use AlamofireImage extensons to fetch the image and render the image veiw.
        af_setImage(withURL: url,
                    placeholderImage: nil,
                    imageTransition: .crossDissolve(0.5),
                runImageTransitionIfCached: true)

    }
}

