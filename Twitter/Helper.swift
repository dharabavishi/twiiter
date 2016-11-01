//
//  Helper.swift
//  Twitter
//
//  Created by Ruchit Mehta on 10/31/16.
//  Copyright © 2016 Dhara Bavishi. All rights reserved.
//

import UIKit

class Helper: NSObject {
    class func timeAgoSinceDate(date: Date, numericDates:Bool) -> String {
        let calendar = Calendar.current
        let unitFlags = Set<Calendar.Component>(arrayLiteral: Calendar.Component.minute, Calendar.Component.hour, Calendar.Component.day, Calendar.Component.weekOfYear, Calendar.Component.month, Calendar.Component.year, Calendar.Component.second)
        let now = Date()
        let dateComparison = now.compare(date)
        var earliest: Date
        var latest: Date
        
        switch dateComparison {
        case .orderedAscending:
            earliest = now
            latest = date
        default:
            earliest = date
            latest = now
        }
        
        let components: DateComponents = calendar.dateComponents(unitFlags, from: earliest, to: latest)
        
        guard
            let year = components.year,
            let month = components.month,
            let weekOfYear = components.weekOfYear,
            let day = components.day,
            let hour = components.hour,
            let minute = components.minute,
            let second = components.second
            else {
                fatalError()
        }
        
        if (year >= 2) {
            return getOnlyDate(date: date)
        } else if (year >= 1) {
            return getOnlyDate(date: date)
        } else if (month >= 2) {
            return getOnlyDate(date: date)
        } else if (weekOfYear >= 1) {
            return getOnlyDate(date: date)
        } else if (day >= 2) {
            return "\(components.day!)d"
        } else if (day >= 1){
            if (numericDates){
                return "1d"
            } else {
                return "1d"
            }
        } else if (hour >= 2) {
            return "\(hour)h"
        } else if (hour >= 1){
            if (numericDates){
                return "1h"
            } else {
                return "1h"
            }
        } else if (minute >= 2) {
            return "\(minute)m"
        } else if (minute >= 1){
            if (numericDates){
                return "1m"
            } else {
                return "1m"
            }
        } else if (second >= 3) {
            return "\(second)s"
        } else {
            return "now"
        }
        
        
    }
    class  func getOnlyDate(date : Date)->String{
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        
        let date = dateFormatter.string(from: date)
        return date
    }
    class func getDateTime(date : Date)->String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
        
        let date = dateFormatter.string(from: date)
        return date
        }
}
