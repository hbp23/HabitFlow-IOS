//
//  TodayViewModel.swift
//  HabitFlow
//
//  Created by Harsh Patel.
//

import Foundation
import Combine

struct TodayHabitItem: Identifiable {
    var habit: Habit
    var log: HabitLog?
    
    var id: String { habit.id ?? UUID().uuidString}
    var completedCount: Int {
        log?.completedCount ?? 0
    }
    var targetPerDay: Int {
        habit.targetPerDay
    }
    var isCompleted: Bool {
        log?.isCompleted ?? false
    }
    var progressText: String {
        "\(completedCount)/\(targetPerDay)"
    }
}

final class TodayViewModel: ObservableObject {
    @Published var items: [TodayHabitItem] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let repository: HabitRepository
    private let calendar: Calendar
    private var userID: String?
    private var allHabits: [Habit] = []
    
    init(repository: HabitRepository = HabitRepository(), calendar: Calendar = .current) {
        self.repository = repository
        self.calendar = calendar
    }
    
    func refresh(userId: String, habits: [Habit]) {
        self.userID = userId
        self.allHabits = habits
        let today = Date()
        let todayString = today.toHabitDateString(calendar: calendar)
        isLoading = true
        errorMessage = nil
        
        repository.fetchLogsForLastNDays(userId: userId, days: 1) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.items = []
                    
                case .success(let logs):
                    
                    let todaysLogs = logs.filter { $0.dateString == todayString }
                    
                    let logByHabitId = Dictionary(
                        grouping: todaysLogs,
                        by: { $0.habitId }
                    ).compactMapValues { $0.first }
                    
                    let dueHabits = habits.filter { habit in
                        habit.isScheduled(on: today, calendar: self.calendar)
                    }
                    
                    self.items = dueHabits
                        .sorted(by: { $0.sortOrder < $1.sortOrder })
                        .map { habit in
                            TodayHabitItem(
                                habit: habit,
                                log: logByHabitId[habit.id ?? ""]
                            )
                        }
                }
            }
        }
    }
    
    func incrementCompletion(for item: TodayHabitItem) {
        guard let userId = userID else { return }
        guard let index = items.firstIndex(where: { $0.id == item.id}) else { return }
        
        let habit = items[index].habit
        let today = Date()
        let currentLog: HabitLog
        if let existing = items[index].log {
            currentLog = existing
        } else {
            currentLog = HabitLog.newForToday(
                habit: habit,
                userId: userId,
                date: today,
                calendar: calendar
            )
        }
        let updatedLog = currentLog.incremented(maxToTarget: true)
        items[index].log = updatedLog
        
        repository.upsertLog(updatedLog) { [weak self] result in
            guard let self = self else { return }
            if case .failure(let error) = result {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
