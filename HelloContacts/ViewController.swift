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
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.receivedLongPress(gestureRecognizer:)))
        collectionView.addGestureRecognizer(longPressRecognizer)
    }
    
    @objc func receivedLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
        let tappedPoint = gestureRecognizer.location(in: collectionView)
        guard let tappedIndexPath = collectionView.indexPathForItem(at: tappedPoint),
              let tappedCell = collectionView.cellForItem(at: tappedIndexPath) else { return }
        
        let confirmDialog = UIAlertController(title: "Delete this contact?", message: "Are you sure you want to delete this contact?", preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "Yes", style: .destructive, handler: { action in
            self.contacts.remove(at: tappedIndexPath.row)
            self.collectionView.deleteItems(at: [tappedIndexPath])
        })
        let cancelAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        confirmDialog.addAction(deleteAction)
        confirmDialog.addAction(cancelAction)
        
        if let popOver = confirmDialog.popoverPresentationController {
            popOver.sourceView = tappedCell
        }
        present(confirmDialog, animated: true, completion: nil)
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

extension ViewController : UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? ContactCollectionViewCell else { return }
        
        UIView.animate(withDuration: 0.1, delay: 0, options: [.curveEaseOut], animations: {
            cell.contactImage.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }, completion: { finished in
            UIView.animate(withDuration: 0.1, delay: 0, options: [.curveEaseIn], animations: {
                cell.contactImage.transform = CGAffineTransform.identity
            }, completion: nil)
        })
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

