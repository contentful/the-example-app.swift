#!/usr/bin/ruby

use_frameworks!
platform :ios, "11.0"

target 'the-example-app.swift' do
  pod 'Contentful', :path => '/Users/loudmouth/Professional/Contentful/contentful.swift', :branch => 'improvement/errors'
  pod 'markymark', :git => 'https://github.com/M2Mobi/Marky-Mark.git', :branch => 'master'
  pod 'AlamofireImage', '~> 3.3'
  pod 'DeepLinkKit', :git => 'https://github.com/button/DeepLinkKit/', :tag => '1.5.0'

  target 'the-example-app.swiftTests' do
    inherit! :search_paths
  end

  target 'the-example-app.swiftUITests' do
    inherit! :search_paths
    pod 'Nimble'
  end
end


