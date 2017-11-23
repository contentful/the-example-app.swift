
import Foundation
import UIKit
import markymark

class LessonCopyTableViewCell: UITableViewCell, CellConfigurable {

    typealias ItemType = LessonCopy

    @IBOutlet weak var copyLabel: UILabel! {
        didSet {

        }
    }

    func configure(item: LessonCopy) {
        let markyMark = MarkyMark() { $0.setFlavor(ContentfulFlavor()) }
//        let markdownItems = markyMark.parseMarkDown(item.copy)
        let markdownItems = markyMark.parseMarkDown(stubCopy())
        let styling = DefaultStyling()
        let config = MarkDownToAttributedStringConverterConfiguration(styling: styling)
        config.addLayoutBlockBuilder(SVGAttributedStringBlockBuilder())

        let converter = MarkDownConverter(configuration: config)
        let attributedText = converter.convert(markdownItems)
        copyLabel.attributedText = attributedText
    }

    func stubCopy() -> String {
        return """
        ## API-first

        Contentful follows an API-first approach, which means all functionality is provided through an API.

        This means you can:
        - modify data schemas or configure a webhook through the Content Management API.
        - deliver cross-channel content through the Content Delivery API.
        - preview unpubublished content through the Content Preview API.
        - resize, crop, or re-compress images through the Images API.

        ![api first](https://images.contentful.com/ft4tkuv7nwl0/1YK5kwroV6UEGS64mQs0Eo/c5eb53f39703f73d215e7ed8ad2f88e6/api-first.svg)

        Contentful is a headless CMS; there is no templating or presentation layer tied to the content. Instead, a developer has complete freedom when it comes to building an application that consumes and presents content from Contentful. This allows you to decouple your applications from Contentful's services.

        Contentful has minimal requirements:
        - support for HTTP
        - parsing of JSON

        Beyond that, you are free to chose any technology you want.
        """
    }
}
