//
//  Canvas.swift
//  Foxes
//
//  Created by Fabian Canas on 8/24/15.
//  Copyright © 2015 Fabian Canas. All rights reserved.
//

import AppKit

class Canvas: NSView {
    
    var foxes   :Population = Population(items: [], color: NSColor.orangeColor())
    var bunnies :Population = Population(items: [], color: NSColor.grayColor())
    
    let squareWidth = 2
    
    override func drawRect(rect: CGRect) {
        draw(foxes)
        draw(bunnies)
    }
    
    func draw(p :Population) {
        p.color.setFill()
        for i in p.items {
            NSRectFill(NSRect(x: i.x * squareWidth, y: i.y * squareWidth, width: squareWidth, height: squareWidth))
        }
    }
    
}
