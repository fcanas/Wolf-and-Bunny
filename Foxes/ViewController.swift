//
//  ViewController.swift
//  Foxes
//
//  Created by Fabian Canas on 8/24/15.
//  Copyright © 2015 Fabian Canas. All rights reserved.
//

import Cocoa
import Darwin

var foxes   :Population = Population(items: [], color: NSColor.orangeColor())
var bunnies :Population = Population(items: [], color: NSColor.grayColor())

let reproductiveAge = 100

let world :UInt32 = 200

enum Direction :Int {
    case Up    = 0
    case Down  = 1
    case Left  = 2
    case Right = 3
}

let updateInterval :NSTimeInterval = 0.016

class ViewController: NSViewController {

    @IBOutlet var canvas :Canvas?
    @IBOutlet var foxLabel :NSTextField?
    @IBOutlet var rabbitLabel :NSTextField?
    
    var timer :NSTimer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timer =  NSTimer(timeInterval: updateInterval, target: self, selector: Selector("tick"), userInfo: nil, repeats: true)
        NSRunLoop.mainRunLoop().addTimer(timer!, forMode: NSRunLoopCommonModes)
        let numBunnies = 100
        let numFoxes = 30
        foxes = fill(foxes, number: numFoxes, belly: 5)
        bunnies = fill(bunnies, number: numBunnies, belly: 5)
        
        foxLabel?.textColor = foxes.color
        rabbitLabel?.textColor = bunnies.color
    }
    
    func fill(population: Population, number: Int, belly: Int) -> Population {
        var num = number
        var items = Array<Point<Int>>()
        repeat {
            arc4random_uniform(world)
            items.append(Point<Int>(x:Int(arc4random_uniform(world)), y: Int(arc4random_uniform(world)), belly: belly, age: 0))
            num--
        } while num > 0
        return Population(items: items, color: population.color)
    }
    
    func move(pop: Population) -> Population {
        var items = Array<Point<Int>>()
        for var i in pop.items {
            switch Direction(rawValue: Int(arc4random_uniform(4)))! {
            case .Up:
                i.y += 1
                if i.y < 0 {
                    i.y = Int(world) - 1
                }
                i.y = i.y % Int(world)
            case .Down:
                i.y -= 1
                if i.y < 0 {
                    i.y = Int(world) - 1
                }
                i.y = i.y % Int(world)
            case .Left:
                i.x -= 1
                if i.x < 0 {
                    i.x = Int(world) - 1
                }
                i.x = i.x % Int(world)
            case .Right:
                i.x += 1
                if i.x < 0 {
                    i.x = Int(world) - 1
                }
                i.x = i.x % Int(world)
            }
            items.append(i)
        }
        return Population(items: items, color: pop.color)
    }
    
    func reproduce(p :Population) -> Population {
        var parents = p.items
        var children = Array<Point<Int>>()
        while parents.count > 0 {
            let p1 = parents.popLast()
            if p1?.age < reproductiveAge {
                continue
            }
            if let p1 = p1 {
                for (i, p2) in parents.enumerate() {
                    if p2.age < reproductiveAge {
                        continue
                    }
                    if p1.x == p2.x && p1.y == p2.y {
                        children.append(Point<Int>(x: p1.x, y: p1.y, belly: 15, age: 0))
                        parents.removeAtIndex(i)
                        break
                    }
                }
            }
            
        }
        return Population(items: p.items + children, color: p.color)
    }
    
    func age(p :Population) -> Population {
        return Population(items: p.items.map({ Point<Int>(x: $0.x, y: $0.y, belly: $0.belly, age: $0.age + 1) }), color: p.color)
    }
    
    func tick() {
        
        foxes = move(foxes)
        bunnies = move(bunnies)
        bunnies = reproduce(bunnies)
        bunnies = age(bunnies)
        
        canvas?.foxes = foxes
        canvas?.bunnies = bunnies
        canvas?.setNeedsDisplayInRect(canvas!.bounds)
        
        foxLabel?.stringValue = "\(foxes.items.count)🐺"
        rabbitLabel?.stringValue = "🐇\(bunnies.items.count)"
    }
    
    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

