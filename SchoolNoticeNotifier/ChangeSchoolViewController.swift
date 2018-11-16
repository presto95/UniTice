//
//  ChangeSchoolViewController.swift
//  SchoolNoticeNotifier
//
//  Created by Presto on 16/11/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import UIKit
import SnapKit

class ChangeSchoolViewController: UIViewController {
    
    private var schools = School.allCases
    lazy private var pickerView: UIPickerView! = {
        let pickerView = UIPickerView()
        view.addSubview(pickerView)
        pickerView.showsSelectionIndicator = false
        pickerView.delegate = self
        return pickerView
    }()
    lazy private var button: UIButton! = {
        let button = UIButton(type: .system)
        view.addSubview(button)
        button.setTitle("확인", for: [])
        button.addTarget(self, action: #selector(touchUpButton(_:)), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "학교 변경"
        view.backgroundColor = .white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        pickerView.snp.makeConstraints { maker in
            maker.height.equalTo(300)
            maker.leading.equalTo(view.snp.leading).offset(16)
            maker.trailing.equalTo(view.snp.trailing).offset(-16)
            maker.center.equalTo(view.snp.center)
        }
    }
    
    @objc func touchUpButton(_ sender: UIButton) {
        
    }
}

extension ChangeSchoolViewController: UIPickerViewDataSource {
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return schools.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
}

extension ChangeSchoolViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return schools[row].rawValue
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print(schools[row].rawValue)
    }
}
