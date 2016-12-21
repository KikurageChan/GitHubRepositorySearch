# Uncomment this line to define a global platform for your project
# platform :ios, '8.0'
# Uncomment this line if you're using Swift
use_frameworks!

target 'testAd' do

platform :ios, '8.0'

pod 'Alamofire', '3.5.1'
pod 'SwiftyJSON', '2.4.0'
pod 'SCLAlertView', '0.6.0'
pod 'SVProgressHUD'

post_install do |installer|
  installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
          config.build_settings['SWIFT_VERSION'] = '2.3'
      end
   end
end

end
