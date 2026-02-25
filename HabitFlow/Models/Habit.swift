//
//  Habit.swift
//  HabitFlow
//
//  Created by Harsh Patel.
//

import Foundation
import FirebaseFirestore

enum HabitFrequency: String, Codable, CaseIterable {
    case everyDay
    case specificDays
}

struct Habit: Identifiable, Codable {
    @DocumentID var id: String?
    
    var userID: String
    var name: String
    var description: String?
    var emoji: String
    var colorHex: String
    var frequency: HabitFrequency
    var daysOfWeek: [Int]
    var targetPerDay: Int
    var isArchived: Bool
    var sortOrder: Int
    var createdAt: Date
    var updatedAt: Date?
    
    
    
    
    func isScheduled(on date: Date, calendar: Calendar = .current) -> Bool {
        if isArchived { return false }
        
        switch frequency {
        case .everyDay:
            return true
        case .specificDays:
            let weekday = calendar.component(.weekday, from: date)
            return daysOfWeek.contains(weekday)
        }
    }
    
    var scheduleDescription: String {
        switch frequency {
        case .everyDay:
            return "Every Day"
        case .specificDays:
            if daysOfWeek.isEmpty { return "No days selected" }
            let symbols = Calendar.current.shortWeekdaySymbols
            let mapped = daysOfWeek.compactMap { index -> String? in
                guard index >= 1, index <= symbols.count else { return nil }
                return symbols[index - 1]
            }
            return mapped.joined(separator: ", ")
        }
    }
    
    static func new(
        userID: String,
        name: String,
        description: String?,
        emoji: String,
        colorHex: String,
        frequency: HabitFrequency,
        daysOfWeek: [Int],
        targetPerDay: Int,
        sortOrder: Int = 0
    ) -> Habit {
        Habit(
            id: nil,
            userID: userID,
            name: name,
            description: description,
            emoji: emoji,
            colorHex: colorHex,
            frequency: frequency,
            daysOfWeek: daysOfWeek,
            targetPerDay: targetPerDay,
            isArchived: false,
            sortOrder: sortOrder,
            createdAt: Date(),
            updatedAt: nil
        )
    }
}
