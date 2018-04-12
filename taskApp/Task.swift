//
//  Task.swift
//  taskApp
//
//  Created by classtream on 2018/04/12.
//  Copyright © 2018年 ono. All rights reserved.
//

import RealmSwift

class Task: Object {
    @objc dynamic var id: Int = 0
    @objc dynamic var title: String = ""
    @objc dynamic var category: String = ""
    @objc dynamic var contents: String = ""
    @objc dynamic var date: Date = Date()
 
    override static func primaryKey() -> String? {
        return "id"
    }
}
