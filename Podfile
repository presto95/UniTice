# Uncomment the next line to define a global platform for your project
platform :ios, '11.0'

target 'UniTice' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  pod 'Carte'
  pod 'Firebase/Core'
  pod 'Firebase/Messaging'
  pod 'Kanna'
  pod 'ReactorKit'
  pod 'RealmSwift'
  pod 'RxCocoa'
  pod 'RxDataSources'
  pod 'RxGesture'
  pod 'RxOptional'
  pod 'RxSwift'
  pod 'RxViewController'
  pod 'SnapKit'
  pod 'Then'
  pod 'XLPagerTabStrip'
end

post_install do |installer|
  pods_dir = File.dirname(installer.pods_project.path)
  at_exit { `ruby #{pods_dir}/Carte/Sources/Carte/carte.rb configure` }
end
