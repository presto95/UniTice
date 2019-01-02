# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'UniTice' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  pod 'Kanna', '~> 4.0.0'
  pod 'Firebase/Core'
  pod 'Firebase/Messaging'
  pod 'Carte'
  pod 'SnapKit', '~> 4.0.0'
  pod 'DZNEmptyDataSet'
  pod 'XLPagerTabStrip', '~> 8.1'
  pod 'RealmSwift'
  # Pods for UniTice
end

post_install do |installer|
  pods_dir = File.dirname(installer.pods_project.path)
  at_exit { `ruby #{pods_dir}/Carte/Sources/Carte/carte.rb configure` }
end
