//
//  StatsView.swift
//  HabitFlow
//
//  Created by Harsh Patel.
//

import SwiftUI

struct StatsView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var habitListVM: HabitListViewModel
    @StateObject private var statsVM = StatsViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if let error = statsVM.errorMessage {
                    ErrorBanner(message: error)
                }
                
                Group {
                    if statsVM.isLoading {
                        ProgressView("Loading stats...")
                    } else {
                        VStack(spacing: 24) {
                            summarySection
                            completionSection
                            bestHabitSection
                            Spacer()
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Stats")
        }
        .onAppear {
            if let userId = authVM.userId {
                statsVM.refresh(userId: userId, habits: habitListVM.habits)
            }
        }
        .refreshable {
            if let userId = authVM.userId {
                statsVM.refresh(userId: userId, habits: habitListVM.habits)
            }
        }
    }
    
    private var summarySection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Overview")
                .font(.headline)
            Text("Total habits: \(statsVM.summary.totalHabits)")
            Text("Active habits: \(statsVM.summary.activeHabits)")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var completionSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Last 7 days")
                .font(.headline)
            let rate = statsVM.summary.completionRateLast7Days
            Text(String(format: "Overall completion: %.0f%%", rate * 100))
            ProgressView(value: rate)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var bestHabitSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Most completed habit")
                .font(.headline)
            if let name = statsVM.summary.bestHabitName {
                Text(name)
                    .font(.title3.bold())
                Text("Total completions (7 days): \(statsVM.summary.totalCompletionsLast7Days)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                Text("No data yet.")
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    StatsView()
}
