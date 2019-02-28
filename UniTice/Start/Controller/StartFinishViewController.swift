//
//  StartFinishViewController.swift
//  UniTice
//
//  Created by Presto on 19/12/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import UIKit

import ReactorKit
import RxCocoa
import RxSwift

final class StartFinishViewController: UIViewController, StoryboardView {
  
  var disposeBag: DisposeBag = DisposeBag()
  
  @IBOutlet weak var universityLabel: UILabel!
  
  @IBOutlet weak var keywordLabel: UILabel! {
    didSet {
      let keywords = InitialInfo.shared.keywords
      if keywords.isEmpty {
        keywordLabel.text = "없음"
      } else {
        var result = ""
        for (index, keyword) in keywords.enumerated() {
          if index + 1 == keywords.count {
            result += keyword
          } else {
            result += keyword + ", "
          }
        }
        keywordLabel.text = result
      }
    }
  }
  
  @IBOutlet private weak var confirmButton: UTButton!
  
  @IBOutlet private weak var backButton: UTButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
  }
  
  func bind(reactor: FinishViewReactor) {
    confirmButton.rx.tap
      .map { Reactor.Action.touchUpConfirmButton }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    backButton.rx.tap
      .map { Reactor.Action.touchUpBackButton }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    reactor.state.map { $0.isConfirmButtonSelected }
      .distinctUntilChanged()
      .filter { $0 }
      .subscribe(onNext: { [weak self] _ in
        guard let self = self else { return }
        let mainViewController = StoryboardScene.Main.mainNavigationController.instantiate()
        mainViewController.modalTransitionStyle = .flipHorizontal
        mainViewController.present(to: self)
      })
      .disposed(by: disposeBag)
    reactor.state.map { $0.isBackButtonSelected }
      .distinctUntilChanged()
      .filter { $0 }
      .subscribe(onNext: { [weak self] _ in
        guard let self = self else { return }
        self.navigationController?.popViewController(animated: true)
      })
      .disposed(by: disposeBag)
  }
  
  private func setup() {
    universityLabel.text = InitialInfo.shared.university.rawValue
    confirmButton.type = .next
    backButton.type = .back
  }
  
//  @objc private func confirmButtonDidTap(_ sender: UIButton) {
//    let university = InitialInfo.shared.university.rawValue
//    let keywords = InitialInfo.shared.keywords
//    let user = User()
//    user.university = university
//    user.keywords.append(objectsIn: keywords)
//    User.addUser(user)
//    UniversityModel.shared.generateModel()
//    let next = UIViewController.instantiate(from: "Main", identifier: "MainNavigationController")
//    next.modalTransitionStyle = .flipHorizontal
//    present(next, animated: true, completion: nil)
//  }
//
//  @objc private func backButtonDidTap(_ sender: UIButton) {
//    navigationController?.popViewController(animated: true)
//  }
}
