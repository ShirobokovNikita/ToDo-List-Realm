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
    
    let currentTasksList: TasksList
    
    private var currentTasks: Results<Task>!
    private var completedTasks: Results<Task>!
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(DetailTaskCell.self, forCellReuseIdentifier: .cellReuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()
    
    init(currentTasksList: TasksList) {
        self.currentTasksList = currentTasksList
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
        
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(
            title: "Edit",
            style: .plain,
            target: self,
            action: #selector(editMode)
        ),
            UIBarButtonItem(
            title: "Add",
            style: .plain,
            target: self,
            action: #selector(addNewTask)
        )]
        
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
            navigationItem.rightBarButtonItem?.title = "Edit"
        } else {
            navigationItem.rightBarButtonItem?.title = "Done"
            tableView.setEditing(true, animated: true)
        }
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
        currentTasks = currentTasksList.tasks.filter("isComplete = false")
        completedTasks = currentTasksList.tasks.filter("isComplete = true")
        
        tableView.reloadData()
    }
    
}

// MARK: - TableView DataSource
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

// MARK: - TableView Delegate
extension DetailTaskViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        var task: Task!
        var title = "Done"
        
        task = indexPath.section == 0 ? currentTasks[indexPath.row] : completedTasks[indexPath.row]
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (_, _, _)  in
            StorageManager.deleteTask(task)
            self.filteringTasks()
        }
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { (_, _, _)  in
            self.alertForAddAndUpdateList(task)
            self.filteringTasks()
        }
        
        title = indexPath.section == 0 ? "Done" : "Undone"
        
        let doneAction = UIContextualAction(style: .normal, title: title) {  (_, _, _) in
            StorageManager.makeDone(task)
            self.filteringTasks()
        }
        
        editAction.backgroundColor = .orange
        doneAction.backgroundColor = .green
        
        let swipeActions = UISwipeActionsConfiguration(actions: [deleteAction, doneAction, editAction])
        
        return swipeActions
    }
}

// MARK: - Alert
extension DetailTaskViewController {
    
    private func alertForAddAndUpdateList(_ taskName: Task? = nil) {
        
        var title = "New task"
        var doneButton = "Save"
        
        if taskName != nil {
            title = "Edit Task"
            doneButton = "Update"
        }
        
        let alert = UIAlertController(
            title: title,
            message: "Please, insert new value",
            preferredStyle: .alert
        )
        var taskTextField: UITextField!
        var noteTextField: UITextField!
        
        let saveAction = UIAlertAction(title: doneButton, style: .default) { _ in
            guard let newTask = taskTextField.text, !newTask.isEmpty else { return }
            
            if let taskName = taskName {
                if let newNote = noteTextField.text, !newNote.isEmpty {
                    StorageManager.editTask(taskName, newTask: newTask, newNote: newNote)
                } else {
                    StorageManager.editTask(taskName, newTask: newTask, newNote: "")
                }
                
                self.filteringTasks()
            } else {
                let task = Task()
                task.name = newTask
                
                if let note = noteTextField.text, !note.isEmpty {
                    task.note = note
                }
                
                StorageManager.saveTask(self.currentTasksList, task: task)
                self.filteringTasks()
            }
        }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
            
            alert.addAction(saveAction)
            alert.addAction(cancelAction)
            
            alert.addTextField() { textFieald in
                taskTextField = textFieald
                taskTextField.placeholder = "New task"
                
                if let taskName = taskName {
                    taskTextField.text = taskName.name
                }
            }
        
            alert.addTextField() { textField in
                noteTextField = textField
                noteTextField.placeholder = "Note"
                
                if let taskName = taskName {
                    noteTextField.text = taskName.note
                }
            }
            
            present(alert, animated: true)
        }
    }
