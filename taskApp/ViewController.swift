//
//  ViewController.swift
//  taskApp
//
//  Created by classtream on 2018/04/11.
//  Copyright © 2018年 ono. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    let realm = try! Realm()
    var taskArray: Results<Task>!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.searchItems(nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        // 検索バー設定
        let searchBar: UISearchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.placeholder = "Search by Category"
        searchBar.showsCancelButton = true
        self.navigationItem.titleView = searchBar
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let iViewController: InputViewController = segue.destination as! InputViewController
        
        if segue.identifier == "cellSegue" {
            let indexPath = self.tableView.indexPathForSelectedRow
            iViewController.task = self.taskArray[indexPath!.row]
        } else {
            let task = Task()
            task.date = Date()
            
            let tArray = realm.objects(Task.self)
            if tArray.count != 0 {
                task.id = tArray.max(ofProperty: "id")! + 1
            }
            iViewController.task = task
        }
    }
    
    @objc func dismissKeybord() {
        self.view.endEditing(true)
    }
    
    // MARK: Search
    
    // 検索
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        
        let predicate = NSPredicate(format: "category = %@", searchBar.text!.trimmingCharacters(in: .whitespaces))
        self.searchItems(predicate)
    }
    
    // キャンセル
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        
        self.searchItems(nil)
        searchBar.resignFirstResponder()
    }
    
    // データ検索
    func searchItems(_ predicate: NSPredicate!) {
        taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: false)
        if predicate != nil {
            taskArray = taskArray.filter(predicate)
        }
        self.tableView.reloadData()
    }

    // MARK: UITableViewDataSourceプロトコルのメソッド
    // データの数（＝セルの数）を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.taskArray.count
    }
    
    // 各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 再利用可能な cell を得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        // cellに値を設定
        let task = self.taskArray[indexPath.row]
        if task.category != "" {
            cell.textLabel?.text = task.title + " (" + task.category + ")"
        } else {
            cell.textLabel?.text = task.title
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let dateString: String = formatter.string(from: task.date)
        cell.detailTextLabel?.text = dateString
        
        return cell
    }
    
    // MARK: UITableViewDelegateプロトコルのメソッド
    // 各セルを選択した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "cellSegue", sender: nil)
    }
    
    // セルが削除が可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath)-> UITableViewCellEditingStyle {
        return .delete
    }
    
    // Delete ボタンが押された時に呼ばれるメソッド
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            // 通史されたタスクを取得
            let task = self.taskArray[indexPath.row]
            
            // ローカル通知をキャンセル
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])
            
            // DBから削除
            try! self.realm.write {
                self.realm.delete(self.taskArray[indexPath.row])
                self.tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
            // 未通知のローカル通知一覧をログ出力
            center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
                for request in requests {
                    print("/---------------")
                    print(request)
                    print(" ---------------/")
                }
            }
        }
    }
}

