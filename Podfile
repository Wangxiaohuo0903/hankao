platform :ios, "10.0"
use_frameworks!
abstract_target 'Chinese' do
    pod 'SDWebImage'
    pod 'ObjectMapper'
    pod 'Alamofire'
    pod 'SwiftyJSON'
    pod 'NVActivityIndicatorView'
    pod 'UICountingLabel'
    pod 'ReachabilitySwift'
    pod 'CocoaLumberjack/Swift'
    pod "DXPopover"
    pod 'YYText'
    pod 'KeychainAccess'
    pod 'DCAnimationKit'
    pod 'MJRefresh', '~> 3.1.15.3'
    pod 'AGGeometryKit+POP'
    pod 'FBSDKLoginKit'
    pod 'SnapKit', '~> 5.0.0'

    target 'ChineseDev' do
    end
    target 'ChineseStaging' do
    end
    target 'Microsoft Learn Chinese' do
    end
end
post_install do |installer|
  installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['SWIFT_VERSION'] = '4.2'
      end
  end
end

