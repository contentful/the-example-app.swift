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
  pod 'Contentful', :git => '/Users/jpwright/Contentful/swift/SDK/contentful.swift', :branch => 'improvement/usability-improvements'
  pod 'markymark'

  target 'the-example-app.swiftTests' do
    inherit! :search_paths
  end
end


