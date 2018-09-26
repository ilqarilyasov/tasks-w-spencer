//
//  TasksTableViewController.swift
//  TasksSC
//
//  Created by Ilgar Ilyasov on 9/25/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class TasksTableViewController: UITableViewController {
    
    // MARK: - Properties
    
    let taskController = TaskController()
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskController.tasks.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath)
        let task = taskController.tasks[indexPath.row]

        cell.textLabel?.text = task.name
        cell.detailTextLabel?.text = task.notes

        return cell
    }


    // MARK: - Override to support editing the table view
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let task = taskController.tasks[indexPath.row]
            taskController.deleteTask(task: task)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowViewFromAddButton" {
            let destVC = segue.destination as! TaskDetailViewController
            destVC.taskController = taskController
            
        } else if segue.identifier == "ShowViewFromCell" {
            let destVC = segue.destination as! TaskDetailViewController
            
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            let task = taskController.tasks[indexPath.row]
            
            destVC.task = task
            destVC.taskController = taskController
        }
    }
}
