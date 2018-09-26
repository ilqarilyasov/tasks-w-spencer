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
    var task: Task? { didSet { updateViews() } }

    // MARK: - Outlets
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var notesTextView: UITextView!
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
    }
    
    // MARK: - Actions

    @IBAction func saveTask(_ sender: Any) {
        guard let name = nameTextField.text else { return }
        let notes = notesTextView.text
        
        if let task = task {
            taskController?.updateTask(task: task, name: name, notes: notes)
        } else {
            taskController?.createTask(with: name, notes: notes)
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Update views
    
    func updateViews() {
        guard let task = task, isViewLoaded else { return }
        
        nameTextField.text = task.name
        notesTextView.text = task.notes
    }
}
