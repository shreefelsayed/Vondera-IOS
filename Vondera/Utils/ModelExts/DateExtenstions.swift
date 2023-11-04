//
//  DateExtenstions.swift
//  Vondera
//
//  Created by Shreif El Sayed on 01/06/2023.
//

import Foundation
import FirebaseFirestore
import SwiftUI

extension Date {
    func toFirestoreTimestamp() -> Timestamp {
        return Timestamp(date: self)
    }
    
    func isSameDay(as otherDate: Date?) -> Bool {
        guard otherDate != nil else {
            return false
        }
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: self)
        let otherComponents = calendar.dateComponents([.year, .month, .day], from: otherDate!)
        
        return components.year == otherComponents.year &&
        components.month == otherComponents.month &&
        components.day == otherComponents.day
    }
    
    func isSameWeek(as otherDate: Date?) -> Bool {
        guard otherDate != nil else {
            return false
        }
        let calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        let otherComponents = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: otherDate!)
        
        return components.yearForWeekOfYear == otherComponents.yearForWeekOfYear &&
        components.weekOfYear == otherComponents.weekOfYear
    }
    
    func isSameMonth(as otherDate: Date?) -> Bool {
        guard otherDate != nil else {
            return false
        }
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: self)
        let otherComponents = calendar.dateComponents([.year, .month], from: otherDate!)
        
        return components.year == otherComponents.year &&
        components.month == otherComponents.month
    }
    
    func isSameYear(as otherDate: Date) -> Bool {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year], from: self)
        let otherComponents = calendar.dateComponents([.year], from: otherDate)
        
        return components.year == otherComponents.year
    }
    
    func timeAgoString() -> LocalizedStringKey {
            let interval = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self, to: Date())
            
            if let year = interval.year, year > 0 {
                return year == 1 ? "1 yr ago" : "\(year) yrs ago"
            } else if let month = interval.month, month > 0 {
                return month == 1 ? "1 month ago" : "\(month) months ago"
            } else if let day = interval.day, day > 0 {
                return day == 1 ? "1 day ago" : "\(day) days ago"
            } else if let hour = interval.hour, hour > 0 {
                return hour == 1 ? "1 hr ago" : "\(hour) hrs ago"
            } else if let minute = interval.minute, minute > 0 {
                return minute == 1 ? "1 min ago" : "\(minute) mins ago"
            } else if let second = interval.second, second > 0 {
                return second < 5 ? "Just now" : "\(second) seconds ago"
            } else {
                return "Just now"
            }
        }
    
    func daysAgo(_ days: Int) -> Date {
        let calendar = Calendar.current
        return calendar.date(byAdding: .day, value: -days, to: self) ?? self
    }
    
    func startOfDay() -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: self)
        return calendar.date(from: components)!
    }

    func endOfDay() -> Date {
        let calendar = Calendar.current
        var components = DateComponents()
        components.day = 1
        components.second = -1
        let startOfNextDay = calendar.date(byAdding: components, to: self.startOfDay())!
        return startOfNextDay
    }
}

extension Timestamp {
    func toDate() -> Date {
        return self.dateValue()
    }
}
