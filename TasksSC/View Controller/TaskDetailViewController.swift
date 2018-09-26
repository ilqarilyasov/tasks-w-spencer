//
//  TaskDetailViewController.swift
//  TasksSC
//
//  Created by Ilgar Ilyasov on 9/25/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class TaskDetailViewController: UIViewController {
    
    // MARK: - Properties
    
    var taskController: TaskController?
    var task: Task? { didSet { updateViews() }}

    // MARK: - Outlets
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var priorityControl: UISegmentedControl!
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
    }
    
    // MARK: - Actions

    @IBAction func saveTask(_ sender: Any) {
        guard let name = nameTextField.text else {return}
        let notes = notesTextView.text
        
        let priorityIndex = priorityControl.selectedSegmentIndex
        let priority = TaskPriority.allPriorities[priorityIndex]
        
        if let task = task {
            taskController?.updateTask(task: task, name: name, notes: notes, priority: priority)
        } else {
            taskController?.createTask(with: name, notes: notes, priority: priority)
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Update views
    
    func updateViews() {
        guard isViewLoaded else {return}
        
        title = task?.name ?? "Create Task"
        
        nameTextField.text = task?.name
        notesTextView.text = task?.notes
        
        let priority: TaskPriority
        
        if let taskPriority = task?.priority {
            priority = TaskPriority(rawValue: taskPriority) ?? .normal
        } else {
            priority = .normal
        }
        
        guard let priorityIndex = TaskPriority.allPriorities.index(of: priority) else {return}
        priorityControl.selectedSegmentIndex = priorityIndex
    }
}
