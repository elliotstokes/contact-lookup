//
//  ContactLookup.swift
//  contactLookup
//
//  Created by James Hunter on 20/08/2015.
//  Copyright (c) 2015 JADH. All rights reserved.
//

import UIKit
import AddressBook

@objc(ContactLookup) class ContactLookup : CDVPlugin {
    var numberFormatter = MPPhoneNumberFormatter()
    var command = CDVInvokedUrlCommand()

    func lookupContact(command: CDVInvokedUrlCommand) {
        self.command = command
        
        if let phoneNumbers = command.argumentAtIndex(0) as? [String],
           let countryCode = command.argumentAtIndex(1) as? String {
            self.numberFormatter = MPPhoneNumberFormatter(countryCode: countryCode)
            
            setupAddressBookWithCompletion { (addressBookRef) in
                if let addressBook: ABAddressBookRef = addressBookRef {
                    let contacts = self.searchContactsIn(addressBook, forPhoneNumbers: phoneNumbers)
                    let responseArray = contacts.map { $0.dictionaryRepresentation }
                    self.sendPluginResponse(responseArray)
                } else {
                    println("denied")
                }
            }
        } else {
            sendPluginResponse(nil)
        }
    }

    private func setupAddressBookWithCompletion(completion: (ABAddressBookRef?) -> Void) {
        let addressBook: ABAddressBookRef = ABAddressBookCreateWithOptions(nil, nil).takeRetainedValue()
        
        ABAddressBookRequestAccessWithCompletion(addressBook) {
            (granted, error) -> Void in
            if (error != nil) {
                completion(nil)
            } else {
                completion(addressBook)
            }
        }
    }
    
    private func searchContactsIn(addressBook: ABAddressBookRef, forPhoneNumbers phoneNumbers: [String]) -> [MPContact] {
        let people = ABAddressBookCopyArrayOfAllPeople(addressBook).takeRetainedValue() as [ABRecord]
        let searchSet = Set(phoneNumbers)
        var response = [MPContact]()
        for person : ABRecord in people {
            let newPerson = MPContact(fromRecord: person, withNumberFormatter: numberFormatter)
            if newPerson.phoneNumbers.intersect(searchSet).count > 0 {
                if newPerson.hasImage { newPerson.fetchImageData() }
                response.append(newPerson)
            }
        }
        return response
    }
    
    private func sendPluginResponse(response: [AnyObject]?) {
        let pluginResult = pluginResponseFrom(response)
        self.commandDelegate.sendPluginResult(pluginResult, callbackId:command.callbackId)
    }
    
    private func pluginResponseFrom(response: [AnyObject]?) -> CDVPluginResult {
        if let responseArray = response {
            return CDVPluginResult(status: CDVCommandStatus_OK, messageAsArray: responseArray)
        } else {
            return CDVPluginResult(status: CDVCommandStatus_OK)
        }
    }
 
}
