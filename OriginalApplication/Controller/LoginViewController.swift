//
//  LoginViewController.swift
//  OriginalApplication
//
//  Created by 濱田広毅 on 2020/07/10.
//  Copyright © 2020 濱田広毅. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import FacebookCore
import FacebookLogin
import Firebase

class LoginViewController: UIViewController, UITextFieldDelegate, LoginButtonDelegate {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    let accountLogin = AccountLogin()
    let logout = LogOut()
    
    let fbLoginButton:FBLoginButton = FBLoginButton()
    var displayName = String()
    var pictureURL = String()
    var pictureURLString = String()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        fbLoginButton.delegate = self
        fbLoginButton.frame = CGRect(x: view.frame.size.width/2 - view.frame.size.width/4, y: view.frame.size.height/4, width: view.frame.size.width/2, height: 30)
        fbLoginButton.permissions = ["public_profile, email"]
        view.addSubview(fbLoginButton)
        
        // ログアウトメソッド呼び出し
        logout.logout()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        
        if(error == nil)
        {
            if(result?.isCancelled == true)
            {
                return
            }
        }
        
        let credential = FacebookAuthProvider.credential(withAccessToken: AccessToken.current!.tokenString)
        Auth.auth().signIn(with: credential) { (result, error) in
            
            if let error = error
            {
                return
            }
            
            self.displayName = result!.user.displayName!
            self.pictureURLString = result!.user.photoURL!.absoluteString
//            UserDefaults.standard.set(1, forKey: "loginOK")
//            UserDefaults.standard.set(self.displayName, forKey: "displayName")
//            UserDefaults.standard.set(self.pictureURLString, forKey: "pictureURLString")
            
            let homeVC = self.storyboard?.instantiateViewController(identifier: "Home") as! HomeController
            self.navigationController?.pushViewController(homeVC, animated: true)
        }
    }
    
    func loginButtonWillLogin(_ loginButton: FBLoginButton) -> Bool {
        return true
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        
        print("ログアウトしました")
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
