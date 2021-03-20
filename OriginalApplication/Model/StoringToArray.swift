//
//  StoringToArray.swift
//  OriginalApplication
//
//  Created by 濱田広毅 on 2021/03/16.
//  Copyright © 2021 濱田広毅. All rights reserved.
//

import Foundation
import Firebase

class StoringToArray{
    
    var indexIDArray = [String]()
    
    // データを格納
    func storingToArray(){
        
        let ref = Database.database().reference().child("Record").child(Auth.auth().currentUser!.uid).queryLimited(toLast: 100).observe(.value) { (snapShot) in
            
            if let snapShot = snapShot.children.allObjects as? [DataSnapshot]{
                
                for snap in snapShot{
                    
                    // autoIDを追加
                    self.indexIDArray.append(snap.key)
                }
        
            }
            
        }
    }
}
