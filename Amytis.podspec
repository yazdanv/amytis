#
# Be sure to run `pod lib lint DataExtYazdan.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Amytis'
  s.version          = '0.1'
  s.summary          = 'Yazdan Amytis framework'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = "manupulate data with some ext and protocols"

  s.homepage         = 'https://gitlab.com/yIOS/amytis'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Yazdan' => 'ymazdy@gmail.com' }
  s.source           = { :git => 'https://gitlab.com/yIOS/amytis.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.3'
  s.watchos.deployment_target = '4.0'
  # s.osx.deployment_target = '10.11'

  s.watchos.source_files = 'AmytisWatch/**/*'
  s.ios.source_files = 'Amytis/View/**/*',
    'Amytis/CodeManager/**/*',
    'Amytis/Controller/**/*',
    'Amytis/SizingAndFrame/**/*',
    'Amytis/CoreModules/**/*',
    'Amytis/Protocols/**/*',
     'Amytis/Constants/**/*',
      'Amytis/Extension/**/*',
       'Amytis/Handlers/**/*',
        'Amytis/JS/**/*',
         'Amytis/Model/**/*',
          'Amytis/ViewTypes/**/*'

  s.ios.resource_bundles = {
    'Amytis' => ['Resources/*/*.*']
  }

  s.watchos.resource_bundles = {
    'AmytisWatch' => ['WatchResources/*/*.*']
  }


  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.ios.dependency 'Socket.IO-Client-Swift', '12.0.0'

end
