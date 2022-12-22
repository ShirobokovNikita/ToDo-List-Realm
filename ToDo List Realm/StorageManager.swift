//
//  StorageManager.swift
//  ToDo List Realm
//
//  Created by Nikita Shirobokov on 19.12.22.
//

import RealmSwift

let realm = try! Realm()

class StorageManager {
    
    static func saveTasksList(_ tasksList: TasksList) {
        try! realm.write {
            realm.add(tasksList)
        }
    }
}
