//
//  LessonRichTextTableViewCell.swift
//  the-example-app.swift
//
//  Created by JP Wright on 13/12/18.
//  Copyright © 2018 Contentful. All rights reserved.
//

import Foundation
import Contentful
import ContentfulRichTextRenderer


struct RichTextEmbeddedViewProvider: ViewProvider {

    func view(for resource: FlatResource, context: [CodingUserInfoKey : Any]) -> ResourceBlockView {
        if let asset = resource as? Asset, asset.file?.details?.imageInfo != nil {
            let imageView = EmbeddedAssetImageView(asset: asset)
            imageView.surroundingTextShouldWrap = false
            imageView.setImageToNaturalHeight()
            return imageView
        } else if let snippets = resource as? LessonSnippets {
            let view = Bundle.main.loadNibNamed(String(describing: EmbeddedLessonSnippetsView.self), owner: self, options: nil)?.first as? EmbeddedLessonSnippetsView
            guard let embeddedSnippetsView = view else {
                return EmptyView(frame: .zero)
            }
            embeddedSnippetsView.configure(snippets: snippets)
            embeddedSnippetsView.sizeToFit()
            return embeddedSnippetsView
        }
        return EmptyView(frame: .zero)
    }
}

class LessonRichTextTableViewCell: UITableViewCell, CellConfigurable {

    typealias ItemType = LessonCollectionViewCell.Model

    var cellViewModel: ItemType?

    var richTextViewController: RichTextViewController?

    func configure(item: LessonCollectionViewCell.Model) {
        cellViewModel = item

        var styling = RenderingConfiguration()
        styling.viewProvider = RichTextEmbeddedViewProvider()
        let renderer = DefaultRichTextRenderer(styleConfig: styling)
        richTextViewController = RichTextViewController(richText: cellViewModel!.lesson.richText,
                                                        renderer: renderer,
                                                        nibName: nil,
                                                        bundle: nil)
    }

    func resetAllContent() {
        richTextViewController = nil
        cellViewModel = nil
    }
}
