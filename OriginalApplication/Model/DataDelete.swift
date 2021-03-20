//
//  DataDelete.swift
//  OriginalApplication
//
//  Created by 濱田広毅 on 2021/03/06.
//  Copyright © 2021 濱田広毅. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth

// データベースにあるデータを削除するクラス
class DataDelete{
    
    func dataDelete(autoIDArray:[String], indexNumber:Int){
        
        let ref = Database.database().reference()
        
        let authHandle = Auth.auth().addStateDidChangeListener { (auth, user) in
            
            ref.child("Record").child(user!.uid).child(autoIDArray[indexNumber]).removeValue()
        }
    }
    
}
