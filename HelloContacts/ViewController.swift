//
//  ViewController.swift
//  HelloContacts
//
//  Created by TQL Mobile  on 12/5/17.
//  Copyright © 2017 University of Cincinnati. All rights reserved.
//

import UIKit
import Contacts

class ViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    var contacts = [HCContact]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.prefetchDataSource = self
        tableView.delegate = self
        
        
        let store = CNContactStore()
        let authorizationStatus = CNContactStore.authorizationStatus(for: .contacts)
        
        if authorizationStatus == .notDetermined {
            store.requestAccess(for: .contacts, completionHandler: {[weak self] authorized, error in
                if authorized {
                    self?.retrieveContacts(fromStore: store)
                }
            })
        }else if authorizationStatus == .authorized {
            retrieveContacts(fromStore: store)
        }
    }

    func retrieveContacts(fromStore store: CNContactStore) {
        let containerId = store.defaultContainerIdentifier()
        let predicate = CNContact.predicateForContactsInContainer(withIdentifier: containerId)
        
        let keysToFetch = [CNContactGivenNameKey as CNKeyDescriptor,
                           CNContactFamilyNameKey as CNKeyDescriptor,
                           CNContactImageDataKey as CNKeyDescriptor,
                           CNContactImageDataAvailableKey as CNKeyDescriptor]
        
        //let contacts = try! store.unifiedContacts(matching: predicate, keysToFetch: keysToFetch)
        contacts = try! store.unifiedContacts(matching: predicate, keysToFetch: keysToFetch).map{ contact in return HCContact(contact: contact) }
        
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
        
        navigationItem.rightBarButtonItem = editButtonItem
        
        print(contacts)
        
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        tableView.setEditing(editing, animated: animated)
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell") as! ContactTableViewCell
        let contact = contacts[indexPath.row]
        
        cell.nameLabel.text = "\(contact.givenName) \(contact.familyName)"
        
        contact.fetchImageIfNeeded()
        if let image = contact.contactImage {
            cell.contactImage.image = image
        }
        
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let contact = contacts[indexPath.row]
        
        let alertController = UIAlertController(title: "Contact Tapped", message: "You tapped \(contact.givenName)", preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Ok", style: .default, handler: {action in
            tableView.deselectRow(at: indexPath, animated: true)
        })
        alertController.addAction(dismissAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteHandler: UIContextualActionHandler = { [weak self] action, view, callback in
            self?.contacts.remove(at: indexPath.row)
            self?.tableView.beginUpdates()
            self?.tableView.deleteRows(at: [indexPath], with: .fade)
            self?.tableView.endUpdates()
            callback(true)
        }
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete", handler: deleteHandler)
        let actions = [deleteAction]
        let config = UISwipeActionsConfiguration(actions: actions)
        return config
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let contact = contacts.remove(at: sourceIndexPath.row)
        contacts.insert(contact, at: destinationIndexPath.row)
    }
}

extension ViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            let contact = contacts[indexPath.row]
            contact.fetchImageIfNeeded()
        }
    }
}



