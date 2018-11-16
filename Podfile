# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'SchoolNoticeNotifier' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  pod 'Kanna', '~> 4.0.0'
  pod 'Alamofire', '~> 4.7'
  pod 'SwiftLint'
  pod 'MarqueeLabel/Swift'
  pod 'Firebase/Core'
  pod 'Firebase/Messaging'
  pod 'Carte'
  pod 'SnapKit', '~> 4.0.0'
  pod 'SkeletonView'
  pod 'DZNEmptyDataSet'
  # Pods for SchoolNoticeNotifier

post_install do |installer|
  pods_dir = File.dirname(installer.pods_project.path)
  at_exit { `ruby #{pods_dir}/Carte/Sources/Carte/carte.rb configure` }
end
end
