//: Playground - noun: a place where people can play

import AlphaFramework
import XCPlayground

let view = MyView(frame: CGRectMake(0,0,100,100))
let model = MyViewModel()

XCPlaygroundPage.currentPage.liveView = view
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

let binding = Binding(receiver: view, toModel: model)

model.backgroundColor = UIColor.orangeColor()
model.layerCornerRadius = 10
model.labelText = "Fabian"
