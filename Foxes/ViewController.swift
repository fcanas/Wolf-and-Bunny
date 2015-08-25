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

let world :UInt32 = 200

enum Direction :Int {
    case Up    = 0
    case Down  = 1
    case Left  = 2
    case Right = 3
}

let updateInterval :NSTimeInterval = 0.016

class ViewController: NSViewController {
    
    @IBOutlet var reproductiveAgeSlider :NSSlider?
    @IBOutlet var reproductiveAgeLabel :NSTextField?
    var reproductiveAge :Int = 100
    
    @IBOutlet var reproductiveThresholdSlider :NSSlider?
    @IBOutlet var reproductiveThresholdLabel :NSTextField?
    var initialBelly :Int = 300
    
    @IBOutlet var huntRateSlider :NSSlider?
    @IBOutlet var huntRateLabel :NSTextField?
    var huntRate :Int = 10
    
    @IBOutlet var canvas :Canvas?
    @IBOutlet var foxLabel :NSTextField?
    @IBOutlet var rabbitLabel :NSTextField?
    
    var timer :NSTimer?
    
    @IBAction func age(sender: AnyObject?) {
        reproductiveAge = (reproductiveAgeSlider?.integerValue)!
        reproductiveAgeLabel?.integerValue = reproductiveAge
    }
    
    @IBAction func reproduction(sender: AnyObject?) {
        reproductiveAge = (reproductiveThresholdSlider?.integerValue)!
        reproductiveThresholdLabel?.integerValue = reproductiveAge
    }
    
    @IBAction func hunt(sender: AnyObject?) {
        huntRate = (huntRateSlider?.integerValue)!
        huntRateLabel?.integerValue = huntRate
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reproductiveAgeSlider?.integerValue = reproductiveAge
        reproductiveAgeLabel?.integerValue = reproductiveAge
        
        reproductiveThresholdSlider?.integerValue = initialBelly
        reproductiveThresholdLabel?.integerValue = initialBelly
        
        huntRateSlider?.integerValue = huntRate
        huntRateLabel?.integerValue = huntRate
        
        timer =  NSTimer(timeInterval: updateInterval, target: self, selector: Selector("tick"), userInfo: nil, repeats: true)
        NSRunLoop.mainRunLoop().addTimer(timer!, forMode: NSRunLoopCommonModes)
        let numBunnies = 600
        let numFoxes = 75
        foxes = fill(foxes, number: numFoxes, belly: initialBelly)
        bunnies = fill(bunnies, number: numBunnies, belly: initialBelly)
        
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
            case .Down:
                i.y -= 1
            case .Left:
                i.x -= 1
            case .Right:
                i.x += 1
            }
            if i.x < 0 {
                i.x = Int(world) - 1
            }
            i.x = i.x % Int(world)
            if i.y < 0 {
                i.y = Int(world) - 1
            }
            i.y = i.y % Int(world)
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
                        children.append(Point<Int>(x: p1.x, y: p1.y, belly: initialBelly, age: 0))
                        parents.removeAtIndex(i)
                        break
                    }
                }
            }
        }
        return Population(items: p.items + children, color: p.color)
    }
    
    func eat(foxes: Population, rabbits: Population) -> (foxes: Population, rabbits: Population) {
        var rs = rabbits.items
        var fs = Array<Point<Int>>()
        for f in foxes.items {
            var fb = f.belly
            for (i, r) in rs.enumerate() {
                if r.overlapping(f) {
                    rs.removeAtIndex(i)
                    fb += 200
                    break
                }
            }
            fs.append(Point<Int>(x:f.x, y:f.y, belly: fb, age:f.age))
        }
        return (Population(items: fs, color: foxes.color), Population(items: rs, color: rabbits.color))
    }
    
    func parthenogenisis(p: Population) -> Population {
        let newItems = p.items.reduce(Array<Point<Int>>()) { (a, i) -> Array<Point<Int>> in
            if i.belly >= 2 * initialBelly {
                return a + [
                    Point<Int>(x:i.x, y: i.y, belly: initialBelly, age: 0),
                    Point<Int>(x:i.x, y: i.y, belly: initialBelly, age: i.age)
                ]
            } else {
                return a + [i]
            }
        }
        return Population(items: newItems, color: p.color)
    }
    
    func age(p :Population) -> Population {
        return Population(items: p.items.map({ Point<Int>(x: $0.x, y: $0.y, belly: $0.belly - 1, age: $0.age + 1) }), color: p.color)
    }
    
    func cull(p :Population) -> Population {
        return Population(items: p.items.filter({
            $0.belly > 0
        }), color: p.color)
    }
    
    func tick_bg() {
        bunnies = age(bunnies)
        bunnies = reproduce(bunnies)
        
        bunnies = move(bunnies)
        
        foxes = age(foxes)
        foxes = reproduce(foxes)
        
        for var hunt = 0; hunt < huntRate; hunt++ {
            foxes = move(foxes)
            (foxes, bunnies) = eat(foxes, rabbits: bunnies)
        }
        
        foxes = cull(foxes)
        
        canvas?.foxes = foxes
        canvas?.bunnies = bunnies
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.canvas?.setNeedsDisplayInRect(self.canvas!.bounds)
            
            self.foxLabel?.stringValue = "\(foxes.items.count)🐺"
            self.rabbitLabel?.stringValue = "🐇\(bunnies.items.count)"
        }
    }
    
    func tick() {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)) { () -> Void in
            self.tick_bg()
        }
        
    }
}
