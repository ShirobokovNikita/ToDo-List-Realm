//
//  DetailTaskViewController.swift
//  ToDo List Realm
//
//  Created by Nikita Shirobokov on 18.12.22.
//

import UIKit
import RealmSwift

private extension String {
    static let cellReuseIdentifier = "TaskCell"
}

class DetailTaskViewController: UIViewController {
    
    let currentTasksList: TasksList?
     
    var currentTasks: Results<Task>!
    var completedTasks: Results<Task>!
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(TaskCell.self, forCellReuseIdentifier: .cellReuseIdentifier)
        tableView.dataSource = self
        //        tableView.delegate = self
        return tableView
    }()
    
    init(currentTasksList: TasksList) {
        self.currentTasksList = currentTasksList
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Task"
        
        setupTableView()
        filteringTasks()
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func filteringTasks() {
        currentTasks = currentTasksList?.tasks.filter("isComplete = false")
        completedTasks = currentTasksList?.tasks.filter("isComplete = true")
        
        tableView.reloadData()
    }
    
}

extension DetailTaskViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? currentTasks.count : completedTasks.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Current Tasks" : "Completed Tasks"
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: .cellReuseIdentifier, for: indexPath)
        
        var task: Task!
        task = indexPath.section == 0 ? currentTasks[indexPath.row] : completedTasks[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = task.name
        content.secondaryText = task.note
        cell.contentConfiguration = content
        
        return cell
    }


}

extension DetailTaskViewController {
    
    private func alertForAddAndUpdateList() {
        
        let alert = UIAlertController(title: "New list",
                                      message: "Please, insert new value",
                                      preferredStyle: .alert)
        var alertTextField: UITextField!
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let newTask = alertTextField.text, !newTask.isEmpty else { return }
            
            let task = Task()
            task.name = newTask
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        alert.addTextField() { textFieald in
            alertTextField = textFieald
            alertTextField.placeholder = "New task"
        }
        
        alert.addTextField() { textField in
            alertTextField = textField
            alertTextField.placeholder = "Note"
        }
        
        present(alert, animated: true)
    }
}
