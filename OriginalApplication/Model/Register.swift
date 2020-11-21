//
//  Register.swift
//  OriginalApplication
//
//  Created by 濱田広毅 on 2020/07/19.
//  Copyright © 2020 濱田広毅. All rights reserved.
//

import Foundation
import Firebase

class Register
{
    
    
    func Register(email:String, password:String)
    {
        
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            
            if(error != nil)
            {
                print(error as Any)
            }
            else
            {
                print("ユーザーの作成が成功しました")
                
            }
        }
    }
}
