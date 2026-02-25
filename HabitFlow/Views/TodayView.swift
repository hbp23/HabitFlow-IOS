//
//  TodayView.swift
//  HabitFlow
//
//  Created by Harsh Patel.
//

import SwiftUI

struct TodayView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var habitListVM: HabitListViewModel
    @StateObject private var todayVM = TodayViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if let error = todayVM.errorMessage {
                    ErrorBanner(message: error)
                }
                Group {
                    if todayVM.isLoading {
                        ProgressView("Loading today...")
                    } else if todayVM.items.isEmpty {
                        VStack(spacing: 12) {
                            Text("No habits scheduled for today")
                                .font(.headline)
                            Text("Create or schedule habits in the Habits tab.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .multilineTextAlignment(.center)
                        .padding()
                    } else {
                        List {
                            ForEach(todayVM.items) { item in
                                TodayHabitRow(item: item) {
                                    todayVM.incrementCompletion(for: item)
                                }
                            }
                        }
                        .listStyle(.insetGrouped)
                    }
                }
            }
            .navigationTitle("Today")
        }
        .onAppear {
            if let userID = authVM.userId {
                todayVM.refresh(userId: userID, habits: habitListVM.habits)
            }
        }
        .refreshable {
            if let userID = authVM.userId {
                todayVM.refresh(userId: userID, habits: habitListVM.habits)
            }
        }
    }
}

struct TodayHabitRow: View {
    let item: TodayHabitItem
    let onIncrement: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Text(item.habit.emoji)
                .font(.largeTitle)
                .frame(width: 44, height: 44)
                .background(Color(hex: item.habit.colorHex) ?? .accentColor.opacity(0.2))
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: 4) {
                Text(item.habit.name)
                    .font(.headline)
                Text(item.progressText)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Button {
                onIncrement()
            } label: {
                Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "plus.circle")
                    .font(.title2)
            }
            .buttonStyle(.borderless)
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }
}

#Preview {
    TodayView()
        .environmentObject(
            AuthViewModel(authService: FirebaseAuthService())
        )
        .environmentObject(
            HabitListViewModel()
        )
}
