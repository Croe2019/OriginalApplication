//
//  SetAlarmViewController.swift
//  OriginalApplication
//
//  Created by 濱田広毅 on 2021/05/28.
//  Copyright © 2021 濱田広毅. All rights reserved.
//

import UIKit

class SetAlarmViewController: UIViewController {
    
    @IBOutlet weak var setTimePicker: UIDatePicker!
    
    let alarm = Alarm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTimePicker.datePickerMode = UIDatePicker.Mode.time
        setTimePicker.setDate(Date(), animated: false)
    }
    
    @IBAction func AlarmButtonPressed(_ sender: Any) {
        
        alarm.selectedWakeUPTime = setTimePicker.date
        
        alarm.RunTime()
    }
    
    
    @IBAction func Back(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
