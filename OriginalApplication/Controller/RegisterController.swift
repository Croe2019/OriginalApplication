//
//  RegisterController.swift
//  OriginalApplication
//
//  Created by 濱田広毅 on 2020/07/19.
//  Copyright © 2020 濱田広毅. All rights reserved.
//

import UIKit

class RegisterController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var EmailTextField: UITextField!
    @IBOutlet weak var PasswordTextField: UITextField!
    
    let register = Register()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        EmailTextField.delegate = self
        PasswordTextField.delegate = self
    }
    

    
    @IBAction func RegisterNewUser(_ sender: Any) {
        
        // 新規登録
        register.Register(email: EmailTextField.text!, password: PasswordTextField.text!)
        
        // ホーム画面へ遷移
        performSegue(withIdentifier: "Home", sender: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        EmailTextField.resignFirstResponder()
        PasswordTextField.resignFirstResponder()
        
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}
