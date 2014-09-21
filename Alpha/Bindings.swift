//
//  Bindings.swift
//  Alpha
//
//  Created by Matthew Newberry on 9/19/14.
//  Copyright (c) 2014 OpenTable. All rights reserved.
//

import UIKit

extension Dictionary {
    mutating func update(other:Dictionary) {
        for (key,value) in other {
            self.updateValue(value, forKey:key)
        }
    }
}

class Binding: NSObject {
    private lazy var myContext = UnsafeMutablePointer<Void>.alloc(1)
    
    weak var receiver: AnyObject?
    var propertyMap: [String:String] = [String:String]()
    
    init(receiver receiver_: AnyObject, toModel model:AnyObject) {
        super.init()
        receiver = receiver_
        
        let viewProperties = propertiesForObject(receiver_)
        let modelProperties = propertiesForObject(model, recursive: false)
        var observing = [String]()
        
        for key in viewProperties {
            for modelKey in modelProperties {
                
                if !contains(observing, modelKey) {
                    model.addObserver(self, forKeyPath: modelKey, options: .New, context: myContext)
                    observing += [modelKey]
                }
                
                if modelKey == key {
                    receiver_.setValue(model.valueForKey(modelKey), forKeyPath: key)
                    propertyMap[modelKey] = key
                } else if prefix(modelKey, countElements(key)) == key {
                    let complete = (modelKey as NSString).substringFromIndex(countElements(key))
                    
                    if countElements(complete) > 0 {
                        let first = (complete as NSString).substringToIndex(1).lowercaseString
                        let property = first + (complete as NSString).substringFromIndex(1)
                        let keyPath = key + "." + property
                        receiver_.setValue(model.valueForKey(modelKey), forKeyPath: keyPath)
                        propertyMap[modelKey] = keyPath
                    }
                }
            }
        }
    }
    
    override func observeValueForKeyPath(keyPath: String!, ofObject object: AnyObject!, change: [NSObject : AnyObject]!, context: UnsafeMutablePointer<Void>) {
        if context == myContext {
            if let destKey = propertyMap[keyPath]? {
                if let newValue: AnyObject = change[NSKeyValueChangeNewKey]? {
                    receiver!.setValue(newValue, forKeyPath: destKey)
                }
            }
        } else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }
    
    func propertiesForObject(obj: AnyObject, recursive: Bool = true) -> [String] {
        var properties = [String]()
        
        var klasses = recursive ? klassesForKlass(obj.dynamicType) : [obj.dynamicType]
        var offLimits = ["observationInfo"]
                
        for klass in klasses {
            var methodCount: UInt32 = 0
            var methods = class_copyMethodList(klass, &methodCount)
            for i in 0..<methodCount {
                let name = method_getName(methods[Int(i)]).description
                if prefix(name, 3) == "set" {
                    var property = suffix(name, countElements(name) - 3)
                    
                    // remove trailing ":"
                    property = prefix(property, countElements(property) - 1)
                    
                    //lowercase first letter
                    let first = prefix(property, 1).lowercaseString
                    
                    // join lowercase prefix to property
                    property = first + suffix(property, countElements(property) - 1)
                    if obj.respondsToSelector(Selector(property)) && !contains(offLimits, property){
                        properties += [property]
                    }
                }
            }
            
            free(methods)
        }
        
        return properties
    }
    
    private func klassesForKlass(klass: AnyClass) -> [AnyClass] {
        var klasses = [klass]
        
        if let k: AnyClass = class_getSuperclass(klass) {
            klasses += klassesForKlass(k)
        }
        
        return klasses
    }
}