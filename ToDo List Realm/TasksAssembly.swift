//
//  TasksAssembly.swift
//  ToDo List Realm
//
//  Created by Nikita Shirobokov on 18.12.22.
//

import Foundation
import UIKit

protocol ITasksAssembly: AnyObject {
    func makeTasksScreen(router: IRouter) -> UIViewController
    func makeDetailTaskScreen(taskId: Int, router: IRouter, tasksList: TasksList) -> UIViewController
}

final class TasksAssembly: ITasksAssembly {
    func makeTasksScreen(router: IRouter) -> UIViewController {
        let viewController = TasksListViewController(output: router)
        return viewController
    }
    
    func makeDetailTaskScreen(taskId: Int, router: IRouter, tasksList: TasksList) -> UIViewController {
        let viewController = DetailTaskViewController(currentTasksList: tasksList)
        return viewController
    }
    
    
}

