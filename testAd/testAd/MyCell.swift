//
//  MyCell.swift
//  testAd
//
//  Created by 木耳ちゃん on 2016/07/24.
//  Copyright © 2016年 NeTGroup. All rights reserved.
//

import Foundation
import UIKit

class MyCell:UITableViewCell{
    
    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        self.label.text = nil
    }

}
