//
//  HabitDetailView.swift
//  HabitFlow
//
//  Created by Harsh Patel
//

import SwiftUI

struct HabitDetailView: View {
    let habit: Habit
    let userId: String
    @StateObject private var habitDetailVM: HabitDetialViewModel
    
    init(habit: Habit, userId: String) {
        self.habit = habit
        self.userId = userId
        _habitDetailVM = StateObject(wrappedValue: HabitDetialViewModel(habit: habit, userId: userId))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                headerSection
                streakSection
                completionSection
                logsSection
            }
            .padding()
        }
        .refreshable {
            habitDetailVM.loadLogs(lastNDays: 14)
        }
        .navigationTitle(habit.name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            habitDetailVM.loadLogs(lastNDays: 14)
        }
    }
    
    private var headerSection: some View {
        HStack(spacing: 12) {
            Text(habit.emoji)
                .font(.system(size: 48))
                .frame(width: 64, height: 64)
                .background(Color(hex: habit.colorHex) ?? .accentColor.opacity(0.2))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(habit.name)
                    .font(.title2.bold())
                if let description = habit.description {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Text(habit.scheduleDescription)
                    .font(.subheadline)
            }
            Spacer()
        }
    }
    
    private var streakSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Streaks")
                .font(.headline)
            HStack {
                VStack(alignment: .leading) {
                    Text("Current")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(habitDetailVM.currentStreak) days")
                        .font(.title3.bold())
                }
                Spacer()
                VStack(alignment: .leading) {
                    Text("Longest")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(habitDetailVM.longestStreak) days")
                        .font(.title3.bold())
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var completionSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Last 7 days")
                .font(.headline)
            let rate = habitDetailVM.completionRateLast7Days
            Text(String(format: "Completion rate: %.0f%%", rate * 100))
                .font(.subheadline)
            ProgressView(value: rate)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var logsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Recent Activity")
                .font(.headline)
            
            if habitDetailVM.logs.isEmpty {
                Text("No activity yet.")
                    .foregroundColor(.secondary)
                    .font(.subheadline)
            } else {
                ForEach(habitDetailVM.logs) { log in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(log.dateString)
                                .font(.subheadline)
                            Spacer()
                            Text("\(log.completedCount)/\(log.targetPerDay)")
                                .font(.subheadline)
                        }
                        if let note = log.note, !note.isEmpty {
                            Text(note)
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(8)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    let sampleHabit = Habit(
        id: "preview-habit",
        userID: "preview-user",
        name: "Drink Water",
        description: "Drink 8 glasses of water",
        emoji: "💧",
        colorHex: "#3B82F6",
        frequency: .everyDay,
        daysOfWeek: [],
        targetPerDay: 3,
        isArchived: false,
        sortOrder: 0,
        createdAt: Date(),
        updatedAt: nil
    )
    HabitDetailView(habit: sampleHabit, userId: "preview-user")
}
