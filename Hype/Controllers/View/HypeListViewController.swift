//
//  HypeListViewController.swift
//  Hype
//
//  Created by Michael Di Cesare on 10/14/19.
//  Copyright © 2019 RYAN GREENBURG. All rights reserved.
//

import UIKit

class HypeListViewController: UIViewController {
    
    // MARK: - Properties
    var refreshContol = UIRefreshControl()
    
    
    // MARK: - OUtlets
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        // fetch hypes
        loadData()
    }
    
    // MARK: - Actions
    @IBAction func addButtenTapped(_ sender: Any) {
        presentHypeAlert(for: nil)
    }
    
    // MARK: - Helper Function
    
    private func saveHype(with text: String) {
        HypeController.shared.saveHype(with: text, photo: nil) { (success) in
            if success {
                self.updateViews()
            }
        }
    }
    
    private func update(hype: Hype) {
        HypeController.shared.update(hype) { (success) in
            if success {
                self.updateViews()
            }
        }
    }
    
    private func updateViews() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.refreshContol.endRefreshing()
        }
        
    }
    // Add obj-c to use a obj-c object
    @objc private func loadData() {
        HypeController.shared.fetchAllHypes { (success) in
            if success {
                self.updateViews()
            }
        }
    }
    
    private func setupViews() {
        tableView.delegate = self
        tableView.dataSource = self
        refreshContol.attributedTitle = NSAttributedString(string: "Pull to see your Hypes!")
        refreshContol.addTarget(self, action: #selector(loadData), for: .valueChanged)
        tableView.addSubview(refreshContol)
    }
    
    private func presentHypeAlert(for hype: Hype?) {
        let alertController = UIAlertController(title: "Get Hype!", message: "What is hype may never die!", preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Hype is hype today?!"
            textField.autocorrectionType = .yes
            textField.autocapitalizationType = .sentences
            if let hype = hype {
                textField.text = hype.body
            }
            
        }
        let addHypeAction = UIAlertAction(title: "Send", style: .default) { (_) in
            guard let text = alertController.textFields?.first?.text,
                !text.isEmpty else {return}
            if let hype = hype {
                hype.body = text
                self.update(hype: hype)
                //add helper
            } else {
                // save
                self.saveHype(with: text)
            }
            
            
        }
        
        let cancleAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        alertController.addAction(addHypeAction)
        alertController.addAction(cancleAction)
        present(alertController, animated: true)
    }
}

// MARK: - Extentions
extension HypeListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return HypeController.shared.hypes.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HypeCell", for: indexPath)
        
        let hype = HypeController.shared.hypes[indexPath.row]
        cell.textLabel?.text = hype.body
        cell.detailTextLabel?.text = hype.timestamp.formatDate()
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let hype = HypeController.shared.hypes[indexPath.row]
        guard hype.userReference.recordID == UserController.shared.currentUser?.ckRecordID else {return false}
        return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // pass the hype as a perameter
        let hypeToUpdate = HypeController.shared.hypes[indexPath.row]
        presentHypeAlert(for: hypeToUpdate)
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Grab the hype we want to delete from the index path
            let hypeToDelete = HypeController.shared.hypes[indexPath.row]
            // make sure that the hype exists in the hypes array
            guard let index = HypeController.shared.hypes.firstIndex(of: hypeToDelete) else { return }
            // call our delete method to delete hype
            HypeController.shared.delete(hypeToDelete) { (sucess) in
                // if it delets successfully , we remove the hype from our SOT and delete the row
                if sucess { HypeController.shared.hypes.remove(at: index)
                    DispatchQueue.main.async {
                        tableView.deleteRows(at: [indexPath], with: .automatic)
                    }
                }
            }
        }
    }
}

