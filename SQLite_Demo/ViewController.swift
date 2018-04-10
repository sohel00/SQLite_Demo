//
//  ViewController.swift
//  SQLite_Demo
//
//  Created by Sohel Dhengre on 05/04/18.
//  Copyright © 2018 Sohel Dhengre. All rights reserved.
//

import UIKit
import SQLite

class ViewController: UIViewController {

    var database: Connection!
    let userTable = Table("Users")
    let id = Expression<Int>("id")
    let name = Expression<String>("name")
    let email = Expression<String>("email")
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        do {
            let doumentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let fileUrl = doumentDirectory.appendingPathComponent("Users").appendingPathExtension("sqlite3")
            let db = try Connection(fileUrl.path)
            self.database = db
        }
        catch {
            debugPrint(error.localizedDescription)
        }
    }

   
    @IBAction func createTablePressed(_ sender: Any) {
        let createTable = self.userTable.create { (table) in
            table.column(self.id, primaryKey:true)
            table.column(self.name)
            table.column(self.email, unique:true)
        }
        do {
            try self.database.run(createTable)
            print("Table Created")
        } catch{
            debugPrint(error.localizedDescription)
        }
        
    }
    
    @IBAction func insertUserPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Inser User", message: nil, preferredStyle: .alert)
        alert.addTextField { (tf) in
            tf.placeholder = "Name"
        }
        alert.addTextField { (tf) in
            tf.placeholder = "Email"
        }
        let action = UIAlertAction(title: "Submit", style: .default) { (_) in
            guard let name = alert.textFields?.first?.text,
              let email = alert.textFields?.last?.text else {return}
            print(name)
            print(email)
            
            let insertUser = self.userTable.insert(self.name <- name, self.email <- email)
            do {
                try self.database.run(insertUser)
                print("Inserted Users")
            } catch {
                debugPrint(error.localizedDescription)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive) { (_) in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(action)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func listUserspressed(_ sender: Any) {
        
        do {
             let users = try self.database.prepare(self.userTable)
            for user in users {
                print("User_ID: \(user[self.id])", "Name: \(user[self.name])", "Email: \(user[self.email])")
            }
        } catch  {
            print(error.localizedDescription)
        }
    }
    
    
    @IBAction func updateUserPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Update User", message: nil, preferredStyle: .alert)
        alert.addTextField { (tf) in
            tf.placeholder = "User_Id"
        }
        alert.addTextField { (tf) in
            tf.placeholder = "Email"
        }
        let action = UIAlertAction(title: "Submit", style: .default) { (_) in
            guard let userIDString = alert.textFields?.first?.text,
            let userId = Int(userIDString),
                let email = alert.textFields?.last?.text else {return}
            
            let user = self.userTable.filter(self.id == userId)
            let updateUser = user.update(self.email <- email)
            do {
                try self.database.run(updateUser)
            } catch {
                print(error.localizedDescription)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive) { (_) in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(action)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func deleteUserPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Delete User", message: nil, preferredStyle: .alert)
        alert.addTextField { (tf) in
            tf.placeholder = "User_ID"
        }
        let action = UIAlertAction(title: "Submit", style: .default) { (_) in
            guard let UserIdString = alert.textFields?.first?.text,
            let userIdInt = Int(UserIdString) else {return}
            let User = self.userTable.filter(self.id == userIdInt)
            let deleteUser = User.delete()
            do {
                try self.database.run(deleteUser)
            } catch {
                print(error.localizedDescription)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive) { (_) in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(action)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
}




