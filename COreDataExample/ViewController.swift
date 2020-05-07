//
//  ViewController.swift
//  COreDataExample
//
//  Created by Admin on 5/5/20.
//  Copyright © 2020 Rohini. All rights reserved.
//

import UIKit
import CoreData
import CloudKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var persons = [NSManagedObject]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.dataSource = self
        tableView.delegate = self
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        let managedObjContext = appDelegate.coreDataStack.persistentContainer.viewContext
        
        let fetchReq = NSFetchRequest<Person>(entityName: "Person")
        do{
            persons = try managedObjContext.fetch(fetchReq)
        }
        catch{
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(fetcData(notification:)), name: .diReceiveRemoteNotification, object: nil)
        
    }
    
    @objc func fetcData(notification: Notification){
        
        if let notification = notification.object as? CKQueryNotification{
            let recordID = notification.recordID
            
            guard let appDelegate =
                UIApplication.shared.delegate as? AppDelegate else {
                    return
            }
            let managedObjContext = appDelegate.coreDataStack.persistentContainer.viewContext
            let fetchReq = NSFetchRequest<Person>(entityName: "Person")
            let predicate = NSPredicate(format: "name = %@", argumentArray: [recordID?.value(forKey: "CD_name") as! String]) // Specify your condition here
            fetchReq.predicate = predicate
            do{
                let data = try managedObjContext.fetch(fetchReq)
                print("DEBUG: value for the name is \(data)")
            }
            catch{
                
            }
        }
    }
    
    
    @IBAction func addNewNames(_ sender: Any) {
        
        let alert = UIAlertController(title: "New Name",
                                      message: "Add a new name",
                                      preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save",
                                       style: .default) {
                                        [unowned self] action in
                                        
                                        guard let textField = alert.textFields?.first,
                                            let nameToSave = textField.text else {
                                                return
                                        }
                                        
                                        self.save(name: nameToSave)
                                        self.tableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .cancel)
        
        alert.addTextField()
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
        
    }
    
    func save(name: String){
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedObjectContext = appDelegate.coreDataStack.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Person", in: managedObjectContext)
        let person = NSManagedObject(entity: entity!, insertInto: managedObjectContext)
        person.setValue(name, forKey: "name")
        
        do
        {
            try managedObjectContext.save()
            persons.append(person)
        }catch{
            
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return persons.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let person = persons[indexPath.row]
        cell.textLabel?.text = person.value(forKey: "name") as? String
        
        return cell
    }
    
}

extension Notification.Name {
    static let diReceiveRemoteNotification = Notification.Name("diReceiveRemoteNotification")
}
