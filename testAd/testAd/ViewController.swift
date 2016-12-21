//
//  ViewController.swift
//  testAd
//
//  Created by 木耳ちゃん on 2016/06/14.
//  Copyright © 2016年 NeTGroup. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SCLAlertView
import SVProgressHUD

class ViewController: UIViewController,UITextFieldDelegate{
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var userTextField: UITextField!
    @IBOutlet weak var passTextField: UITextField!
    
    var loading:Bool = false
    
    //判定のため、一時的に保存しておく変数
    var txtActiveField = UITextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userTextField.placeholder = "ユーザー名"
        passTextField.placeholder = "パスワード"
        passTextField.secureTextEntry = true
        //デリゲート設定
        userTextField.delegate = self
        passTextField.delegate = self
        
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(ViewController.keyboardWillShow(_:)),
                                                         name: UIKeyboardWillShowNotification,
                                                         object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(ViewController.keyboardWillHide(_:)),
                                                         name: UIKeyboardWillHideNotification,
                                                         object: nil)
    }
    
    
    func keyboardWillShow(notification: NSNotification) {
        let userInfo = notification.userInfo!
        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        scrollView.contentOffset.y = keyboardScreenEndFrame.size.height
        
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        scrollView.contentOffset.y = 0
    }
    
    
    override func viewDidAppear(animated: Bool) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let i = userDefaults.stringForKey("token"){
            print("保存されています:\(i)")
            presentMainScene()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self,
                                                            name: UIKeyboardWillShowNotification,
                                                            object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self,
                                                            name: UIKeyboardWillHideNotification,
                                                            object: nil)
    }
    func requestToken(){
        SVProgressHUD.setDefaultStyle(.Custom)
        SVProgressHUD.setBackgroundColor(UIColor(red: 245/255, green: 220/255, blue: 215/255, alpha: 1))
        SVProgressHUD.setForegroundColor(UIColor.blackColor())
        SVProgressHUD.showWithStatus("読み込み中")
        
        let user = userTextField.text ?? "none"
        let password = passTextField.text ?? "0000"
        
        let params = [
            "scopes": ["repo"],
            "note":"KikurageChanApp",
            ]
        
        let plainString = "\(user):\(password)" as NSString
        let plainData = plainString.dataUsingEncoding(NSUTF8StringEncoding)
        let base64String = plainData?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
        
        
        
        let hed = [ "Authorization": "Basic \(base64String!)"]
        
        
        Alamofire.request(.POST, "https://api.github.com/authorizations",parameters: params,encoding:.JSON,headers: hed)
            .authenticate(user: user, password: password)
            .responseJSON{ res in
                guard let object = res.result.value else {
                    print("失敗")
                    self.loading = false
                    return
                }
                let json = JSON(object)
                let userDefaults = NSUserDefaults.standardUserDefaults()
                if let token = json["token"].string{
                    userDefaults.setObject(token,forKey:"token")
                    userDefaults.synchronize()
                    SVProgressHUD.dismiss()
                    self.presentMainScene()
                    return
                }
                if json["errors"][0]["code"].string != nil{
                    SCLAlertView().showTitle(
                        "エラー", // タイトル
                        subTitle: "他の端末で既に登録済みです", // サブタイトル
                        duration: 0, // 2.0秒ごに、自動的に閉じる（OKでも閉じることはできる）
                        completeText: "OK", // クローズボタンのタイトル
                        style: .Error, // スタイル（Success)指定
                        colorStyle: 0xf5dcd7, // ボタン、シンボルの色
                        colorTextButton: 0x000000 // ボタンの文字列の色
                    )
                }else{
                    SCLAlertView().showTitle(
                        "エラー", // タイトル
                        subTitle: "IDまたはパスワードが違います", // サブタイトル
                        duration: 0, // 2.0秒ごに、自動的に閉じる（OKでも閉じることはできる）
                        completeText: "OK", // クローズボタンのタイトル
                        style: .Error, // スタイル（Success)指定
                        colorStyle: 0xf5dcd7, // ボタン、シンボルの色
                        colorTextButton: 0x000000 // ボタンの文字列の色
                    )
                }
                self.loading = false
                SVProgressHUD.dismiss()
        }
    }
    
    //テキストフィールドを編集する直前に呼ばれます
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        txtActiveField = textField
        return true
    }
    // キーボードを閉じる
    func textFieldShouldReturn(textField: UITextField) -> Bool{
        self.view.endEditing(true)
        return true
    }
    //画面タップでもキーボードを閉じる
    @IBAction func tapScreen(sender: AnyObject) {
        self.view.endEditing(true)
    }
    
    @IBAction func okButtonAction(sender: AnyObject){
        if !self.loading{
            self.loading = true
            requestToken()
        }
    }
    
    //UserDefaultsに保存されているデータを消去
    func clearUserDefaults(){
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.removeObjectForKey("token")
        userDefaults.synchronize()
    }
    func presentMainScene(){
        let storyboard: UIStoryboard = self.storyboard!
        let nextView = storyboard.instantiateViewControllerWithIdentifier("main") as! MainController
        nextView.modalTransitionStyle = UIModalTransitionStyle.FlipHorizontal
        self.presentViewController(nextView, animated: true, completion: nil)
    }
    
    
}

