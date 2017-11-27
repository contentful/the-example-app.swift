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
  pod 'Contentful', '~> 1.0.0-beta3'
  pod 'markymark', :git => 'https://github.com/M2Mobi/Marky-Mark.git', :branch => 'master'

  target 'the-example-app.swiftTests' do
    inherit! :search_paths
  end
end


