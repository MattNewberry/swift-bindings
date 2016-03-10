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
    
    public init(receiver receiver_: AnyObject, toModel model_:AnyObject) {
        super.init()
        receiver = receiver_
        model = model_
        
        let viewProperties = propertiesForObject(receiver_)
        let modelProperties = propertiesForObject(model_, recursive: false)
        
        for key in viewProperties {
            for modelKey in modelProperties {
                
                if !observedProperties.contains(modelKey) {
                    model_.addObserver(self, forKeyPath: modelKey, options: .New, context: bindingContext)
                    observedProperties += [modelKey]
                }
                
                if modelKey == key {
                    receiver_.setValue(model_.valueForKey(modelKey), forKeyPath: key)
                    propertyMap[modelKey] = key
                } else if String(modelKey.characters.prefix(key.characters.count)) == key {
                    let complete = String(modelKey.characters.suffix(modelKey.characters.count - key.characters.count))
                    
                    if complete.characters.count > 0 {
                        let first = String(complete.characters.prefix(1)).lowercaseString
                        let property = first + String(complete.characters.suffix(complete.characters.count - 1))
                        let keyPath = key + "." + property
                        receiver_.setValue(model_.valueForKey(modelKey), forKeyPath: keyPath)
                        propertyMap[modelKey] = keyPath
                    }
                }
            }
        }
    }

    public override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        guard
            let keyPath = keyPath,
            let change = change else {
            return
        }
        
        if context == bindingContext {
            if let destKey = propertyMap[keyPath] {
                if let newValue: AnyObject = change[NSKeyValueChangeNewKey] {
                    receiver!.setValue(newValue, forKeyPath: destKey)
                }
            }
        } else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }
    
    func propertiesForObject(obj: AnyObject, recursive: Bool = true) -> [String] {
        var properties = [String]()
        
        let klasses = recursive ? klassesForKlass(obj.dynamicType) : [obj.dynamicType]
        
        for klass in klasses {
            var methodCount: UInt32 = 0
            let methods = class_copyMethodList(klass, &methodCount)
            for i in 0..<methodCount {
                let name = method_getName(methods[Int(i)]).description
                if String(name.characters.prefix(3)) == "set" {
                    var property = String(name.characters.suffix(name.characters.count - 3))
                    
                    // remove trailing ":"
                    property = String(property.characters.prefix(property.characters.count - 1))
                    
                    //lowercase first letter
                    let first = String(property.characters.prefix(1)).lowercaseString
                    
                    // join lowercase prefix to property
                    property = first + String(property.characters.suffix(property.characters.count - 1))
                    print(property)
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