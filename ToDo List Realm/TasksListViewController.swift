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
    
    private let segmentedItems = ["A-Z", "Date"]
    
    private let output: IRouter?
    
    private var tasksLists: Results<TasksList>!
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(TaskCell.self, forCellReuseIdentifier: .cellReuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()
    
    private lazy var segmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: segmentedItems)
        segmentedControl.selectedSegmentIndex = 0
        return segmentedControl
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
        tableView.reloadData()
        
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
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Edit",
            style: .plain,
            target: self,
            action: #selector(editMode)
        )
        
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    @objc private func addNewTask() {
        alertForAddAndUpdateList()
    }
    
    @objc private func editMode() {
        if tableView.isEditing {
            tableView.setEditing(false, animated: true)
            navigationItem.leftBarButtonItem?.title = "Edit"
            navigationItem.rightBarButtonItem?.isEnabled = true
        } else {
            navigationItem.leftBarButtonItem?.title = "Done"
            tableView.setEditing(true, animated: true)
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tasksLists = realm.objects(TasksList.self)
        
        setupSegmentedControl()
        setupTableView()
        
        title = .title
        
        view.backgroundColor = .white
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(segmentedControl).inset(40)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func setupSegmentedControl() {
        view.addSubview(segmentedControl)
        segmentedControl.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide)
        }
    }

}

// MARK: - TableView DataSource
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

// MARK: - TableView Delegate
extension TasksListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tasksList = tasksLists[indexPath.row]
//        let detailVC = DetailTaskViewController(currentTasksList: tasksList)
        output?.showDetailTaskScreen(taskId: indexPath.row, tasksList: tasksList)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let currentList = tasksLists[indexPath.row]
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") {  (_, _, _) in
            
            StorageManager.deleteList(taskList: currentList)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") {  (_, _, _) in
            
            self.alertForAddAndUpdateList(currentList) {
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }
        
        let doneAction = UIContextualAction(style: .normal, title: "Done") {  (_, _, _) in
            StorageManager.makeAllDone(currentList)
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        
        let swipeActions = UISwipeActionsConfiguration(actions: [deleteAction, doneAction, editAction])
        
        editAction.backgroundColor = .orange
        doneAction.backgroundColor = .green
        
        return swipeActions
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let itemToMove = tasksLists[sourceIndexPath.row]
        realm.delete(itemToMove)
        realm.add(itemToMove)
    }
}

// MARK: - Alert
extension TasksListViewController {
    
    private func alertForAddAndUpdateList(_ listName: TasksList? = nil, completion: (() -> Void)? = nil) {
        
        var title = "New List"
        var doneButton = "Save"
        
        if listName != nil {
            title = "Edit List"
            doneButton = "Update"
        }
        
        let alert = UIAlertController(title: title,
                                      message: "Please, insert new value",
                                      preferredStyle: .alert)
        var alertTextField: UITextField!
        
        
        let saveAction = UIAlertAction(title: doneButton, style: .default) { _ in
            guard let newList = alertTextField.text, !newList.isEmpty else { return }
            
            if let listName = listName {
                StorageManager.editList(taskList: listName, newListName: newList)
                if completion != nil { completion!() }
            } else {
                let tasksList = TasksList()
                tasksList.name = newList
                
                StorageManager.saveTasksList(tasksList)
                self.tableView.insertRows(at: [IndexPath(
                    row: self.tasksLists.count - 1, section: 0)], with: .automatic
                )
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        alert.addTextField() { textFieald in
            alertTextField = textFieald
            alertTextField.placeholder = "List name"
        }
        
        if let listName = listName {
            alertTextField.text = listName.name
        }
        
        present(alert, animated: true)
    }
}

