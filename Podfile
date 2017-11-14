#!/usr/bin/ruby

plugin 'cocoapods-keys', {
  :project => 'the-example-app.swift',
  :target => 'the-example-app.swift',
  :keys => [ 'SpaceId', 'DeliveryAPIAccessToken' ]
}

use_frameworks!
platform :ios, "8.0"

target 'the-example-app.swift' do
  pod 'Contentful', '~> 1.0.0-beta2'
  pod 'Down'
end


