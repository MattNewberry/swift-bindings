//
//  MyView.swift
//  Alpha
//
//  9/21/14
//  Copyright (c) 2014 OpenTable. All rights reserved.
//

import UIKit

public class MyView: UIView {
    var label: UILabel = UILabel()
    
    var customVar: String? {
        didSet {
            print("\(oldValue) is now \(customVar)")
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(label)
        
    }
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.addSubview(label)
    }
    
    override public func layoutSubviews() {
        label.frame = CGRectInset(self.bounds, 10, 10)
    }
}

public class MyViewModel: NSObject {
    dynamic var labelBackgroundColor: UIColor = UIColor.redColor()
    public dynamic var labelText: String = "hello!"
    dynamic var labelFont: UIFont = UIFont.systemFontOfSize(15)
    
    public dynamic var layerCornerRadius: CGFloat = 3
    dynamic var labelTextColor: UIColor = UIColor.greenColor()
    public dynamic var backgroundColor: UIColor = UIColor.blueColor()
    dynamic var alpha: Float = 1.0
    dynamic var customVar: String = "custom!"
    
    func objectDidUpdate(obj: AnyObject!) {
        let overdue = false
        
        if overdue {
            labelBackgroundColor = UIColor.redColor()
        } else {
            labelBackgroundColor = UIColor.blackColor()
        }
    }
}