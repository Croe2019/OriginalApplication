//
//  LoginViewController.swift
//  OriginalApplication
//
//  Created by 濱田広毅 on 2020/07/10.
//  Copyright © 2020 濱田広毅. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    let accountLogin = AccountLogin()
    let logout = LogOut()
    
    var displayName = String()
    var pictureURL = String()
    var pictureURLString = String()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        // ログアウトメソッド呼び出し
        logout.logout()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    
    @IBAction func Login(_ sender: Any) {
    
        accountLogin.AccountLogin(email: emailTextField.text!, password: passwordTextField.text!)
        
        performSegue(withIdentifier: "Home", sender: nil)
    
    }
    
    
    
    @IBAction func RegisterSceneMove(_ sender: Any) {
        
        performSegue(withIdentifier: "Register", sender: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.view.endEditing(true)
    }
}
