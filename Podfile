#!/usr/bin/ruby

use_frameworks!
platform :ios, "11.0"
inhibit_all_warnings!

target 'the-example-app.swift' do
  pod 'Contentful', '~> 1.0.1'
  pod 'Firebase/Core'
  pod 'SnowplowTracker'
  pod 'markymark', '~> 4.0.3'
  pod 'AlamofireImage', '~> 3.3'
  pod 'DeepLinkKit'
  pod 'Fabric'
  pod 'Crashlytics'

  target 'the-example-app.swiftTests' do
    inherit! :search_paths
    pod 'Nimble'
    pod 'KIF'
  end
end

