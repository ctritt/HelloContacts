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
        
        navigationItem.rightBarButtonItem = editButtonItem
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.collectionViewLayout = ContactsCollectionViewLayout()
        
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
        contacts = try! store.unifiedContacts(matching: predicate, keysToFetch: keysToFetch).map{ contact in
            return HCContact(contact: contact)
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.collectionView.reloadData()
        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
    }
}

extension ViewController : UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "contactCell", for: indexPath) as! ContactCollectionViewCell
        
        let contact = contacts[indexPath.row]
        cell.nameLabel.text = "\(contact.givenName) \(contact.familyName)"
        contact.fetchImageIfNeeded()
        if let image = contact.contactImage {
            cell.contactImage.image = image
        }
        return cell
    }
}

extension ViewController : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: floor((collectionView.bounds.width - 2) / 3), height: 90)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        let cellsPerRow: CGFloat = 3
        let widthRemainder = (collectionView.bounds.width - (cellsPerRow-1)).truncatingRemainder(dividingBy: cellsPerRow) / (cellsPerRow-1)
        return 1 + widthRemainder
    }
}

extension ViewController : UICollectionViewDataSourcePrefetching {
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            let contact = contacts[indexPath.row]
            contact.fetchImageIfNeeded()
        }
    }
}

