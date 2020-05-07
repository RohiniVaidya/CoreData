//
//  InterfaceController.swift
//  CoreDataExampleWatch Extension
//
//  Created by Admin on 5/7/20.
//  Copyright © 2020 Rohini. All rights reserved.
//

import WatchKit
import Foundation
import CoreData

class InterfaceController: WKInterfaceController {

    @IBOutlet weak var textField: WKInterfaceTextField!
    
    @IBOutlet weak var submitBtn: WKInterfaceButton!
    var textInput = "default"
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }
    
    @IBAction func textFieldAction(_ value: NSString?) {
        
        if value != nil{
            textInput = value! as String

        }
        
    }
    @IBAction func SubmitAction() {
        
        let appDelegate = WKExtension.shared().delegate as? ExtensionDelegate
        let context = appDelegate?.coreDataStack.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Person", in: context!)
        let person = NSManagedObject(entity: entity!, insertInto: context!)
        person.setValue("Watch Text + \(Date()) + \(textInput)", forKey: "name")
        
        do
        {
            try context!.save()
        }catch{
            
        }
    }
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
