//
//  TasksListViewController.swift
//  ToDo List Realm
//
//  Created by Nikita Shirobokov on 18.12.22.
//

import UIKit
import SnapKit
import RealmSwift

private extension String {
    static let cellReuseIdentifier = "TaskCell"
    static let title = "Tasks"
}

class TasksListViewController: UIViewController {
    
    private let output: IRouter?
    
    private var tasksLists: Results<TasksList>!
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(TaskCell.self, forCellReuseIdentifier: .cellReuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()
    
    init(output: IRouter) {
        self.output = output
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = UIColor(
            displayP3Red: 21/255,
            green: 101/255,
            blue: 192/255,
            alpha: 194/255
        )
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Add",
            style: .plain,
            target: self,
            action: #selector(addNewTask)
        )
        
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    @objc private func addNewTask() {
        alertForAddAndUpdateList()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tasksLists = realm.objects(TasksList.self)
        
        setupTableView()
        
        title = .title
        
        view.backgroundColor = .white
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }

}


extension TasksListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tasksLists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: .cellReuseIdentifier, for: indexPath) as! TaskCell
        
        let taskList = tasksLists[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = taskList.name
        content.secondaryText = "\(taskList.tasks.count)"
        cell.contentConfiguration = content
        
        return cell
    }
}

extension TasksListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tasksList = tasksLists[indexPath.row]
//        let detailVC = DetailTaskViewController(currentTasksList: tasksList)
        output?.showDetailTaskScreen(taskId: indexPath.row, tasksList: tasksList)
    }
}

extension TasksListViewController {
    
    private func alertForAddAndUpdateList() {
        
        let alert = UIAlertController(title: "New list",
                                      message: "Please, insert new value",
                                      preferredStyle: .alert)
        var alertTextField: UITextField!
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let newList = alertTextField.text, !newList.isEmpty else { return }
            
            let tasksList = TasksList()
            tasksList.name = newList
            
            StorageManager.saveTasksList(tasksList)
            self.tableView.insertRows(at: [IndexPath(row: self.tasksLists.count - 1, section: 0)], with: .automatic)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        alert.addTextField() { textFieald in
            alertTextField = textFieald
            alertTextField.placeholder = "List name"
        }
        
        present(alert, animated: true)
    }
}
