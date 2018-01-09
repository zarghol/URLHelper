//
//  ViewController.swift
//  URLHelper
//
//  Created by clement on 05/01/2018.
//  Copyright © 2018 Clement Nonn. All rights reserved.
//

import UIKit

enum RequestArrayError: Error {
    case missingSection, unknownHeader
}

class ViewController: UITableViewController {
    
    @IBOutlet weak var displayedSegmentedControl: UISegmentedControl!

    var collections = GlobalFileStore.default.collections {
        didSet {
            GlobalFileStore.default.collections = collections
        }
    }
    
    var history = GlobalFileStore.default.history {
        didSet {
            GlobalFileStore.default.history = history
        }
    }
    
    private func getArray(for section: Int?) throws -> [Request] {
        if displayedSegmentedControl.selectedSegmentIndex == 0 {
            guard let section = section else {
                throw RequestArrayError.missingSection
            }
            guard let headerTitle = self.tableView(tableView, titleForHeaderInSection: section) else {
                throw RequestArrayError.unknownHeader
            }
            return collections[headerTitle] ?? []
        } else {
            return history.map { $0.request }
        }
    }
    
    private func getRequest(_ indexPath: IndexPath) -> Request {
        let requestArray = try! self.getArray(for: indexPath.section)
        return requestArray[indexPath.row]
    }
    
    var params = [QueryParameter: UITextField]()
    
    func open(_ request: Request) {
        let paramsToAsk = request.parameters.filter { $0.isParameterizable }

        if paramsToAsk.count > 0 {
            let alert = UIAlertController(title: "parameters", message: nil, preferredStyle: .alert)
            
            for param in paramsToAsk {
                alert.addTextField(configurationHandler: { textfield in
                    textfield.placeholder = param.name
                    self.params[param] = textfield
                })
            }
            
            alert.addAction(UIAlertAction(title: "Annuler", style: .cancel, handler: { action in
                self.params = [:]
            }))
            
            alert.addAction(UIAlertAction(title: "Envoyer", style: .default, handler: { action in
                let url = request.url(handleParameter: { paramToHandle -> String? in
                    return self.params[paramToHandle]?.text
                })
                self.send(request, finalUrl: url)
            }))
            alert.addAction(UIAlertAction(title: "Envoyer val. defaut", style: .default, handler: { action in
                self.send(request, finalUrl: request.defaultUrl)
            }))
            
            self.present(alert, animated: true)
        } else {
            self.send(request, finalUrl: request.defaultUrl)
        }
    }
    
    func send(_ request: Request, finalUrl: URL) {
        let sent = SentRequest(request: request, sentQuery: finalUrl.query, date: Date())
        UIApplication.shared.open(finalUrl, options: [:], completionHandler: nil)
        if history.first != sent {
            history.insert(sent, at: 0)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.open(self.getRequest(indexPath))
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (try! self.getArray(for: section)).count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.displayedSegmentedControl.selectedSegmentIndex == 0 ? collections.count : 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard displayedSegmentedControl.selectedSegmentIndex == 0 else {
            return nil
        }
        let index = collections.keys.index(collections.keys.startIndex, offsetBy: section)
        return collections.keys[index]
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if displayedSegmentedControl.selectedSegmentIndex == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "requestCell", for: indexPath)
            let request = self.getRequest(indexPath)
            cell.textLabel?.text = request.name
            cell.detailTextLabel?.text = request.defaultUrl.absoluteString
            return cell
        } else {
            let history = self.history[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "requestCell", for: indexPath)
            cell.textLabel?.text = history.request.name
            cell.detailTextLabel?.text = "\(history.request.defaultUrl) with query : \(history.sentQuery ?? "")"
            return cell
        }
        
        
    }
    
    @IBAction func changeSelectedControl() {
        self.tableView.reloadData()
    }
    
    weak var requestField: UITextField?
    
    @IBAction func sendQuickRequest() {
        let alert = UIAlertController(title: "Quick Request", message: nil, preferredStyle: .alert)
        alert.addTextField { requestField in
            self.requestField = requestField
        }
        alert.addAction(UIAlertAction(title: "Annuler", style: .cancel, handler: { _ in
            self.requestField = nil
        }))
        
        alert.addAction(UIAlertAction(title: "Envoyer", style: .default, handler: { _ in
            let components = URLComponents(string: self.requestField!.text!)!
            
            let items = components.queryItems!.map { QueryParameter(name: $0.name, defaultValue: $0.value, isParameterizable: false) }
            let newRequest = Request(name: "untitled", scheme: components.scheme!, path: components.path, parameters: items)
            self.open(newRequest)
            self.requestField = nil
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func unwindWithNewRequest(segue: UIStoryboardSegue) {
        guard let newRequestVC = segue.source as? NewRequestViewController else {
            return
        }
        let request = newRequestVC.buildRequest()
        let category = newRequestVC.categoryTextfield.text ?? "default"
        var currentArray = collections[category] ?? [Request]()
        currentArray.append(request)
        collections[category] = currentArray
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

// Je veux pouvoir :
// 1. en un clic lancer une requete préconfiguré => url scheme, path, params,
// 2. créer une requete
// 3. sauvegarder l'historique des requetes

