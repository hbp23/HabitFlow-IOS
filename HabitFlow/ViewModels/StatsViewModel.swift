//
//  StatsViewModel.swift
//  HabitFlow
//
//  Created by Harsh Patel.
//

import Foundation
import Combine

final class StatsViewModel: ObservableObject {
    @Published var summary: StatsSummary = StatsSummary(
        totalHabits: 0,
        activeHabits: 0,
        completionRateLast7Days: 0,
        bestHabitName: nil,
        totalCompletionsLast7Days: 0
    )
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let repository: HabitRepository
    private let calendar: Calendar
    
    init(repository: HabitRepository = HabitRepository(), calendar: Calendar = .current) {
        self.repository = repository
        self.calendar = calendar
    }
    
    func refresh(userId: String, habits: [Habit]) {
        isLoading = true
        errorMessage = nil
        
        repository.fetchLogsForLastNDays(userId: userId, days: 7) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.summary = StatsSummary(
                        totalHabits: habits.count,
                        activeHabits: habits.filter { !$0.isArchived }.count,
                        completionRateLast7Days: 0,
                        bestHabitName: nil,
                        totalCompletionsLast7Days: 0
                    )
                case .success(let logs):
                    self.summary = self.computeSummary(habits: habits, logs: logs)
                }
            }
        }
    }
    
    private func computeSummary(habits: [Habit], logs: [HabitLog]) -> StatsSummary {
        let totalHabits = habits.count
        let activeHabitsList = habits.filter { !$0.isArchived }
        let activeHabits = activeHabitsList.count
        
        let today = Date()
        let last7Dates: [Date] = (0..<7)
            .compactMap { offset in
                calendar.date(byAdding: .day, value: -offset, to: today)
            }
            .sorted()
        

        var logByKey: [String: HabitLog] = [:]
        for log in logs {
            let key = "\(log.habitId)|\(log.dateString)"
            logByKey[key] = log
        }
        
        var totalScheduledSlots = 0
        var totalCompletedSlots = 0
        
        for date in last7Dates {
            let dateString = date.toHabitDateString(calendar: calendar)
            
            for habit in activeHabitsList {
                if habit.isScheduled(on: date, calendar: calendar) {
                    totalScheduledSlots += 1
                    let key = "\(habit.id ?? "")|\(dateString)"
                    if let log = logByKey[key], log.isCompleted {
                        totalCompletedSlots += 1
                    }
                }
            }
        }
        
        let completionRate: Double = totalScheduledSlots == 0
            ? 0
            : Double(totalCompletedSlots) / Double(totalScheduledSlots)
        
        let totalCompletions = logs.reduce(0) { $0 + $1.completedCount }
        
        var countsByHabitId: [String: Int] = [:]
        for log in logs {
            countsByHabitId[log.habitId, default: 0] += log.completedCount
        }
        
        let bestHabitId = countsByHabitId.max(by: { $0.value < $1.value })?.key
        let bestHabitName = habits.first(where: { $0.id == bestHabitId })?.name
        
        return StatsSummary(
            totalHabits: totalHabits,
            activeHabits: activeHabits,
            completionRateLast7Days: completionRate,
            bestHabitName: bestHabitName,
            totalCompletionsLast7Days: totalCompletions
        )
    }
    
}
