//
//  MPPhoneNumber.swift
//  WePlan
//
//  Created by James Hunter on 20/08/2015.
//
//

import Foundation

class MPPhoneNumberFormatter {
    var countryCode: String = "44"
    
    private let nonDigitCharSet: NSCharacterSet = {
        return NSCharacterSet.decimalDigitCharacterSet().invertedSet
    }()
    
    init() { }
    
    init(countryCode code: String) {
        self.countryCode = code
    }
    
    func format(number: String) -> String? {
        var output = number
        if number.hasPrefix("00") {
            output = substring(number, fromIndex: 2)
        }
        output = output.componentsSeparatedByCharactersInSet(nonDigitCharSet).joinWithSeparator("")
        if output.isEmpty { return nil }
        
        if !number.hasPrefix("+") {
            var initialIndex = 0
            switch countryCode {
            case "44": initialIndex = output.hasPrefix("44") ? 2 : 1
            case "99": initialIndex = output.hasPrefix("99") ? 2 : 0
            default: break
            }
            output = countryCode + substring(output, fromIndex: initialIndex)
        }
        
        return output
    }
    
    private func substring(string: String, fromIndex index: Int) -> String {
        return string[string.startIndex.advancedBy(index)..<string.endIndex]
    }
}
