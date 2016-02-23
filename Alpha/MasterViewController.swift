//
//  MasterViewController.swift
//  Alpha
//
//  Created by Matthew Newberry on 9/19/14.
//  Copyright (c) 2014 OpenTable. All rights reserved.
//

import UIKit
import CoreData

class MasterViewController: UIViewController {

    let colors = [UIColor.blueColor(), UIColor.redColor(), UIColor.greenColor()]
    
    @IBOutlet weak var myView: MyView!
    var myModel = MyViewModel()
    var binding: Binding!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        binding = Binding(receiver: myView, toModel: myModel)
        view.addSubview(myView)
        
        NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "doColor", userInfo: nil, repeats: true)
    }
    
    func doColor() {
        let index: Int = Int(arc4random_uniform(UInt32(colors.count)))
        let color = colors[index]
        myModel.labelBackgroundColor = color
        
        let index1: Int = Int(arc4random_uniform(UInt32(colors.count)))
        let color1 = colors[index1]
        myModel.backgroundColor = color1
        myModel.labelFont = UIFont.systemFontOfSize(CGFloat(arc4random_uniform(50)))
        
        let alpha: Float = Float(arc4random_uniform(100))
        myModel.alpha = alpha / 100
        
        myModel.customVar = "Hello! \(alpha)"
        
        binding.enabled = myModel.alpha > 0.5
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

