//
//  AddEditHabitView.swift
//  HabitFlow
//
//  Created by Harsh Patel.
//

import SwiftUI

struct AddEditHabitView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var habitListVM: HabitListViewModel
    let habitToEdit: Habit?
    @State private var name: String = ""
    @State private var descriptionText: String = ""
    @State private var emoji: String = "🔥"
    @State private var color: Color = .accentColor
    @State private var frequency: HabitFrequency = .everyDay
    @State private var selectedDays: Set<Int> = [] // 1...7
    @State private var targetPerDay: Int = 1
    @State private var isArchived: Bool = false
    
    var isEditing: Bool {
        habitToEdit != nil
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Basic Info") {
                    TextField("Name", text: $name)
                    TextField("Description (optional)", text: $descriptionText)
                    TextField("Emoji", text: $emoji)
                        .textInputAutocapitalization(.never)
                        .frame(maxWidth: 80)
                    
                    ColorPicker("Color", selection: $color, supportsOpacity: false)
                }
                
                Section("Schedule") {
                    Picker("Frequency", selection: $frequency) {
                        Text("Every Day").tag(HabitFrequency.everyDay)
                        Text("Specific Days").tag(HabitFrequency.specificDays)
                    }
                    .pickerStyle(.segmented)
                    
                    if frequency == .specificDays {
                        DaysOfWeekSelector(selectedDays: $selectedDays)
                    }
                }
                
                Section("Daily Target") {
                    Stepper("Times per day: \(targetPerDay)", value: $targetPerDay, in: 1...10)
                }
                
                if isEditing {
                    Section {
                        Toggle("Archived", isOn: $isArchived)
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Habit" : "New Habit")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveHabit()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear {
                if let habit = habitToEdit {
                    loadFromHabit(habit)
                }
            }
        }
    }
    
    private func loadFromHabit(_ habit: Habit) {
        name = habit.name
        descriptionText = habit.description ?? ""
        emoji = habit.emoji
        color = Color(hex: habit.colorHex) ?? .accentColor
        frequency = habit.frequency
        selectedDays = Set(habit.daysOfWeek)
        targetPerDay = habit.targetPerDay
        isArchived = habit.isArchived
    }
    
    private func saveHabit() {
        guard let userId = authVM.userId else { return }
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        let colorHex = color.toHexString() ?? "#3B82F6"
        if var habit = habitToEdit {
            habit.name = trimmedName
              habit.description = descriptionText.isEmpty ? nil : descriptionText
              habit.emoji = emoji.isEmpty ? "🔥" : emoji
              habit.colorHex = colorHex
              habit.frequency = frequency
              habit.daysOfWeek = Array(selectedDays).sorted()
              habit.targetPerDay = targetPerDay
              habit.isArchived = isArchived
              habit.updatedAt = Date()
              habitListVM.updateHabit(habit)
        } else {
            let newHabit = Habit.new(
                userID: userId,
                name: trimmedName,
                description: descriptionText.isEmpty ? nil : descriptionText,
                emoji: emoji.isEmpty ? "🔥" : emoji,
                colorHex: colorHex,
                frequency: frequency,
                daysOfWeek: Array(selectedDays).sorted(),
                targetPerDay: targetPerDay,
                sortOrder: habitListVM.habits.count
            )
            habitListVM.addHabit(newHabit)
        }
        dismiss()
    }
}

struct DaysOfWeekSelector: View {
    @Binding var selectedDays: Set<Int>
    private let symbols = Calendar.current.veryShortWeekdaySymbols
    
    var body: some View {
        HStack {
            ForEach(1...7, id: \.self) { index in
                let isSelected = selectedDays.contains(index)
                Button {
                    if isSelected {
                        selectedDays.remove(index)
                    } else {
                        selectedDays.insert(index)
                    }
                } label: {
                    Text(symbols[index - 1])
                        .frame(maxWidth: .infinity)
                        .padding(8)
                        .background(isSelected ? Color.accentColor : Color(.systemGray5))
                        .foregroundColor(isSelected ? .white : .primary)
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

#Preview {
    AddEditHabitView(habitToEdit: nil)
        .environmentObject(
            AuthViewModel(authService: FirebaseAuthService())
        )
        .environmentObject(
            HabitListViewModel()
        )
}

