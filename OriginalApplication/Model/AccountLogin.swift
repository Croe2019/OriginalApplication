//
//  Login.swift
//  OriginalApplication
//
//  Created by 濱田広毅 on 2020/07/20.
//  Copyright © 2020 濱田広毅. All rights reserved.
//

import Foundation
import Firebase

class AccountLogin
{
   
    func AccountLogin(email:String, password:String)
    {
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            
            if(error != nil)
            {
                print(error as Any)
            }
            else
            {
                print("ログイン成功")
            }
        }
    }
}
