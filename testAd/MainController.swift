//
//  MainController.swift
//  testAd
//
//  Created by 木耳ちゃん on 2016/07/18.
//  Copyright © 2016年 NeTGroup. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class MainController: UIViewController,UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate,KeyHideViewTouchDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var keyHideView: KeyHideView!
    
    var fullNames:[String] = []
    var urls:[String] = []
    var token:String = ""
    var dataRequest:Request?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchBar.delegate = self
        self.keyHideView.touchDelegate = self
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let value = userDefaults.stringForKey("token"){
            self.token = value
        }
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(ViewController.keyboardWillShow(_:)),
                                                         name: UIKeyboardWillShowNotification,
                                                         object: nil)
        
    }
    
    func keyboardWillShow(notification: NSNotification) {
        self.keyHideView.hidden = false
    }

    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        let text = searchBar.text ?? ""
        self.fullNames.removeAll()
        self.urls.removeAll()
        getInfo(keyword: text)
    }
    
    //情報を取得
    func getInfo(keyword keyword:String){
        //もしキーワードがnilか空白の場合は検索をかけないでreturn
        dataRequest?.cancel()
        if keyword == "" {
            self.fullNames.removeAll()
            self.urls.removeAll()
            //テーブルの描画処理を実施
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableView.reloadData()
            })
            return
        }
        let header = ["Authorization": "token \(self.token)"]
        let encodeKeyword = keyword.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        let encodedUrl = "https://api.github.com/search/repositories?q=\(encodeKeyword!)&per_page=10"
        dataRequest = Alamofire.request(.GET, encodedUrl,headers: header)
            .responseJSON { res in
                guard let object = res.result.value else {
                    print("失敗")
                    return
                }
                let json = JSON(object)
                //もしアクセストークンでデータを取得できなかった場合
                if json["message"].string == "Bad credentials"{
                    let storyboard: UIStoryboard = self.storyboard!
                    let nextView = storyboard.instantiateViewControllerWithIdentifier("login") as! ViewController
                    nextView.modalTransitionStyle = UIModalTransitionStyle.FlipHorizontal
                    self.presentViewController(nextView, animated: true, completion: nil)
                    let userDefaults = NSUserDefaults.standardUserDefaults()
                    userDefaults.removeObjectForKey("token")
                    userDefaults.synchronize()
                    return
                }
                //テーブルの描画処理を実施
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    for i in 0..<json["items"].count{
                        self.fullNames.append(json["items"][i]["full_name"].string!)
                        self.urls.append(json["items"][i]["html_url"].string!)
                    }
                    self.tableView.reloadData()
                })
            }
    }
    //cellを選択された時
    func tableView(table: UITableView, didSelectRowAtIndexPath indexPath:NSIndexPath) {
        let storyboard: UIStoryboard = self.storyboard!
        let readVC = storyboard.instantiateViewControllerWithIdentifier("read") as! readController
        readVC.url = self.urls[indexPath.row]
        readVC.titleName = self.fullNames[indexPath.row]
        readVC.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        self.presentViewController(readVC, animated: true, completion: nil)
    }
    //KeyHideViewがタッチされた時の処理
    func touch() {
        self.view.endEditing(true)
    }
    
    
    //テーブルの行数を返却
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fullNames.count
    }
    //テーブルの行ごとのセルを返却する
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath:indexPath) as! MyCell
        cell.label.text = fullNames[indexPath.row]
        return cell
    }

}
