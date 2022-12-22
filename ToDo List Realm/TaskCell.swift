//
//  TaskCell.swift
//  ToDo List Realm
//
//  Created by Nikita Shirobokov on 18.12.22.
//

import UIKit

class TaskCell: UITableViewCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value2, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
