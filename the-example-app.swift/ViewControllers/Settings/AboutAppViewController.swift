//
//  AboutAppViewController.swift
//  the-example-app.swift
//
//  Created by JP Wright on 20.08.18.
//  Copyright © 2018 Contentful. All rights reserved.
//

import Foundation
import UIKit

enum ExampleApp {

    static let all: [ExampleApp] = [
        .javascript,
        .dotNet,
        .ruby,
        .php,
        .python,
        .java,
        .swift,
        .android,
    ]

    case swift
    case android
    case java
    case javascript
    case dotNet
    case ruby
    case python
    case php

    var githubLink: URL {
        switch self {
        case .swift:        return URL(string: "https://github.com/contentful/the-example-app.swift")!
        case .android:      return URL(string: "https://github.com/contentful/the-example-app.kotlin")!
        case .java:         return URL(string: "https://github.com/contentful/the-example-app.java")!
        case .javascript:   return URL(string: "https://github.com/contentful/the-example-app.nodejs")!
        case .dotNet:       return URL(string: "https://github.com/contentful/the-example-app.csharp")!
        case .ruby:         return URL(string: "https://github.com/contentful/the-example-app.rb")!
        case .php:          return URL(string: "https://github.com/contentful/the-example-app.php")!
        case .python:       return URL(string: "https://github.com/contentful/the-example-app.py")!
        }
    }

    func hostedAppURL(contentful: StatefulContentfulClientProvider) -> URL {
        var route: String
        switch self {
        case .swift:        return URL(string: "https://itunes.apple.com/app/contentful-reference/id1333721890")!
        case .android:      return URL(string: "https://play.google.com/store/apps/details?id=com.contentful.tea.kotlin")!
        case .java:         route = "https://the-example-app-java.\(contentful.credentials.domainHost)/"
        case .javascript:   route = "https://the-example-app-nodejs.\(contentful.credentials.domainHost)/"
        case .dotNet:       route = "https://the-example-app-csharp.\(contentful.credentials.domainHost)/"
        case .ruby:         route = "https://the-example-app-rb.\(contentful.credentials.domainHost)/"
        case .php:          route = "https://the-example-app-php.\(contentful.credentials.domainHost)/"
        case .python:       route = "https://the-example-app-py.\(contentful.credentials.domainHost)/"
        }

        let params: [String: String] = [
            "space_id": contentful.credentials.spaceId,
            "delivery_token": contentful.credentials.deliveryAPIAccessToken,
            "preview_token": contentful.credentials.previewAPIAccessToken,
            "api": contentful.stateMachine.state.api == .delivery ? "cda" : "cpa",
            "editorial_features": contentful.stateMachine.state.editorialFeaturesEnabled ? "enabled" : "disabled",
            "locale": contentful.stateMachine.state.locale.code
        ]
        let paramStrings: [String] = params.map { kv in
            let (key, value) = kv
            return key + "=" + value
        }
        let paramString = "?" + paramStrings.joined(separator: "&")

        return URL(string: route + paramString)!
    }
    
    var image: UIImage? {
        switch self {
        case .swift:        return UIImage(named: "example-app-swift")
        case .android:      return UIImage(named: "example-app-android")
        case .java:         return UIImage(named: "example-app-java")
        case .javascript:   return UIImage(named: "example-app-nodejs")
        case .dotNet:       return UIImage(named: "example-app-dotnet")
        case .ruby:         return UIImage(named: "example-app-ruby")
        case .php:          return UIImage(named: "example-app-php")
        case .python:       return UIImage(named: "example-app-python")
        }
    }
}

class AboutAppViewController: UIViewController,
                              UITableViewDataSource {

    init(services: ApplicationServices) {
        self.services = services
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    let services: ApplicationServices

    // Table view and cell rendering.
    var tableView: UITableView!
    let aboutAppCellFactory = TableViewCellFactory<AboutTableViewCell>()
    let exampleAppCellFactory = TableViewCellFactory<ExampleAppTableViewCell>()

    // MARK: UIViewController

    override func loadView() {
        tableView = UITableView(frame: .zero)

        tableView.accessibilityLabel = "About"

        tableView.registerNibFor(AboutTableViewCell.self)
        tableView.registerNibFor(ExampleAppTableViewCell.self)

        // Enable table view cells to be sized dynamically based on inner content.
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 200
        view = tableView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "About"
        tableView.dataSource = self
    }

    // MARK: UITableViewDataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:     return 1
        case 1:     return ExampleApp.all.count
        default:    fatalError()
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let attributedText = AboutAppViewController.aboutAttributedText(contentfulService: services.contentful)
            return aboutAppCellFactory.cell(for: attributedText, in: tableView, at: indexPath)
        case 1:
            let viewModel = ExampleAppViewModel(exampleApp: ExampleApp.all[indexPath.row], contentful: services.contentful)
            return exampleAppCellFactory.cell(for: viewModel, in: tableView, at: indexPath)
        default:
            fatalError()
        }
    }

    static func aboutAttributedText(contentfulService: StatefulContentfulClientProvider) -> NSAttributedString {
        let regularAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 14.0, weight: .regular)]
        let underlineAttributes: [NSAttributedString.Key: Any] = [.underlineStyle: NSUnderlineStyle.single.rawValue]

        let attributedString = NSMutableAttributedString(string: "")
        let title = NSAttributedString(string: "modalTitleSwift".localized(contentfulService: contentfulService) + " ",
                                       attributes: [.font: UIFont.systemFont(ofSize: 18.0, weight: .bold)])

        let intro = NSAttributedString(string: "modalIntroSwift".localized(contentfulService: contentfulService) + " ",
                                       attributes: regularAttributes)

        let githubLink = NSAttributedString(string: "Github".localized(contentfulService: contentfulService),
                                            attributes: regularAttributes + underlineAttributes + [.link: URL(string: "https://github.com/contentful/the-example-app.swift")!])

        let spaceIntro = NSAttributedString(string: "modalSpaceIntro".localized(contentfulService: contentfulService) + " ",
                                            attributes: regularAttributes)

        let spaceLink = NSAttributedString(string: "modalSpaceLinkLabel".localized(contentfulService: contentfulService),
                                           attributes: regularAttributes + underlineAttributes + [.link: URL(string: "https://github.com/contentful/content-models/blob/master/the-example-app/README.md")!])

        let platforms = NSAttributedString(string: "modalPlatforms".localized(contentfulService: contentfulService),
                                           attributes: regularAttributes)

        attributedString.append(title)
        attributedString.append(NSAttributedString(string: "\n\n", attributes: regularAttributes))
        attributedString.append(intro)
        attributedString.append(githubLink)
        attributedString.append(NSAttributedString(string: ".\n\n", attributes: regularAttributes))
        attributedString.append(spaceIntro)
        attributedString.append(spaceLink)
        attributedString.append(NSAttributedString(string: ".\n\n", attributes: regularAttributes))
        attributedString.append(platforms)
        return attributedString
    }
}
