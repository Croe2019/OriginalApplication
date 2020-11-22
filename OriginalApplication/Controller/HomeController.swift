//
//  HomeController.swift
//  OriginalApplication
//
//  Created by 濱田広毅 on 2020/07/19.
//  Copyright © 2020 濱田広毅. All rights reserved.
//

import UIKit
import Firebase
import FSCalendar
import CalculateCalendarLogic

class HomeController: UIViewController, UITableViewDelegate, UITableViewDataSource, FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    
    @IBOutlet weak var memoTableView: UITableView!
    @IBOutlet weak var calendar: FSCalendar!
    
    
    var memoArray = [Memo]()
    
    var memoTitle = String()
    var memoTextBody = String()
    // 画像のURLの値を渡す
    var memoImageString = String()
    // テストコード indexNumberにtableViewにあるメモのautoID番号を入れる Int型にしているのは数字で判別する為
    // String型の方が良い場合はString型へ変更
    var indexNumber = Int()
    
    // autoID表示用配列
    var autoIDArray = [String]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        memoTableView.delegate = self
        memoTableView.dataSource = self
        
        calendar.dataSource = self
        calendar.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let ref = Database.database().reference()
        
        self.memoArray.removeAll()
        self.memoTableView.reloadData()
        // テストコード 処理順を変更 最初にログインしたユーザーを確認後データを読み込む
        let authHandle = Auth.auth().addStateDidChangeListener { (auth, user) in
            
            if let user = user?.uid{
                
                let ref = Database.database().reference().child("Record").child(Auth.auth().currentUser!.uid).queryLimited(toFirst: 100).observe(.value) { (snapShot) in
                    
                    if let snapShot = snapShot.children.allObjects as? [DataSnapshot]{
                        
                        for snap in snapShot{
                            
                            if let memoData = snap.value as? [String:Any]{
                                
                                let memoTitle = memoData["memoTitle"] as? String
                                let memoTextData = memoData["memoBody"] as? String
                                let memoImageData = memoData["memoImage"] as? String
                                
                                if(memoImageData != "" && memoTitle != "" && memoTextData != ""){
                                    
                                    self.FeachData()
                                    
                                }
                                else if(memoImageData != "" && memoTitle == "" && memoTextData == ""){
                                    
                                    self.FetchImageData()
                                }
                                else if(memoTextData != "" && memoTitle != "" && memoImageData == ""){
                                    
                                    self.FetchTextData()
                                }
                            }
                            
                        }
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    fileprivate let gregorian: Calendar = Calendar(identifier: .gregorian)
    fileprivate lazy var dateFormatter: DateFormatter = {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    // 祝日判定を行い結果を返すメソッド(True:祝日)
        func judgeHoliday(_ date : Date) -> Bool {
            //祝日判定用のカレンダークラスのインスタンス
            let tmpCalendar = Calendar(identifier: .gregorian)

            // 祝日判定を行う日にちの年、月、日を取得
            let year = tmpCalendar.component(.year, from: date)
            let month = tmpCalendar.component(.month, from: date)
            let day = tmpCalendar.component(.day, from: date)

            // CalculateCalendarLogic()：祝日判定のインスタンスの生成
            let holiday = CalculateCalendarLogic()

            return holiday.judgeJapaneseHoliday(year: year, month: month, day: day)
        }
        // date型 -> 年月日をIntで取得
        func getDay(_ date:Date) -> (Int,Int,Int){
            let tmpCalendar = Calendar(identifier: .gregorian)
            let year = tmpCalendar.component(.year, from: date)
            let month = tmpCalendar.component(.month, from: date)
            let day = tmpCalendar.component(.day, from: date)
            return (year,month,day)
        }
    
    //曜日判定(日曜日:1 〜 土曜日:7)
        func getWeekIdx(_ date: Date) -> Int{
            let tmpCalendar = Calendar(identifier: .gregorian)
            return tmpCalendar.component(.weekday, from: date)
        }

        // 土日や祝日の日の文字色を変える
        func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
            //祝日判定をする（祝日は赤色で表示する）
            if self.judgeHoliday(date){
                return UIColor.red
            }

            //土日の判定を行う（土曜日は青色、日曜日は赤色で表示する）
            let weekday = self.getWeekIdx(date)
            if weekday == 1 {   //日曜日
                return UIColor.red
            }
            else if weekday == 7 {  //土曜日
                return UIColor.blue
            }

            return nil
        }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        let selectDay = getDay(date)
    }
    
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return memoArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = memoTableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel!.text = memoArray[indexPath.row].GetTextTitle()
    
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        memoTitle = memoArray[indexPath.row].GetTextTitle()
        memoTextBody = memoArray[indexPath.row].GetTextMemoData()
        
        memoImageString = memoArray[indexPath.row].GetImageString()
        // テストコード 2番号を格納
        indexNumber = indexPath.row
        print("autoID",indexNumber)
        
        performSegue(withIdentifier: "Detail", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // 複数の画面遷移をする為、エラー防止
        if(segue.identifier == "Detail"){
            
            let detailVC = segue.destination as! DetailViewController
            detailVC.memoTextTitleString = memoTitle
            detailVC.memoTextBodyString = memoTextBody
            // 画像の値を渡す
            detailVC.memoImageString = memoImageString
            // テストコード 詳細画面へ値を渡す
            detailVC.indexNumber = indexNumber
            
        }
        
    }
    
    // テストコード
    func FeachData(){
        
        let ref = Database.database().reference().child("Record").child(Auth.auth().currentUser!.uid).queryLimited(toLast: 100).observe(.value) { (snapShot) in
            
            self.memoArray.removeAll()
            
            if let snapShot = snapShot.children.allObjects as? [DataSnapshot]{
                
                for snap in snapShot{
                    
                    if let memoData = snap.value as? [String:Any]{
                        
                        let memoTitle = memoData["memoTitle"] as? String
                        let memoTextData = memoData["memoBody"] as? String
                        let memoImageString = memoData["memoImage"] as? String
                        
                        self.memoArray.append(Memo.init(textTitle: memoTitle!, textMemoData: memoTextData!, memoImageString: memoImageString!))
                    }
                }
                
            }
            
            self.memoTableView.reloadData()
        }
    }
    
    // キー値を取得しないでデータを取得
    func FetchImageData(){
        
        let ref = Database.database().reference().child("Record").child(Auth.auth().currentUser!.uid).queryLimited(toLast: 100).observe(.value) { (snapShot) in
            
            self.memoArray.removeAll()
            
            if let snapShot = snapShot.children.allObjects as? [DataSnapshot]{
                
                for snap in snapShot{
                    
                    if let memoData = snap.value as? [String:Any]{
                        
                        // 画像の値を渡す為、memoImageStringに画像のキー値を入れる
                        let memoImageString = memoData["memoImage"] as? String
                        
                        self.memoArray.append(Memo.init(memoImageString: memoImageString!))
                       
                    }
                    
                }
                
            }
            
            self.memoTableView.reloadData()
        }
        
    }
    
    // キー値を指定して、データを取得
    func FetchTextData(){
        
        let ref = Database.database().reference().child("Record").child(Auth.auth().currentUser!.uid).queryLimited(toLast: 100).observe(.value) { (snapShot) in
            
            self.memoArray.removeAll()
            
            if let snapShot = snapShot.children.allObjects as? [DataSnapshot]{
                
                for snap in snapShot{
                    
                    if let memoData = snap.value as? [String:Any]{
                        
                        let memoTitle = memoData["memoTitle"] as? String
                        let memoTextData = memoData["memoBody"] as? String
                        
                        self.memoArray.append(Memo.init(textTitle: memoTitle!, textMemoData: memoTextData!))
                    }
                }
                
            }
            
            self.memoTableView.reloadData()
        }
    }
}
