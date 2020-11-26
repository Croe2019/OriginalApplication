//
//  SearchResultViewController.swift
//  OriginalApplication
//
//  Created by 濱田広毅 on 2020/11/26.
//  Copyright © 2020 濱田広毅. All rights reserved.
//

import UIKit

class SearchResultViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var resultTableView: UITableView!
    
    var memoArray = [Memo]()
    var memoTitle = String()
    
    var searchMemoTitleString = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        resultTableView.dataSource = self
        resultTableView.delegate = self
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memoArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = resultTableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel!.text = memoArray[indexPath.row].GetTextTitle()
    
        return cell
    }
}
