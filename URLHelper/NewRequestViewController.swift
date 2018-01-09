//
//  NewRequestViewController.swift
//  URLHelper
//
//  Created by clement on 05/01/2018.
//  Copyright © 2018 Clement Nonn. All rights reserved.
//

import UIKit

class NewRequestViewController: UIViewController {
    
    @IBOutlet weak var nameTextfield: UITextField!
    @IBOutlet weak var categoryTextfield: UITextField!
    @IBOutlet weak var schemeTextfield: UITextField!
    @IBOutlet weak var pathTextfield: UITextField!
    
    @IBOutlet weak var queryTableView: UITableView!
    
    var query = [QueryParameter]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    weak var itemNameTextfield: UITextField!
    weak var itemValueTextfield: UITextField!
    
    @IBAction func addQueryItem() {
        let alert = UIAlertController(title: "new item", message: nil, preferredStyle: .alert)
        alert.addTextField { textfield in
            textfield.placeholder = "name"
            self.itemNameTextfield = textfield
        }
        alert.addTextField { textfield in
            textfield.placeholder = "value"
            self.itemValueTextfield = textfield
        }
        alert.addAction(UIAlertAction(title: "Annuler", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
            let item = QueryParameter(name: self.itemNameTextfield.text!,
                                      defaultValue: self.itemValueTextfield.text,
                                      isParameterizable: true)
            self.itemNameTextfield = nil
            self.itemValueTextfield = nil
            self.query.append(item)
            self.queryTableView.reloadData()
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func buildRequest() -> Request {
        return Request(
            name: nameTextfield.text!,
            scheme: schemeTextfield.text!,
            path: pathTextfield.text!,
            parameters: query
        )
    }
    
    @IBAction func cancelRequest() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func createRequest() {
        self.performSegue(withIdentifier: "createRequestSegue", sender: self)
    }
}

extension NewRequestViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.query.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dequeuedCell = tableView.dequeueReusableCell(withIdentifier: "queryItemCell", for: indexPath)
        guard let cell = dequeuedCell as? QueryItemCell else {
            return dequeuedCell
        }
        cell.nameLabel.text = self.query[indexPath.row].name
        cell.defaultValueLabel.text = self.query[indexPath.row].defaultValue
        cell.isParameterizableSwitch.isOn = self.query[indexPath.row].isParameterizable
        cell.isParameterizableSwitch.removeTarget(self, action: #selector(self.changeParameterizable(sender:)), for: .valueChanged)
        cell.isParameterizableSwitch.addTarget(self, action: #selector(self.changeParameterizable(sender:)), for: .valueChanged)
        return cell
    }
    
    @objc func changeParameterizable(sender: UISwitch) {
        guard let cell = sender.superview?.superview as? QueryItemCell,
              let indexPath = queryTableView.indexPath(for: cell) else {
            return
        }
        
        self.query[indexPath.row].isParameterizable = sender.isOn
    }
}
