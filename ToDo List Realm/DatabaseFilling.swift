//
//  DatabaseFilling.swift
//  ToDo List Realm
//
//  Created by Nikita Shirobokov on 20.12.22.
//

import UIKit

class DatabaseFilling {
    
    private func fiiling() {
        
        let shoppingList = TasksList()
        shoppingList.name = "Shopping list"
        
        let moviesList = TasksList(value: ["Movies list", Date(), [["John Wick"], ["Tor", "", Date(), true]]])
        
        let milk = Task()
        milk.name = "Milk"
        milk.note = "2L"
        
        // создание св-ва через массив
        let bread = Task(value: ["Bread", "", Date(), true])
        
        // создание св-ва через словарь
        let apples = Task(value: ["name": "Apples", "note": "2Kg"])
        
        shoppingList.tasks.append(milk)
        shoppingList.tasks.insert(contentsOf: [bread, apples], at: 1)
        
        DispatchQueue.main.async {
            StorageManager.saveTasksList(shoppingList)
            StorageManager.saveTasksList(moviesList)
        }
    }
}


