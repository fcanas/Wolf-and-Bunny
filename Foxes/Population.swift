
//  Population.swift
//  Foxes
//
//  Created by Fabian Canas on 8/24/15.
//  Copyright © 2015 Fabian Canas. All rights reserved.
//

import AppKit

struct Point<T :Equatable> {
    var x :T
    var y :T
    var belly :Int
    var age :Int
    func coincident(p:Point<T>) -> Bool {
        return x == p.x && y == p.y
    }
}

struct Population {
    let items :Array<Point<Int>>
    let color :NSColor
    
    func populate(number: Int, belly: Int) -> Population {
        var num = number
        var items = Array<Point<Int>>()
        repeat {
            arc4random_uniform(world)
            items.append(Point<Int>(x:Int(arc4random_uniform(world)), y: Int(arc4random_uniform(world)), belly: belly, age: 0))
            num--
        } while num > 0
        return Population(items: items, color: color)
    }
    
    func move(worldSize: Int) -> Population {
        var newItems = Array<Point<Int>>()
        for var i in items {
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
                i.x = worldSize - 1
            }
            i.x = i.x % worldSize
            if i.y < 0 {
                i.y = worldSize - 1
            }
            i.y = i.y % worldSize
            newItems.append(i)
        }
        return Population(items: items, color: color)
    }
    
    func age() -> Population {
        return Population(items: items.map({ Point<Int>(x: $0.x, y: $0.y, belly: $0.belly - 1, age: $0.age + 1) }), color: color)
    }
    
    func cull() -> Population {
        return Population(items: items.filter({
            $0.belly > 0
        }), color: color)
    }
    
    func parthenogenerate(threshold :Int) -> Population {
        let newItems = items.reduce(Array<Point<Int>>()) { (a, i) -> Array<Point<Int>> in
            if i.belly >= 2 * threshold {
                return a + [
                    Point<Int>(x:i.x, y: i.y, belly: threshold, age: 0),
                    Point<Int>(x:i.x, y: i.y, belly: threshold, age: i.age)
                ]
            } else {
                return a + [i]
            }
        }
        return Population(items: newItems, color: color)
    }
    
    func reproduce(age: Int, foodThreshold: Int) -> Population {
        var parents = items
        var children = Array<Point<Int>>()
        while parents.count > 0 {
            let p1 = parents.popLast()
            if p1?.age < age {
                continue
            }
            if let p1 = p1 {
                for (i, p2) in parents.enumerate() {
                    if p2.age < age {
                        continue
                    }
                    if p1.x == p2.x && p1.y == p2.y && p1.belly + p2.belly > 2 * foodThreshold {
                        children.append(Point<Int>(x: p1.x, y: p1.y, belly: foodThreshold, age: 0))
                        parents.removeAtIndex(i)
                        break
                    }
                }
            }
        }
        return Population(items: items + children, color: color)
    }
}