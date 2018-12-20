//
//  StartUniversitySelectViewController.swift
//  UniTice
//
//  Created by Presto on 19/12/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import UIKit

class StartUniversitySelectViewController: UIViewController {

    private let universities = University.allCases
    
    @IBOutlet weak var pickerView: UIPickerView! {
        didSet {
            pickerView.delegate = self
            pickerView.dataSource = self
        }
    }
    
    @IBOutlet weak var confirmButton: StartConfirmButton! {
        didSet {
            confirmButton.addTarget(self, action: #selector(touchUpConfirmButton(_:)), for: .touchUpInside)
        }
    }
    
    @IBOutlet weak var backButton: StartBackButton! {
        didSet {
            backButton.addTarget(self, action: #selector(touchUpBackButton(_:)), for: .touchUpInside)
        }
    }
    
    @objc private func touchUpConfirmButton(_ sender: UIButton) {
        let universityIndex = pickerView.selectedRow(inComponent: 0)
        print(universityIndex, universities[universityIndex])
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
