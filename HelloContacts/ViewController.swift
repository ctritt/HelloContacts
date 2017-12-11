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
    
    @IBOutlet var collectionView: UICollectionView!
    
    var contacts = [HCContact]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
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
        
        navigationItem.rightBarButtonItem = editButtonItem
        
        print(contacts)
        
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
    }
}



