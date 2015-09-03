//
//  MPContact.swift
//  WePlan
//
//  Created by James Hunter on 21/08/2015.
//
//

import Foundation
import AddressBook

class MPContact: Printable {
    let recordID: Int32
    let name: String
    let numberFormatter: MPPhoneNumberFormatter
    let hasImage: Bool
    var imagePath: String?
    var phoneNumbers = Set<String>()
    private let record: ABRecord
    
    var description: String {
        return "\(name): " + ", ".join(phoneNumbers) + (hasImage ? " 📷" : "")
    }
    
    var dictionaryRepresentation: [String: AnyObject] {
        var dict = [String: AnyObject]()
        dict["name"] = name
        dict["id"] = "\(recordID)"
        if phoneNumbers.count > 0 {
            dict["phoneNumbers"] = Array(phoneNumbers)
        }
        if let photo = imagePath {
            dict["photo"] = photo
        }
        
        return dict
    }
    
    private var hashValue: Int {
        let idString = "\(recordID):\(name)"
        return idString.hashValue
    }
    
    private var documentStoragePath: NSURL {
        let manager = NSFileManager()
        let paths = manager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask) as! [NSURL]
        let desiredURL = paths[0].URLByAppendingPathComponent("ContactCache")
        if manager.createDirectoryAtURL(desiredURL, withIntermediateDirectories: true, attributes: nil, error: nil) {
            return desiredURL
        } else {
            return paths[0]
        }
    }
    
    init(fromRecord record: ABRecord, withNumberFormatter numberFormatter: MPPhoneNumberFormatter) {
        self.record = record
        
        // ID
        self.recordID = ABRecordGetRecordID(record)
        
        // Name
        self.numberFormatter = numberFormatter
        self.name = ABRecordCopyCompositeName(record).takeRetainedValue() as String
        
        // Phone Numbers
        let numbers : ABMultiValueRef = ABRecordCopyValue(record, kABPersonPhoneProperty).takeRetainedValue()
        for var index = 0; index < ABMultiValueGetCount(numbers); ++index {
            let number: AnyObject = ABMultiValueCopyValueAtIndex(numbers, index).takeRetainedValue()
            let newNumber = numberFormatter.format(number as! String)
            
            self.phoneNumbers.insert(newNumber)
        }
        
        // Profile Picture
        self.hasImage = ABPersonHasImageData(record)
    }
    
    func fetchImageData() {
        let hashString = "\(hashValue)"
        
        if hasSavedImage(hashString) {
            imagePath = imagePathFor(hashString)
        } else {
            let image = getPNGImageForRecord(record)
            
            let imageURL = documentStoragePath.URLByAppendingPathComponent("\(hashString).png")
            imagePath = imageURL.absoluteString
            
            if image.writeToURL(imageURL, atomically: false) {
                rememberSavedImageWithIdentifier(hashString)
                setNoBackupFor(imageURL)
            } else {
                println("not saved")
            }
        }
    }
    
    func canMatchPhoneNumbers(numbers: Set<String>) -> Bool {
        return phoneNumbers.intersect(numbers).count > 0
    }
    
    private func getPNGImageForRecord(record: ABRecord) -> NSData {
        let data = ABPersonCopyImageDataWithFormat(record, kABPersonImageFormatThumbnail).takeRetainedValue()
        return UIImagePNGRepresentation( UIImage(data: data) )
    }
    
    private func imagePathFor(identifier: String) -> String? {
        let imageURL = documentStoragePath.URLByAppendingPathComponent("\(identifier).png")
        return imageURL.absoluteString
    }
    
    private func setNoBackupFor(imageURL: NSURL) {
        var error: NSError? = nil
        imageURL.setResourceValue(NSNumber(bool: true), forKey: NSURLIsExcludedFromBackupKey, error: &error)
    }
    
    private func hasSavedImage(imageRef: String) -> Bool {
        if let savedImages = DataStore.savedImages {
            return contains(savedImages, imageRef)
        } else {
            return false
        }
    }
    
    private func rememberSavedImageWithIdentifier(identifier: String) {
        if let storedImages = DataStore.savedImages {
            let imagesToSave = storedImages + [identifier]
            DataStore.saveImages(imagesToSave)
        } else {
            DataStore.saveImages([identifier])
        }
    }
    
    struct DataStore {
        private static let cachedImageKey = "savedContactImages"
        
        static var savedImages: [String]? {
            return NSUserDefaults.standardUserDefaults().objectForKey(cachedImageKey) as? [String]
        }
        
        static func saveImages(imageIdentifiers: [String]) {
            NSUserDefaults.standardUserDefaults().setObject(imageIdentifiers, forKey: cachedImageKey)
        }
    }
}
