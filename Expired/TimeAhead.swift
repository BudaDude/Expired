//
//  TimeAhead.swift
//  Expired
//
//  Created by George Nance on 5/11/16.
//  Copyright © 2016 George Nance. All rights reserved.
//

import Foundation


func timeAhead(date: NSDate)-> String{
    let calendar = NSCalendar.currentCalendar()
    let now = NSDate()
    let unitFlags: NSCalendarUnit = [.Day, .WeekOfYear, .Month, .Year]
    let components = calendar.components(unitFlags, fromDate: now, toDate: date, options: [])
    print(components.day)
    
    
    if (components.year > 1){
        return "in "
    }
    
    return ""
    
}