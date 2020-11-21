//
//  LogOut.swift
//  OriginalApplication
//
//  Created by 濱田広毅 on 2020/08/21.
//  Copyright © 2020 濱田広毅. All rights reserved.
//

import Foundation
import Firebase

// ログアウトクラス
class LogOut{
    
    func logout(){
        
        let firebaseAuth = Auth.auth()
        
        do{
            try firebaseAuth.signOut()
        }catch let signOutError as NSError{
            print("Error signing out: %@", signOutError)
        }
    }
}
