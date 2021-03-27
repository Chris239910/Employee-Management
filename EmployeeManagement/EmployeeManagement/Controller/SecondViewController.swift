//
//  SecondViewController.swift
//  EmployeeManagement
//
//  Created by english on 2020-12-08.
//  Copyright © 2020 Chris. All rights reserved.
//

import UIKit
import CoreData

class SecondViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var choosenEmployeeName = ""
    var choosenEmployeeId :UUID?

    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var NameTxt: UITextField!
    @IBOutlet weak var DepartmentTxt: UITextField!
    @IBOutlet weak var YearOfBirthTxt: UITextField!
    @IBOutlet weak var saveBtn: UIButton!
    @IBAction func savePressed(_ sender: UIButton) {
        //check if textField is empty or not
        if NameTxt.text! != ""{
            if DepartmentTxt.text! != ""{
                if YearOfBirthTxt.text! != ""{
                    //Save data if all the textFields are not empty
                    let appdelegate = UIApplication.shared.delegate as! AppDelegate
                    let context = appdelegate.persistentContainer.viewContext
                    
                    let newEmployee = NSEntityDescription.insertNewObject(forEntityName: "Employees", into: context)
                    //attribute
                    newEmployee.setValue(NameTxt.text!, forKey: "name")
                    newEmployee.setValue(DepartmentTxt.text!, forKey: "department")
                    if let year = Int(YearOfBirthTxt.text!){
                        newEmployee.setValue(year, forKey: "yearOfBirth")
                    }
                    let data = imgView.image?.jpegData(compressionQuality: 0.5)
                    newEmployee.setValue(data, forKey: "photo")
                    newEmployee.setValue(UUID(), forKey: "id")
                    
                    do{
                        try context.save()
                        print("Success")
                    }catch{
                        print("Error")
                    }
                    
                    //sending notification
                    //objetcs register with a notification center to receive notifications
                    NotificationCenter.default.post(name: NSNotification.Name("newEmployee"), object: nil)
                    //pop the top view controller
                    navigationController?.popViewController(animated: true)
                }else{
                    //notify YearOfBirthTxt is empty
                    YearOfBirthTxt.placeholder = "You must enter Year of Birth"
                    }
            }
            else{
                //notify DepartmentTxt is empty
                DepartmentTxt.placeholder = "You must enter Department"
                }
        }else{
            //notify Namtxt is empty
            NameTxt.placeholder = "You must enter Name"
            }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        //call func getDataById
        getDataById()
        //image tag recognizer
        imgView.isUserInteractionEnabled = true
        //create recognizer
        let imageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(chooseImage))
        imgView.addGestureRecognizer(imageTapRecognizer)
    }
    
    @objc func chooseImage(){
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .photoLibrary
            present(picker, animated: true, completion: nil)
            
        }
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            //value of info is dictionary
            imgView.image = info[.originalImage] as? UIImage
            dismiss(animated: true, completion: nil)
        }
        
        func getDataById(){
            if choosenEmployeeName != "" {
                saveBtn.isHidden = true
                let appdelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appdelegate.persistentContainer.viewContext
                
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Employees")
                let idString = choosenEmployeeId?.uuidString
                fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
                do{
                    let results = try context.fetch(fetchRequest)
                    if results.count > 0{
                        for result in results as! [NSManagedObject]{
                            if let name = result.value(forKey: "name") as? String{
                                NameTxt.text = name
                            }
                            if let department = result.value(forKey: "department") as? String{
                                DepartmentTxt.text = department
                            }
                            if let year = result.value(forKey: "yearOfBirth") as? Int{
                                YearOfBirthTxt.text = String(year)
                            }
                            if let imageData = result.value(forKey: "photo") as? Data{
                                imgView.image = UIImage(data: imageData)
                            }
                            
                        }
                    }
                }catch{
                    print("Error")
                }
            
            }else{
                saveBtn.isHidden = false
            }
            
    }
    


}
