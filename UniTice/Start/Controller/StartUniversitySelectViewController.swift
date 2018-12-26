//
//  StartUniversitySelectViewController.swift
//  UniTice
//
//  Created by Presto on 19/12/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import UIKit

class StartUniversitySelectViewController: UIViewController {

    private let universities = University.allCases.sorted { $0.rawValue < $1.rawValue }
    
    @IBOutlet private weak var pickerView: UIPickerView! {
        didSet {
            pickerView.delegate = self
            pickerView.dataSource = self
        }
    }
    
    @IBOutlet private weak var noneButton: UIButton! {
        didSet {
            noneButton.addTarget(self, action: #selector(touchUpNoneButton(_:)), for: .touchUpInside)
        }
    }
    
    @IBOutlet private weak var confirmButton: StartConfirmButton! {
        didSet {
            confirmButton.addTarget(self, action: #selector(touchUpConfirmButton(_:)), for: .touchUpInside)
        }
    }
    
    @IBOutlet private weak var backButton: StartBackButton! {
        didSet {
            backButton.addTarget(self, action: #selector(touchUpBackButton(_:)), for: .touchUpInside)
        }
    }
    
    @objc private func touchUpNoneButton(_ sender: UIButton) {
        // 공식계정으로 메일 보내게끔 해서 학교 수요 알아볼수도?
    }
    
    @objc private func touchUpConfirmButton(_ sender: UIButton) {
        let universityIndex = pickerView.selectedRow(inComponent: 0)
        InitialInfo.shared.university = universities[universityIndex]
        let next = UIViewController.instantiate(from: "Start", identifier: StartKeywordRegisterViewController.classNameToString)
        navigationController?.pushViewController(next, animated: true)
    }
    
    @objc private func touchUpBackButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}

extension StartUniversitySelectViewController: UIPickerViewDataSource {
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return universities.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
}

extension StartUniversitySelectViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return universities[row].rawValue
    }
}
