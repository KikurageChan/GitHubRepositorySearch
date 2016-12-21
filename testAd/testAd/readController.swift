//
//  readController.swift
//  testAd
//
//  Created by 木耳ちゃん on 2016/07/26.
//  Copyright © 2016年 NeTGroup. All rights reserved.
//

import UIKit
import WebKit

class readController: UIViewController {

    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    var webView:WKWebView!
    var webViewSingle:Bool = false
    
    var titleName:String = ""
    var url:String = "https://www.google.co.jp/"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleLabel.text = titleName
        self.webView = WKWebView()
        self.baseView.addSubview(self.webView)
        self.webView.allowsBackForwardNavigationGestures = true
        load(url)
    }
    override func viewDidLayoutSubviews() {
        if !webViewSingle{
            self.webViewSingle = true
            self.webView.frame = self.baseView.bounds
        }
    }
    func load(url:String){
        let queryUrl = NSURL(string:url)
        let req = NSURLRequest(URL: queryUrl!)
        self.webView.loadRequest(req)
    }
    @IBAction func backAction(sender: AnyObject) {
         self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
