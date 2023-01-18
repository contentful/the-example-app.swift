> **Note**: This repo is no longer officially maintained as of Jan, 2023.
> Feel free to use it, fork it and patch it for your own needs.

## The Swift example app

[![CircleCI](https://circleci.com/gh/contentful/the-example-app.swift.svg?style=svg)](https://circleci.com/gh/contentful/the-example-app.swift)

The Swift example app teaches the very basics of how to work with Contentful:

- consume content from the Contentful Delivery and Preview APIs
- model content
- edit content through the Contentful web app

The app demonstrates how decoupling content from its presentation enables greater flexibility and facilitates shipping higher quality software more quickly.

<img src="https://images.contentful.com/fmjk18k0dyyi/6JbDu02xHimOua0wsyOywg/626164f9c6e3c59383f340d278e0ec06/Screen_Shot_2018-01-29_at_15.24.53.png" alt="Screenshot of the example app"/>

You can see a hosted version of `The Swift example app` on the <a href="https://itunes.apple.com/us/app/the-example-app-swift/id1333721890" target="_blank">App Store</a>.

## What is Contentful?

[Contentful](https://www.contentful.com) provides a content infrastructure for digital teams to power content in websites, apps, and devices. Unlike a CMS, Contentful was built to integrate with the modern software stack. It offers a central hub for structured content, powerful management and delivery APIs, and a customizable web app that enable developers and content creators to ship digital products faster.

## Requirements

* Xcode 9
* Git
* Contentful CLI (only for write access)
* Ruby

Without any changes, this app is connected to a Contentful space with read-only access. To experience the full end-to-end Contentful experience, you need to connect the app to a Contentful space with read _and_ write access. This enables you to see how content editing in the Contentful web app works and how content changes propagate to this app.

## Common setup

Clone the repo and install the dependencies.

```bash
git clone https://github.com/contentful/the-example-app.swift.git
```

```bash
bundle install
bundle exec pod install
```

## Steps for read-only access

Open `the-example-app.swift.xcworkspace` in Xcode and run the app on a simulator or device.

## Steps for read and write access (recommended)

Step 1: Install the [Contentful CLI](https://www.npmjs.com/package/contentful-cli)

Step 2: Login to Contentful through the CLI. It will help you to create a [free account](https://www.contentful.com/sign-up/) if you don't have one already.
```
contentful login
```
Step 3: Create a new space
```
contentful space create --name 'My space for the example app'
```
Step 4: Seed the new space with the content model. Replace the `SPACE_ID` with the id returned from the create command executed in step 3
```
contentful space seed -s '<SPACE_ID>' -t the-example-app
```
Step 5: Head to the Contentful web app's API section and grab `SPACE_ID`, `DELIVERY_ACCESS_TOKEN`, `PREVIEW_ACCESS_TOKEN`.

Step 6: Open `variables.xcconfig` and inject your credentials so it looks like this

```
CONTENTFUL_SPACE_ID=<SPACE_ID>
CONTENTFUL_DELIVERY_TOKEN=<DELIVERY_ACCESS_TOKEN>
CONTENTFUL_PREVIEW_TOKEN=<PREVIEW_ACCESS_TOKEN>
```

Step 7: Open `the-example-app.swift.xcworkspace` in Xcode and run the app on a simulator or device. Navigate to settings and enable editorial features and then take a look around the app.

Enabling editorial features will reveal which pieces of content are drafts or pending changes in your Contentful space.

