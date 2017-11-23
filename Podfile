#!/usr/bin/ruby

plugin 'cocoapods-keys', {
  :project => 'the-example-app.swift',
  :target => 'the-example-app.swift',
  :keys => [ 'SpaceId',
             'DeliveryAPIAccessToken',
             'PreviewAPIAccessToken']
}

use_frameworks!
platform :ios, "11.0"

target 'the-example-app.swift' do
  pod 'Contentful', :path => '/Users/jpwright/Contentful/swift/SDK/contentful.swift', :branch => 'improvement/usability-improvements'
  pod 'markymark', :path => '/Users/jpwright/Contentful/swift/Dependency/Marky-Mark', :branch => 'hotfix/access-identifiers'

  target 'the-example-app.swiftTests' do
    inherit! :search_paths
  end
end


