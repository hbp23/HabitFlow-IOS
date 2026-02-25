//
//  HabitListViewModel.swift
//  HabitFlow
//
//  Created by Harsh Patel.
//

import Foundation
import FirebaseFirestore
import Combine

final class HabitListViewModel: ObservableObject {
    
    @Published var habits: [Habit] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let repository: HabitRepository
    private var habitsListener: ListenerRegistration?
    
    private(set) var userID: String?
    
    init(repository: HabitRepository = HabitRepository()) {
        self.repository = repository
    }
    
    func startListening(userID: String) {
        
        if self.userID == userID, habitsListener != nil {
            return
        }
        
        stopListening()
        
        self.userID = userID
        isLoading = true
        errorMessage = nil
        
        habitsListener = repository.observeHabits(userId: userID) { [weak self] result in
            guard let self = self else { return }
            
            Task { @MainActor in
                self.isLoading = false
                switch result {
                case .success(let habits):
                    self.habits = habits
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func stopListening() {
        habitsListener?.remove()
        habitsListener = nil
        userID = nil
        habits = []
    }
    
    func addHabit(_ habit: Habit) {
        isLoading = true
        errorMessage = nil
        
        repository.addHabit(habit) { [weak self] result in
            guard let self = self else { return }
            Task { @MainActor in
                self.isLoading = false
                if case .failure(let error) = result {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func updateHabit(_ habit: Habit) {
        isLoading = true
        errorMessage = nil
            
        repository.updateHabit(habit) { [weak self] result in
            guard let self = self else { return }
            Task { @MainActor in
                self.isLoading = false
                if case .failure(let error) = result {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func archiveHabit(_ habit: Habit) {
        setArchived(habit, isArchived: true)
    }
        
    func unarchiveHabit(_ habit: Habit) {
        setArchived(habit, isArchived: false)
    }
        
    private func setArchived(_ habit: Habit, isArchived: Bool) {
        isLoading = true
        errorMessage = nil
            
        repository.setArchived(habit, isArchived: isArchived) { [weak self] result in
            guard let self = self else { return }
            Task { @MainActor in
                self.isLoading = false
                if case .failure(let error) = result {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func deleteHabit(_ habit: Habit) {
        isLoading = true
        errorMessage = nil
            
        repository.deleteHabit(habit) { [weak self] result in
            guard let self = self else { return }
            Task { @MainActor in
                self.isLoading = false
                if case .failure(let error) = result {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    
    
}
