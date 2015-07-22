//
//  PropertyListXMLWritable.swift
//  PropertyListEditor
//
//  Created by Prachi Gauriar on 7/19/2015.
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

import Foundation


protocol PropertyListXMLWritable {
    func addPropertyListXMLElementToParentElement(parentXMLElement: NSXMLElement)
}


extension PropertyListXMLWritable {
    func propertyListXMLDocumentData() -> NSData {
        let baseXMLString = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n" +
            "<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">\n" +
            "<plist version=\"1.0\"></plist>"

        let XMLDocument = try! NSXMLDocument(XMLString: baseXMLString, options: 0)
        self.addPropertyListXMLElementToParentElement(XMLDocument.rootElement()!)
        return XMLDocument.XMLDataWithOptions(NSXMLNodePrettyPrint | NSXMLNodeCompactEmptyElement)
    }
}


extension PropertyListItem: PropertyListXMLWritable {
    func addPropertyListXMLElementToParentElement(parentXMLElement: NSXMLElement) {
        switch self {
        case let .ArrayItem(array):
            array.addPropertyListXMLElementToParentElement(parentXMLElement)
        case let .BooleanItem(boolean):
            parentXMLElement.addChild(NSXMLElement(name: boolean.boolValue ? "true" : "false"))
        case let .DataItem(data):
            parentXMLElement.addChild(NSXMLElement(name: "data", stringValue: data.base64EncodedStringWithOptions([])))
        case let .DateItem(date):
            parentXMLElement.addChild(NSXMLElement(name: "date", stringValue: NSDateFormatter.propertyListXMLDateFormatter().stringFromDate(date)))
        case let .DictionaryItem(dictionary):
            dictionary.addPropertyListXMLElementToParentElement(parentXMLElement)
        case let .NumberItem(number):
            if number.isInteger {
                parentXMLElement.addChild(NSXMLElement(name: "integer", stringValue: "\(number.integerValue)"))
            } else {
                parentXMLElement.addChild(NSXMLElement(name: "real", stringValue: "\(number.doubleValue)"))
            }
        case let .StringItem(string):
            parentXMLElement.addChild(NSXMLElement(name: "string", stringValue: string as String))
        }
    }
}


extension PropertyListArray: PropertyListXMLWritable {
    func addPropertyListXMLElementToParentElement(parentXMLElement: NSXMLElement) {
        let arrayXMLElement = NSXMLElement(name: "array")
        for element in self.elements {
            element.addPropertyListXMLElementToParentElement(arrayXMLElement)
        }

        parentXMLElement.addChild(arrayXMLElement)
    }
}


extension PropertyListDictionary: PropertyListXMLWritable {
    func addPropertyListXMLElementToParentElement(parentXMLElement: NSXMLElement) {
        let dictionaryXMLElement = NSXMLElement(name: "dict")
        for keyValuePair in self.elements {
            dictionaryXMLElement.addChild(NSXMLElement(name: "key", stringValue: keyValuePair.key))
            keyValuePair.value.addPropertyListXMLElementToParentElement(dictionaryXMLElement)
        }

        parentXMLElement.addChild(dictionaryXMLElement)
    }
}
