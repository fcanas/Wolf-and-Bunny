//
//  ViewController.swift
//  Foxes
//
//  Created by Fabian Canas on 8/24/15.
//  Copyright © 2015 Fabian Canas. All rights reserved.
//

import Cocoa
import Darwin

let world :UInt32 = 200

enum Direction :Int {
    case Up    = 0
    case Down  = 1
    case Left  = 2
    case Right = 3
}

let updateInterval :NSTimeInterval = 0.016

class ViewController: NSViewController {
    
    var foxes   :Population = Population(items: [], color: NSColor.orangeColor())
    var bunnies :Population = Population(items: [], color: NSColor.grayColor())
    
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
        foxes = foxes.populate(numFoxes, belly: initialBelly)
        bunnies = bunnies.populate(numBunnies, belly: 200)
        
        foxLabel?.textColor = foxes.color
        rabbitLabel?.textColor = bunnies.color
    }
    
    func eat(foxes: Population, rabbits: Population) -> (foxes: Population, rabbits: Population) {
        var rs = rabbits.items
        var fs = Array<Point<Int>>()
        for f in foxes.items {
            var fb = f.belly
            for (i, r) in rs.enumerate() {
                if r.coincident(f) {
                    rs.removeAtIndex(i)
                    fb += r.belly
                    break
                }
            }
            fs.append(Point<Int>(x:f.x, y:f.y, belly: fb, age:f.age))
        }
        return (Population(items: fs, color: foxes.color), Population(items: rs, color: rabbits.color))
    }
    
    func tick_bg() {
        bunnies = bunnies.age().reproduce(reproductiveAge, foodThreshold: initialBelly).move(Int(world))
        
        foxes = foxes.age().reproduce(reproductiveAge, foodThreshold: initialBelly)
        //            .parthenogenerate(initialBelly)
        
        for var hunt = 0; hunt < huntRate; hunt++ {
            foxes = foxes.move(Int(world))
            (foxes, bunnies) = eat(foxes, rabbits: bunnies)
        }
        
        foxes = foxes.cull()
        
        canvas?.foxes = foxes
        canvas?.bunnies = bunnies
    }
    
    func tick() {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0)) { () -> Void in
            self.tick_bg()
        }
        
        self.canvas?.setNeedsDisplayInRect(self.canvas!.bounds)
        
        self.foxLabel?.stringValue = "\(foxes.items.count)🐺"
        self.rabbitLabel?.stringValue = "🐇\(bunnies.items.count)"
    }
}
