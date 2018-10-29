//
//  ExampleAppTableViewCell.swift
//  the-example-app.swift
//
//  Created by JP Wright on 20.08.18.
//  Copyright © 2018 Contentful. All rights reserved.
//

import Foundation
import UIKit

struct ExampleAppViewModel {

    let exampleApp: ExampleApp
    let contentful: ContentfulService
}

class ExampleAppTableViewCell: UITableViewCell, CellConfigurable, UITextViewDelegate {

    typealias ItemType = ExampleAppViewModel

    func configure(item: ExampleAppViewModel) {
        let underlineAttributes: [NSAttributedString.Key: Any] = [.underlineStyle: NSUnderlineStyle.single.rawValue]

        exampleAppImageView.image = item.exampleApp.image
        hostedLinkTextView.attributedText = NSAttributedString(string: "Hosted", attributes: underlineAttributes + [.link: item.exampleApp.hostedAppURL(contentful: item.contentful)])
        githubLinkTextView.attributedText = NSAttributedString(string: "Github", attributes: underlineAttributes + [.link: item.exampleApp.githubLink])
    }

    func resetAllContent() {
        hostedLinkTextView.text = ""
        githubLinkTextView.text = ""
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    @IBOutlet weak var exampleAppImageView: UIImageView!
    @IBOutlet weak var hostedLinkTextView: UITextView!
    @IBOutlet weak var githubLinkTextView: UITextView!
}
