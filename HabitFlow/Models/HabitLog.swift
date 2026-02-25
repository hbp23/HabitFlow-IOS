//
//  HabitLog.swift
//  HabitFlow
//
//  Created by Harsh Patel.
//

import Foundation
import FirebaseFirestore

struct HabitLog: Identifiable, Codable {
    @DocumentID var id: String?
    var habitId: String
    var userId: String
    var dateString: String
    var completedCount: Int
    var targetPerDay: Int
    var note: String?
    var createdAt: Date
    var updatedAt: Date?
    
    
    
    var isCompleted: Bool {
        completedCount >= targetPerDay
    }
    
    static func newForToday(
        habit: Habit,
        userId: String,
        date: Date = Date(),
        calendar: Calendar = .current
    ) -> HabitLog {
        let dateString = date.toHabitDateString(calendar: calendar)
        
        return HabitLog(
            id: nil,
            habitId: habit.id ?? "",
            userId: userId,
            dateString: dateString,
            completedCount: 0,
            targetPerDay: habit.targetPerDay,
            note: nil,
            createdAt: Date(),
            updatedAt: nil
        )
    }
    
    func incremented(maxToTarget: Bool = false) -> HabitLog {
        var copy = self
        if maxToTarget {
            copy.completedCount = max(copy.completedCount + 1, copy.completedCount)
            if copy.completedCount > copy.targetPerDay {
                copy.completedCount = copy.targetPerDay
            }
        } else {
            copy.completedCount += 1
        }
        copy.updatedAt = Date()
        return copy
    }
}
