//
//  HabitDetialViewModel.swift
//  HabitFlow
//
//  Created by Harsh Patel.
//

import Foundation
import Combine

final class HabitDetialViewModel: ObservableObject {
    let habit: Habit
    private let userId: String
    private let repository: HabitRepository
    private let calendar: Calendar
    
    @Published var logs: [HabitLog] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    init(habit: Habit, userId: String, repository: HabitRepository = HabitRepository(), calendar: Calendar = .current) {
        self.habit = habit
        self.userId = userId
        self.repository = repository
        self.calendar = calendar
    }
    
    func loadLogs(lastNDays days: Int = 14) {
        guard let habitId = habit.id else { return }
            
        isLoading = true
        errorMessage = nil
            
        repository.fetchLogsForHabit(
            userId: userId,
            habitId: habitId,
            lastNDays: days
        ) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.logs = []
                case .success(let logs):
                    print("Loaded \(logs.count) logs for habit \(habitId)")
                    self.logs = logs.sorted { $0.dateString < $1.dateString }
                }
            }
        }
    }
    
    func updateNote(for log: HabitLog, note: String) {
        var updated = log
        updated.note = note
        updated.updatedAt = Date()
        
        repository.upsertLog(updated) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if case .failure(let error) = result {
                    self.errorMessage = error.localizedDescription
                } else {
                    if let index = self.logs.firstIndex(where: { $0.id == log.id }) {
                        self.logs[index] = updated
                    }
                }
            }
        }
    }
    
    var completionRateLast7Days: Double {
        let last7 = Array(logs.suffix(7))
        guard !last7.isEmpty else { return 0 }
        let completed = last7.filter { $0.isCompleted }.count
        return Double(completed) / Double(last7.count)
    }
    
    var currentStreak: Int {
        streaks().current
    }
    
    var longestStreak: Int {
        streaks().longest
    }
    
    private func streaks() -> (current: Int, longest: Int) {
        let sortedLogs = logs.sorted { $0.dateString < $1.dateString }
        guard !sortedLogs.isEmpty else { return (0, 0) }
        
        var longest = 0
        var current = 0
        
        var previousDate: Date?
        
        for log in sortedLogs {
            guard let date = Date.fromHabitDateString(log.dateString) else { continue }
            
            if log.isCompleted {
                if let prev = previousDate,
                    let diff = calendar.dateComponents([.day], from: prev, to: date).day,
                    diff == 1 {
                    current += 1
                } else {
                    current = 1
                }
                longest = max(longest, current)
            } else {
                current = 0
            }
            previousDate = date
        }
        
        return (current, longest)
    }
    
    
    
    
}
