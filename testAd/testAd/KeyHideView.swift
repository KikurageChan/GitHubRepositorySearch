//
//  KeyHideView.swift
//  testAd
//
//  Created by 木耳ちゃん on 2016/07/26.
//  Copyright © 2016年 NeTGroup. All rights reserved.
//

import Foundation
import UIKit

class KeyHideView:UIView{
    var touchDelegate: KeyHideViewTouchDelegate?
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.hidden = true
        touchDelegate?.touch()
    }
}
protocol KeyHideViewTouchDelegate {
    func touch()
}