//
//  FoodItem.swift
//  Expired
//
//  Created by George Nance on 3/23/16.
//  Copyright © 2016 George Nance. All rights reserved.
//

import Foundation
import RealmSwift

class FoodType: Object{
    dynamic var name = ""
}

class FoodItem : Object{
    dynamic var name=""
    dynamic var expirationDate : NSDate!
    dynamic let createdOn: NSDate = NSDate()
    dynamic var foodType : FoodType!
    dynamic var isFrozen = false
    dynamic var id = ""

    
    func isExpired()-> Bool{
        return (NSDate().timeIntervalSince1970 > expirationDate.timeIntervalSince1970)
    }
    func daysUntillExpiration()-> Int{
        return NSDate().numberOfDaysUntilDateTime(expirationDate)
    }
    //TODO: Add days until expiration
    
    
}

extension NSDate {
    func numberOfDaysUntilDateTime(toDateTime: NSDate, inTimeZone timeZone: NSTimeZone? = nil) -> Int {
        let calendar = NSCalendar.currentCalendar()
        if let timeZone = timeZone {
            calendar.timeZone = timeZone
        }
        
        var fromDate: NSDate?, toDate: NSDate?
        
        calendar.rangeOfUnit(.Day, startDate: &fromDate, interval: nil, forDate: self)
        calendar.rangeOfUnit(.Day, startDate: &toDate, interval: nil, forDate: toDateTime)
        
        let difference = calendar.components(.Day, fromDate: fromDate!, toDate: toDate!, options: [])
        return difference.day
    }
}