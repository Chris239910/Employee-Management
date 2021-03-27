//
//  ViewController.swift
//  EmployeeManagement
//
//  Created by english on 2020-12-08.
//  Copyright © 2020 Chris. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //declare variables
    var nameArray = [String]()
    var idArray = [UUID]()
    var selectedEmployeeName = ""
    var selectedEmployeeId : UUID?
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return the amount of employees in tableView
        return nameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = nameArray[indexPath.row]
        return cell
    }
    

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        
        //Create add button
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonClick))
        
        
        getData()
    }
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name("newEmployee"), object: nil)
    }
    
    //get data from core database to dislay to tableView
    @objc func getData(){
        //remove everything
        nameArray.removeAll()
        idArray.removeAll()
        
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appdelegate.persistentContainer.viewContext
        
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Employees")
        do{
            let results = try context.fetch(fetchRequest)
            if results.count > 0{
                for result in results as! [NSManagedObject]{
                    if let name = result.value(forKey: "name") as? String{
                        nameArray.append(name)
                    }
                    if let id = result.value(forKey: "id") as? UUID{
                        idArray.append(id)
                    }
                    tableView.reloadData()
                }
            }
        }catch{
            print("Error")
        }
        
    }
    //when click onto addBtn
    @objc func addButtonClick(){
        selectedEmployeeName = ""
        performSegue(withIdentifier: "SC", sender: nil)
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedEmployeeId = idArray[indexPath.row]
        selectedEmployeeName = nameArray[indexPath.row]
        performSegue(withIdentifier: "SC", sender: "nil")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SC" {
            let des = segue.destination as! SecondViewController
            des.choosenEmployeeId = selectedEmployeeId
            des.choosenEmployeeName = selectedEmployeeName
        }
    }
    //delete cell in tableView
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            //delete from painting where Id = ??
            let appdelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appdelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Employees")
            let idString = idArray[indexPath.row].uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString)
            do{
                let results = try context.fetch(fetchRequest)
                if results.count > 0{
                    for result in results as! [NSManagedObject]{
                        if let id = result.value(forKey: "id") as? UUID{
                            if id == idArray[indexPath.row]{
                            context.delete(result)
                            nameArray.remove(at: indexPath.row)
                            idArray.remove(at: indexPath.row)
                            tableView.reloadData()
                            do{
                                try context.save()
                            }catch{
                                print("Error")
                            }
                                break
                        }
                    }
                        
                }
            }
        }catch{
            print("Error")
        }
            
        }
    }


}

