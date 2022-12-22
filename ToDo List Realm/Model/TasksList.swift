//
//  TasksList.swift
//  ToDo List Realm
//
//  Created by Nikita Shirobokov on 19.12.22.
//

import RealmSwift

class TasksList: Object {
    @objc dynamic var name = ""
    @objc dynamic var date = Date()
    let tasks = List<Task>()
}
