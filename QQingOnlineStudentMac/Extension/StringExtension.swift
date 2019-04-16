//
//  StringExtension.swift
//  QQingOnlineStudentMac
//
//  Created by 陶澄 on 2019/1/30.
//  Copyright © 2019年 陶澄. All rights reserved.
//

import Foundation

extension String {
    
    var length: Int {
        return self.count
    }
    
    subscript (i: Int) -> String {
        return self[i ..< i + 1]
    }
    
    func substring(fromIndex: Int) -> String {
        if (fromIndex < 0 || fromIndex > length-1) {
            return ""
        } else {
            return self[min(fromIndex, length) ..< length]
        }
    }
    
    func substring(toIndex: Int) -> String {
        if (toIndex > length - 1) {
            return ""
        } else {
            return self[0 ..< max(0, toIndex)]
        }
    }
    
    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)), upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }
    
    //获取数字
    func getNumberFromString() -> String {
        let scanner = Scanner(string: self)
        scanner.scanUpToCharacters(from: CharacterSet.decimalDigits, into: nil)
        var number :Int = 0
        scanner.scanInt(&number)
        return String(number)
    }

    //检测输入号码合法性
    func validMobileNumber() -> Bool {
        let regex = "^1[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]$"
        let checkMobilePredicate = NSPredicate.init(format: "SELF MATCHES %@", regex)
        return checkMobilePredicate.evaluate(with:self)&&self.length == 11
    }

}
