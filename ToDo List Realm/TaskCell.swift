//
//  TaskCell.swift
//  ToDo List Realm
//
//  Created by Nikita Shirobokov on 18.12.22.
//

import UIKit

class TaskCell: UITableViewCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension UITableViewCell {
    func configure(with tasksList: TasksList, cell: UITableViewCell) {
        let currentTasks = tasksList.tasks.filter("isComplete = false")
        let completedTasks = tasksList.tasks.filter("isComplete = true")
        
        var content = cell.defaultContentConfiguration()
        content.text = tasksList.name
        
        if !currentTasks.isEmpty {
            content.secondaryText = "\(currentTasks.count)"
        } else if !completedTasks.isEmpty {
            content.secondaryText = "✅"
        } else {
            content.secondaryText = "0"
        }
 
        cell.contentConfiguration = content
    }
    
}
