//
//  LoginViewController.swift
//  OriginalApplication
//
//  Created by 濱田広毅 on 2020/07/10.
//  Copyright © 2020 濱田広毅. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import AuthenticationServices
import CryptoKit
import PKHUD

class LoginViewController: UIViewController, UITextFieldDelegate, GIDSignInDelegate, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    let accountLogin = AccountLogin()
   
    var displayName = String()
    var pictureURL = String()
    var pictureURLString = String()
    var currentNonce:String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        GIDSignIn.sharedInstance()?.delegate = self
        GIDSignIn.sharedInstance()?.presentingViewController = self
       
        let appleButton = ASAuthorizationAppleIDButton(authorizationButtonType: .signIn, authorizationButtonStyle: .black)
        appleButton.frame = CGRect(x: 56, y: 190, width: 120, height: 50)
        appleButton.addTarget(self, action: #selector(tap), for: .touchUpInside)
        view.addSubview(appleButton)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    @objc private func tap(){
        
        startSignInWithAppleFlow()
    }
    
    private func startSignInWithAppleFlow(){
        
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let nonce = randomNonceString()
        currentNonce = nonce
        request.nonce = sha256(nonce)
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }

    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            return
        }
        
        switch authorization.credential {
        
        case let credentials as ASAuthorizationAppleIDCredential:
            
            
            break
        default:
            break
        }
        
        guard let nonce = currentNonce else {
            fatalError("Invalid state: A login callback was received, but no login request was sent.")
        }
        guard let appleIDToken = appleIDCredential.identityToken else {
            print("Unable to fetch identity token")
            return
        }
        
        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
            return
        }
        
        let credential = OAuthProvider.credential(
            withProviderID: "apple.com",
            idToken: idTokenString,
            rawNonce: nonce
        )
        // Firebaseへのログインを
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                print(error)
                HUD.flash(.labeledError(title: "予期せぬエラー", subtitle: "再度お試しください。"), delay: 0)
                return
            }
            if let authResult = authResult {
                
                HUD.flash(.labeledSuccess(title: "ログイン完了", subtitle: nil), onView: self.view, delay: 0) { _ in
                    
                    self.performSegue(withIdentifier: "Home", sender: nil)
                   
                }
            }
        }
        
    }
    
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("エラー",error)
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
    
    @IBAction func Login(_ sender: Any) {
    
        accountLogin.AccountLogin(email: emailTextField.text!, password: passwordTextField.text!)
        performSegue(withIdentifier: "Home", sender: nil)
    
    }
    
    
    @IBAction func googleLogin(_ sender: Any) {
        GIDSignIn.sharedInstance()?.signIn()
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        
        if let error = error {
            print("Error: \(error.localizedDescription)")
            return
        }
        let authentication = user.authentication
        // Googleのトークンを渡し、Firebaseクレデンシャルを取得する。
        let credential = GoogleAuthProvider.credential(withIDToken: (authentication?.idToken)!,accessToken: (authentication?.accessToken)!)
        
        // Firebaseにログインする。
        Auth.auth().signIn(with: credential) { (user, error) in
            print("ログイン成功")
            //画面遷移処理
            self.performSegue(withIdentifier: "Home", sender: nil)
        }
    }
    //エラー処理
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        print("Sign off successfully")
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
