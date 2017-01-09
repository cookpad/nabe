#
# Be sure to run `pod lib lint Nabe.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Nabe'
  s.version          = '0.1.0'
  s.summary          = 'Network and model Layers for Cookpad Global-iOS'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
                       Nabe is an abstraction layer that covers network and model layers for Cookpad Global-iOS.
                       DESC
  s.homepage         = 'https://github.com/cookpad/nabe'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Kittinun Vantasin' => 'kittinun.f@gmail.com' }
  s.source           = { :git => 'https://github.com/cookpad/nabe.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.default_subspec = "Core"

  s.subspec "Core" do |ss|
    ss.source_files  = "Sources/Core/"
    ss.dependency "Result", "~> 3.1.0"
    ss.framework  = "Foundation"
  end

  s.subspec "RxSwift" do |ss|
    ss.source_files = "Sources/RxSwift/"
    ss.dependency "Nabe/Core"
    ss.dependency "RxSwift", "~> 3.1.0"
  end

  # s.resource_bundles = {
  #   'Nabe' => ['Nabe/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
