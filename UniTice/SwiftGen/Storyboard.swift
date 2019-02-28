// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

// swiftlint:disable sorted_imports
import Foundation
import UIKit

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// MARK: - Storyboard Scenes

// swiftlint:disable explicit_type_interface identifier_name line_length type_body_length type_name
internal enum StoryboardScene {
  internal enum LaunchScreen: StoryboardType {
    internal static let storyboardName = "LaunchScreen"

    internal static let initialScene = InitialSceneType<UIKit.UIViewController>(storyboard: LaunchScreen.self)
  }
  internal enum Main: StoryboardType {
    internal static let storyboardName = "Main"

    internal static let initialScene = InitialSceneType<UIKit.UINavigationController>(storyboard: Main.self)

    internal static let bookmarkViewController = SceneType<BookmarkViewController>(storyboard: Main.self, identifier: "BookmarkViewController")

    internal static let mainContainerViewController = SceneType<MainContainerViewController>(storyboard: Main.self, identifier: "MainContainerViewController")

    internal static let mainNavigationController = SceneType<UIKit.UINavigationController>(storyboard: Main.self, identifier: "MainNavigationController")

    internal static let searchViewController = SceneType<SearchViewController>(storyboard: Main.self, identifier: "SearchViewController")
  }
  internal enum Setting: StoryboardType {
    internal static let storyboardName = "Setting"

    internal static let changeUniversityViewController = SceneType<ChangeUniversityViewController>(storyboard: Setting.self, identifier: "ChangeUniversityViewController")

    internal static let keywordSettingViewController = SceneType<KeywordSettingViewController>(storyboard: Setting.self, identifier: "KeywordSettingViewController")
  }
  internal enum Start: StoryboardType {
    internal static let storyboardName = "Start"

    internal static let initialScene = InitialSceneType<UIKit.UINavigationController>(storyboard: Start.self)

    internal static let startFinishViewController = SceneType<StartFinishViewController>(storyboard: Start.self, identifier: "StartFinishViewController")

    internal static let startKeywordRegisterViewController = SceneType<StartKeywordRegisterViewController>(storyboard: Start.self, identifier: "StartKeywordRegisterViewController")

    internal static let startNavigationController = SceneType<UIKit.UINavigationController>(storyboard: Start.self, identifier: "StartNavigationController")

    internal static let startUniversitySelectViewController = SceneType<UniversitySelectionViewController>(storyboard: Start.self, identifier: "StartUniversitySelectViewController")
  }
}
// swiftlint:enable explicit_type_interface identifier_name line_length type_body_length type_name

// MARK: - Implementation Details

internal protocol StoryboardType {
  static var storyboardName: String { get }
}

internal extension StoryboardType {
  static var storyboard: UIStoryboard {
    let name = self.storyboardName
    return UIStoryboard(name: name, bundle: Bundle(for: BundleToken.self))
  }
}

internal struct SceneType<T: UIViewController> {
  internal let storyboard: StoryboardType.Type
  internal let identifier: String

  internal func instantiate() -> T {
    let identifier = self.identifier
    guard let controller = storyboard.storyboard.instantiateViewController(withIdentifier: identifier) as? T else {
      fatalError("ViewController '\(identifier)' is not of the expected class \(T.self).")
    }
    return controller
  }
}

internal struct InitialSceneType<T: UIViewController> {
  internal let storyboard: StoryboardType.Type

  internal func instantiate() -> T {
    guard let controller = storyboard.storyboard.instantiateInitialViewController() as? T else {
      fatalError("ViewController is not of the expected class \(T.self).")
    }
    return controller
  }
}

private final class BundleToken {}
