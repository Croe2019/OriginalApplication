//
//  CustomCell.swift
//  OriginalApplication
//
//  Created by 濱田広毅 on 2020/12/27.
//  Copyright © 2020 濱田広毅. All rights reserved.
//

import UIKit

class CustomCell: UICollectionViewCell {
    
    @IBOutlet weak var collectionImage: UIImageView!
    
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
