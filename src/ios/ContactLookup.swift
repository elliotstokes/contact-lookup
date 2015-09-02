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
    let addressBook: ABAddressBookRef? = {
        if let abRef = ABAddressBookCreateWithOptions(nil, nil) {
            return abRef.takeRetainedValue()
        } else {
            return nil
        }
    }()

    func lookupContacts(command: CDVInvokedUrlCommand) {
        self.command = command
        
        if let phoneNumbers = command.argumentAtIndex(0) as? [String],
           let countryCode = command.argumentAtIndex(1) as? String {
            
            commandDelegate.runInBackground {
                self.numberFormatter = MPPhoneNumberFormatter(countryCode: countryCode)
                
                self.setupAddressBookWithCompletion { (addressBookRef) in
                    if let addressBook: ABAddressBookRef = addressBookRef {
                        let contacts = self.searchContactsIn(addressBook, forPhoneNumbers: phoneNumbers)
                        let responseArray = contacts.map { $0.dictionaryRepresentation }
                        self.sendPluginResponse(responseArray)
                    } else {
                        self.sendPluginResponse(error: ["message": "AddressBook access denied"])
                    }
                }
            }
        } else {
            sendPluginResponse(error: ["message": "Not enough details provided"])
        }
    }

    private func setupAddressBookWithCompletion(completion: (ABAddressBookRef?) -> Void) {
        let authStatus = ABAddressBookGetAuthorizationStatus()
        
        switch authStatus {
        case .Authorized:          completion(addressBook!)
        case .Denied, .Restricted: completion(nil)
        case .NotDetermined:       requestAddressBookAccessWithCompletion(completion)
        }
    }
    
    private func requestAddressBookAccessWithCompletion(completion: (ABAddressBookRef?) -> Void) {
        ABAddressBookRequestAccessWithCompletion(addressBook!) { granted, _ in
            if granted {
                completion(self.addressBook!)
            } else {
                completion(nil)
            }
        }
    }
    
    private func searchContactsIn(addressBook: ABAddressBookRef, forPhoneNumbers phoneNumbers: [String]) -> [MPContact] {
        let people = ABAddressBookCopyArrayOfAllPeople(addressBook).takeRetainedValue() as [ABRecord]
        let searchSet = Set(phoneNumbers)
        var response = [MPContact]()
        for person: ABRecord in people {
            let newPerson = MPContact(fromRecord: person, withNumberFormatter: numberFormatter)
            if newPerson.canMatchPhoneNumbers(searchSet) {
                if newPerson.hasImage { newPerson.fetchImageData() }
                response.append(newPerson)
            }
        }
        return response
    }
    
    private func sendPluginResponse(response: [AnyObject]) {
        let pluginResult = pluginResponseFrom(response)
        self.commandDelegate.sendPluginResult(pluginResult, callbackId:command.callbackId)
    }
    
    private func sendPluginResponse(#error: [String: AnyObject]) {
        let pluginResult = pluginErrorResponseFrom(error)
        self.commandDelegate.sendPluginResult(pluginResult, callbackId:command.callbackId)
    }
    
    private func pluginResponseFrom(response: [AnyObject]) -> CDVPluginResult {
        return CDVPluginResult(status: CDVCommandStatus_OK, messageAsArray: response)
    }
    
    private func pluginErrorResponseFrom(error: [String: AnyObject]) -> CDVPluginResult {
        return CDVPluginResult(status: CDVCommandStatus_ERROR, messageAsDictionary: error)
    }
 
}
