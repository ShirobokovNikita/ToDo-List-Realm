//
//  StorageManager.swift
//  ToDo List Realm
//
//  Created by Nikita Shirobokov on 19.12.22.
//

import RealmSwift

let realm = try! Realm()

class StorageManager {
    
    // MARK: - Tasks Lists Methods
    
    static func saveTasksList(_ tasksList: TasksList) {
        try! realm.write {
            realm.add(tasksList)
        }
    }
    
    static func deleteList(taskList: TasksList) {
        try! realm.write {
            let tasks = taskList.tasks
            realm.delete(tasks)
            realm.delete(taskList)
        }
    }
    
    static func editList(taskList: TasksList, newListName: String) {
        try! realm.write {
            taskList.name = newListName
        }
    }
    
    static func makeAllDone(_ tasksList: TasksList) {
        try! realm.write {
            tasksList.tasks.setValue(true, forKey: "isComplete")
        }
    }
    
    // MARK: - Tasks Methods
    
    static func saveTask(_ tasksList: TasksList, task: Task) {
        try! realm.write {
            tasksList.tasks.append(task)
        }
    }
    
    static func editTask(_ task: Task, newTask: String, newNote: String) {
        try! realm.write {
            task.name = newTask
            task.note = newNote
        }
    }
    
    static func deleteTask(_ task: Task) {
        try! realm.write {
            realm.delete(task)
        }
    }
    
    static func makeDone(_ task: Task) {
        try! realm.write {
            task.isComplete.toggle()
        }
    }
    
}
