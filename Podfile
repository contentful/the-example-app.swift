#!/usr/bin/ruby

use_frameworks!
platform :ios, "11.0"

target 'the-example-app.swift' do
  pod 'Contentful', '~> 1.0.0'
  pod 'Firebase/Core'
  pod 'markymark', :git => 'https://github.com/M2Mobi/Marky-Mark.git', :branch => 'master'
  pod 'AlamofireImage', '~> 3.3'
  pod 'DeepLinkKit'

  target 'the-example-app.swiftTests' do
    inherit! :search_paths
    pod 'Nimble'    
  end

  target 'the-example-app.swiftUITests' do
    inherit! :search_paths
    pod 'Nimble'
  end
end


