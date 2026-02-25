//
//  HabitsView.swift
//  HabitFlow
//
//  Created by Harsh Patel.
//

import SwiftUI

enum HabitsFilter: String, CaseIterable {
    case active = "Active"
    case archived = "Archived"
}

struct HabitsView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var habitListVM: HabitListViewModel
    @State private var filter: HabitsFilter = .active
    @State private var showingAddEdit = false
    @State private var habitToEdit: Habit?
    
    var filteredHabits: [Habit] {
        habitListVM.habits.filter { habit in
            switch filter {
            case .active: return !habit.isArchived
            case .archived: return habit.isArchived
        }
        }
        .sorted(by: { $0.sortOrder < $1.sortOrder })
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if let error = habitListVM.errorMessage {
                    ErrorBanner(message: error)
                }
                Group {
                    if habitListVM.isLoading && habitListVM.habits.isEmpty {
                        ProgressView("Loading Habits...")
                    } else if filteredHabits.isEmpty {
                        VStack(spacing: 12) {
                            Text("No \(filter == .active ? "active" : "archived") habits")
                                .font(.headline)
                            if filter == .active {
                                Text("Tap the + button to create your first habit!")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .multilineTextAlignment(.center)
                        .padding()
                    } else {
                        List {
                            ForEach(filteredHabits) { habit in
                                NavigationLink {
                                    if let userId = authVM.userId {
                                        HabitDetailView(
                                            habit: habit,
                                            userId: userId
                                        )
                                    }
                                } label: {
                                    HabitRow(habit: habit)
                                }
                                .swipeActions(edge: .trailing) {
                                    if habit.isArchived {
                                        Button("Unarchive") {
                                            habitListVM.unarchiveHabit(habit)
                                        }
                                    } else {
                                        Button("Archive") {
                                            habitListVM.archiveHabit(habit)
                                        }
                                        .tint(.orange)
                                    }
                                    Button(role: .destructive) {
                                        habitListVM.deleteHabit(habit)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                                .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                    Button {
                                        habitToEdit = habit
                                        showingAddEdit = true
                                    } label: {
                                        Label("Edit", systemImage: "pencil")
                                    }
                                }
                            }
                        }
                        .listStyle(.insetGrouped)
                    }
                }
            }
            .navigationTitle("Habits")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Picker("Filter", selection: $filter) {
                        ForEach(HabitsFilter.allCases, id: \.self) { filter in
                            Text(filter.rawValue).tag(filter)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 200)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        habitToEdit = nil
                        showingAddEdit = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddEdit) {
                AddEditHabitView(habitToEdit: habitToEdit)
            }
        }
    }
}

struct HabitRow: View {
    let habit: Habit
    
    var body: some View {
        HStack(spacing: 12) {
            Text(habit.emoji)
                .font(.largeTitle)
                .frame(width: 40, height: 40)
                .background(Color(hex: habit.colorHex) ?? .accentColor.opacity(0.2))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(habit.name)
                    .font(.headline)
                Text(habit.scheduleDescription)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    HabitsView()
        .environmentObject(
            AuthViewModel(authService: FirebaseAuthService())
        )
        .environmentObject(
            HabitListViewModel()
        )
}
