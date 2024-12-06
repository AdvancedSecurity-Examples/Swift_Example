//
//  ContactService.swift
//  STTR
//
//  Created by Martin Carlisle on 6/7/21.
//

import Foundation
import ContactsUI
class ContactService {
    var contactStore : CNContactStore?
    
    //function used to ask for permission to use contacts
    func fetchOrRequestPermission(completionHandler: @escaping (Bool) -> Void) {
        self.contactStore = CNContactStore()
        self.contactStore!.requestAccess(for: .contacts) { success, error in
            if(success) {
                completionHandler(true)
            } else {
                completionHandler(false)
            }
        }
    }
    
    //function used to get contacts from user data if allowed by user
    func getContacts(completionHandler: @escaping ([Contact], Error?) -> Void) {
        self.fetchOrRequestPermission() { success in
            if(success) {
                do{
                    let keysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey] as [CNKeyDescriptor]
                    
                    var contacts = [CNContact]()
                    let request = CNContactFetchRequest(keysToFetch: keysToFetch)
                    
                    try self.contactStore!.enumerateContacts(with: request) {
                        (contact, stop) in
                        contacts.append(contact)
                    }
                    
                    func getName(_ contact: Contact) -> String {
                        return contact.lastName.count > 0 ? contact.lastName : contact.givenName
                    }
                    
                    let formatted = contacts.compactMap({
                        if($0.phoneNumbers.count > 0 && ($0.givenName.count > 0 || $0.familyName.count > 0)){
                            return Contact.fromCNContact(contact: $0)
                        }
                        
                        return nil
                    }).sorted(by: {getName($0) < getName($1) })
                    completionHandler(formatted, nil)
                } catch {
                    completionHandler([], NSError())
                }
            } else {
                completionHandler([], NSError())
            }
        }
    }
}
