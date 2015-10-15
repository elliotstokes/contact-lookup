//
//  MPPhoneNumber.swift
//  WePlan
//
//  Created by James Hunter on 20/08/2015.
//
//

import Foundation

enum CountryCode {
    case Trunked(String)
    case NonTrunked(String)
    
    private static let all: [CountryCode] = [
        .Trunked("33"),
        .Trunked("34"),
        .Trunked("44"),
        .Trunked("49"),
        .Trunked("61"),
        .Trunked("64"),
        .Trunked("91"),
        .Trunked("353"),
        .Trunked("971"),
        .Trunked("972"),
        .NonTrunked("1"),
        .NonTrunked("99")
    ]
    
    static func fromCode(code: String) -> CountryCode? {
        return self.all.filter { $0.hasCode(code) }.first
    }
    
    private func hasCode(code: String) -> Bool {
        switch self {
        case .Trunked    (let cCode): return code == cCode
        case .NonTrunked (let cCode): return code == cCode
        }
    }
}

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
        
        if !number.hasPrefix("+") && !number.hasPrefix("00") {
            var initialIndex = 0
            if let country = CountryCode.fromCode(countryCode) {
                switch country {
                case .Trunked(let code):    initialIndex = trunkedFirstIndexFor(output, with: code)
                case .NonTrunked(let code): initialIndex = nonTrunkedFirstIndexFor(output, with: code)
                }
            }
            output = countryCode + substring(output, fromIndex: initialIndex)
        }
        
        return output
    }
    
    private func trunkedFirstIndexFor(output: String, with countryCode: String) -> Int {
        if output.hasPrefix(countryCode) { return output.characters.count }
        if output.hasPrefix("0") { return 1 }
        return 0
    }
    
    private func nonTrunkedFirstIndexFor(output: String, with countryCode: String) -> Int {
        return output.hasPrefix(countryCode) ? output.characters.count : 0
    }
    
    private func substring(string: String, fromIndex index: Int) -> String {
        return string[string.startIndex.advancedBy(index)..<string.endIndex]
    }
}
