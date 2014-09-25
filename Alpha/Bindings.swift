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

public class Binding: NSObject {
    private lazy var bindingContext = UnsafeMutablePointer<Void>.alloc(1)
    
    public weak var receiver: AnyObject?
    public weak var model: AnyObject?
    
    private var propertyMap: [String:String] = [String:String]()
    private lazy var observedProperties: [String] = [String]()
    
    public var enabled: Bool = true {
        didSet {
            if enabled != oldValue {
                for modelKey in observedProperties {
                    if enabled {
                        model?.addObserver(self, forKeyPath: modelKey, options: .New, context: bindingContext)
                    } else {
                        model?.removeObserver(self, forKeyPath: modelKey)
                    }
                }
            }
        }
    }
    
    init(receiver receiver_: AnyObject, toModel model_:AnyObject) {
        super.init()
        receiver = receiver_
        model = model_
        
        let viewProperties = propertiesForObject(receiver_)
        let modelProperties = propertiesForObject(model_, recursive: false)
        
        for key in viewProperties {
            for modelKey in modelProperties {
                
                if !contains(observedProperties, modelKey) {
                    model_.addObserver(self, forKeyPath: modelKey, options: .New, context: bindingContext)
                    observedProperties += [modelKey]
                }
                
                if modelKey == key {
                    receiver_.setValue(model_.valueForKey(modelKey), forKeyPath: key)
                    propertyMap[modelKey] = key
                } else if prefix(modelKey, countElements(key)) == key {
                    let complete = suffix(modelKey, countElements(modelKey) - countElements(key))
                    
                    if countElements(complete) > 0 {
                        let first = prefix(complete, 1).lowercaseString
                        let property = first + suffix(complete, countElements(complete) - 1)
                        let keyPath = key + "." + property
                        receiver_.setValue(model_.valueForKey(modelKey), forKeyPath: keyPath)
                        propertyMap[modelKey] = keyPath
                    }
                }
            }
        }
    }
    
    override public func observeValueForKeyPath(keyPath: String!, ofObject object: AnyObject!, change: [NSObject : AnyObject]!, context: UnsafeMutablePointer<Void>) {
        if context == bindingContext {
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
                    if obj.respondsToSelector(Selector(property)){
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