//
//  ChangeSchoolViewController.swift
//  SchoolNoticeNotifier
//
//  Created by Presto on 16/11/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import UIKit
import SnapKit

class ChangeUniversityViewController: UIViewController {
    
    private var universities = University.allCases
    
    @IBOutlet private weak var pickerView: UIPickerView! {
        didSet {
            pickerView.delegate = self
        }
    }
    
    @IBOutlet private weak var confirmButton: UIButton! {
        didSet {
            confirmButton.addTarget(self, action: #selector(touchUpConfirmButton(_:)), for: .touchUpInside)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "학교 변경"
        
    }

    @objc private func touchUpConfirmButton(_ sender: UIButton) {
        let selectedIndex = pickerView.selectedRow(inComponent: 0)
        User.updateUniversity(universities[selectedIndex].rawValue)
        User.removeBookmarksAll()
        User.removeKeywordsAll()
        navigationController?.popViewController(animated: true)
    }
}

extension ChangeUniversityViewController: UIPickerViewDataSource {
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return universities.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
}

extension ChangeUniversityViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return universities[row].rawValue
    }
}
