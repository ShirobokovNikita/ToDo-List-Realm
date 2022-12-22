//
//  Router.swift
//  ToDo List Realm
//
//  Created by Nikita Shirobokov on 18.12.22.
//

import Foundation
import UIKit

protocol IRouter: AnyObject {
    func showTasksScreen()
    func showDetailTaskScreen(taskId: Int, tasksList: TasksList)
}

final class Router {
    
    private let transitionHandler: UINavigationController
    private let tasksAssembly: ITasksAssembly
    
    init(transitionHandler: UINavigationController, usersAssembly: ITasksAssembly) {
        self.transitionHandler = transitionHandler
        self.tasksAssembly = usersAssembly
    }
}

extension Router: IRouter {
    func showTasksScreen() {
        let viewController = tasksAssembly.makeTasksScreen(router: self)
        transitionHandler.pushViewController(viewController, animated: true)
    }
    
    func showDetailTaskScreen(taskId: Int, tasksList: TasksList) {
        let viewController = tasksAssembly.makeDetailTaskScreen(taskId: taskId, router: self, tasksList: tasksList)
        transitionHandler.pushViewController(viewController, animated: true)
    }
}
