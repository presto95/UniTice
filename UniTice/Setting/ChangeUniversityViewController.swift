//
//  ChangeSchoolViewController.swift
//  SchoolNoticeNotifier
//
//  Created by Presto on 16/11/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class ChangeUniversityViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    
    private var viewModel = ChangeUniversityViewModel()
    
    @IBOutlet private weak var pickerView: UIPickerView!
    
    @IBOutlet private weak var confirmButton: UIButton! {
        didSet {
            confirmButton.layer.borderColor = UIColor.main.cgColor
            confirmButton.layer.borderWidth = 1
            confirmButton.layer.cornerRadius = confirmButton.bounds.height / 2
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "학교 변경"
        bindUI()
    }
}

private extension ChangeUniversityViewController {
    func bindUI() {
        bindConfirmButton()
        bindPickerViewItemTitles()
        bindPickerViewItemSelected()
    }
    
    func bindConfirmButton() {
        confirmButton.rx.tap.asObservable()
            .subscribe(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                User.updateUniversity(self.viewModel.selectedUniversity.rawValue)
                User.removeBookmarksAll()
                User.removeKeywordsAll()
                UniversityModel.shared.generateModel()
                self.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    func bindPickerViewItemTitles() {
        Observable
            .just(viewModel.universities)
            .bind(to: pickerView.rx.itemTitles) { _, element in
                return element.rawValue
            }
            .disposed(by: disposeBag)
    }
    
    func bindPickerViewItemSelected() {
        pickerView.rx
            .modelSelected(University.self)
            .map { $0.first }
            .subscribe(onNext: { [weak self] university in
                if let university = university {
                    self?.viewModel.selectedUniversity = university
                }
            })
            .disposed(by: disposeBag)
    }
}
