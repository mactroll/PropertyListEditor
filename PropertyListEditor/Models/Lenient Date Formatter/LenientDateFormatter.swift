//
//  LenientDateFormatter.swift
//  PropertyListEditor
//
//  Created by Prachi Gauriar on 7/16/2015.
//  Copyright © 2015 Quantum Lens Cap. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Cocoa


/// `LenientDateFormatter` instances read/write `NSDate` instances in a highly flexible way. Rather
/// than specifying an actual format, they use data detectors to parse dates in strings.
class LenientDateFormatter: NSFormatter {
    /// Returns an `NSDate` instance by parsing the specified string.
    /// - parameter string: The string to parse.
    /// - returns: The `NSDate` instance that was parsed or `nil` if parsing failed.
    func dateFromString(string: String) -> NSDate? {
        var date: AnyObject?
        self.getObjectValue(&date, forString: string, errorDescription: nil)
        return date as? NSDate
    }


    override func stringForObjectValue(obj: AnyObject) -> String? {
        return NSDateFormatter.propertyListDateOutputFormatter().stringForObjectValue(obj)
    }


    override func getObjectValue(obj: AutoreleasingUnsafeMutablePointer<AnyObject?>,
        forString string: String,
        errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>) -> Bool {
            do {
                let detector = try NSDataDetector(types: NSTextCheckingType.Date.rawValue)
                let matches = detector.matchesInString(string, options: NSMatchingOptions(), range: NSRange(location: 0, length: string.characters.count))

                for match in matches where match.date != nil {
                    obj.memory = match.date
                    return true
                }
            } catch {
                return false
            }

            return false
    }
}
