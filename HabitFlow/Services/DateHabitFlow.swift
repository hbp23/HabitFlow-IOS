//
//  DateHabitFlow.swift
//  HabitFlow
//
//  Created by Harsh Patel on 12/7/25.
//

import Foundation

extension Date {
    private static var habitDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    func toHabitDateString(calendar: Calendar = .current) -> String {
        let components = calendar.dateComponents([.year, .month, .day], from: self)
        let normalized = calendar.date(from: components) ?? self
        return Date.habitDateFormatter.string(from: normalized)
    }
    
    static func fromHabitDateString(_ string: String) -> Date? {
        habitDateFormatter.date(from: string)
    }
}
