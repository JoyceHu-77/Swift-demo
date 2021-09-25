//
//  ViewController.swift
//  coreDataDemo0
//
//  Created by Blacour on 2021/8/29.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    lazy var coreDataStack = CoreDataStack(modelName: "coreDataDemo0")
    
    
    lazy var tableView: UITableView = { () -> UITableView in
        var value = UITableView()
        value.allowsSelection = false
        value.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: (view.frame.height / 2))
        value.delegate = self
        value.dataSource = self
        return value
    }()
    
    lazy var textField: UITextField = { () -> UITextField in
        var value = UITextField()
        value.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        value.frame = CGRect(x: 0, y: view.center.y, width: view.frame.width, height: (view.frame.height / 2))
        value.placeholder = "请输入存入的数据"
        value.font = UIFont.systemFont(ofSize: 17)
        value.delegate = self
        return value
    }()
    
    var currentEntity: Entity?
    var entityArray = [Entity]()
    var entityName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let entityFetch: NSFetchRequest<Entity> = Entity.fetchRequest()
        do {
            let results = try coreDataStack.managedContext.fetch(entityFetch)
            entityArray = results
            for entity in entityArray {
                entity.tag = 0
            }
        } catch let error as NSError {
            print("Fetch error: \(error) description: \(error.userInfo)")
        }
        
        view.addSubview(tableView)
        view.addSubview(textField)
        
        
    }
    
    
    //MARK:-coreData
    func operateDataBase(entityName: String?) {
        for entity in entityArray {
            entity.tag = 0
        }
        guard let entityName = entityName else { return }
        let entityFetch: NSFetchRequest<Entity> = Entity.fetchRequest()
        entityFetch.predicate = NSPredicate(format: "%K == %@",
                                            #keyPath(Entity.name), entityName)
        
        do {
            let results = try coreDataStack.managedContext.fetch(entityFetch)
            print("results.count\(results.count)")
            if results.count > 0 {
                // name found, use name
                currentEntity = results.first
                currentEntity?.tag = 1
                tableView.reloadData()
            } else {
                // name not found, create name
                currentEntity = Entity(context: coreDataStack.managedContext)
                currentEntity?.name = entityName
                coreDataStack.saveContext()
                if let currentEntity = currentEntity {
                    entityArray.append(currentEntity)
                    tableView.reloadData()
                }
            }
        } catch let error as NSError {
            print("Fetch error: \(error) description: \(error.userInfo)")
        }
    }
    
}

//MARK:- TableViewDelegate
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("entityArray.count\(entityArray.count)")
        return entityArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellid = "UITableViewCell"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellid)
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellid)
        }
        cell?.textLabel?.text = entityArray[indexPath.row].name
        if entityArray[indexPath.row].tag == 1 {
            cell?.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        } else {
            cell?.backgroundColor = .white
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView,
                   canEditRowAt indexPath: IndexPath) -> Bool {
      return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let entityToRemove = entityArray[indexPath.row]
        coreDataStack.managedContext.delete(entityToRemove)
        coreDataStack.saveContext()
        entityArray.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        tableView.reloadData()
    }
    
}

//MARK:- TextFieldDelegate
extension ViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        entityName = textField.text
        operateDataBase(entityName: entityName)
        textField.clearsOnBeginEditing = true
        textField.resignFirstResponder() //收键盘
        return true
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    } //点击空白处键盘返回
}

