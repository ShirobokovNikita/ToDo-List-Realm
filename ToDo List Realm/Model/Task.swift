//
//  Task.swift
//  ToDo List Realm
//
//  Created by Nikita Shirobokov on 19.12.22.
//

import RealmSwift

class Task: Object {
    
    @objc dynamic var name = ""
    @objc dynamic var note = ""
    @objc dynamic var date = Date()
    @objc dynamic var isComplete = false
}
