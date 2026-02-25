//
//  HabitRepository.swift
//  HabitFlow
//
//  Created by Harsh Patel.
//

import Foundation
import FirebaseFirestore

final class HabitRepository {
    
    private let db = Firestore.firestore()
    
    private func habitsCollection(for userId: String) -> CollectionReference {
        db.collection("users")
            .document(userId)
            .collection("habits")
    }
    
    private func logsCollection(for userId: String) -> CollectionReference {
        db.collection("users")
            .document(userId)
            .collection("logs")
    }
    
    func observeHabits(
        userId: String,
        onChange: @escaping (Result<[Habit], Error>) -> Void ) -> ListenerRegistration {
            
            let query = habitsCollection(for: userId)
                .order(by: "sortOrder", descending: false)
            
            let listener = query.addSnapshotListener { snapshot, error in
                if let error = error {
                    onChange(.failure(error))
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    onChange(.success([]))
                    return
                }
                
                let habits: [Habit] = documents.compactMap { doc in
                    do {
                        return try doc.data(as: Habit.self)
                    } catch {
                        print("Failed to decode Habit: \(error)")
                        return nil
                    }
                }
                onChange(.success(habits))
            }
            return listener
        }
    
    func addHabit(
        _ habit: Habit,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard !habit.userID.isEmpty else {
            completion(.failure(NSError(domain: "HabitRepository", code: 0, userInfo: [NSLocalizedDescriptionKey: "Missing userId on Habit"])))
            return
        }
        
        do {
            _ = try habitsCollection(for: habit.userID)
                .addDocument(from: habit) { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(()))
                    }
                }
        } catch {
            completion(.failure(error))
        }
    }
    
    func updateHabit(
        _ habit: Habit,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard let id = habit.id, !habit.userID.isEmpty else {
            completion(.failure(NSError(domain: "HabitRepository", code: 0, userInfo: [NSLocalizedDescriptionKey: "Missing id or userID on Habit"])))
            return
        }
        
        var updatedHabit = habit
        updatedHabit.updatedAt = Date()
        
        do {
            try habitsCollection(for: habit.userID)
                .document(id)
                .setData(from: updatedHabit, merge: true) { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        
                    }
                }
        } catch {
            completion(.failure(error))
        }
    }
    
    func deleteHabit(
        _ habit: Habit,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard let id = habit.id, !habit.userID.isEmpty else {
            completion(.failure(NSError(domain: "HabitRepository", code: 0, userInfo: [NSLocalizedDescriptionKey: "Missing id or userId on Habit"])))
            return
        }
        
        habitsCollection(for: habit.userID)
            .document(id)
            .delete() { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
    }
    
    func setArchived(
        _ habit: Habit,
        isArchived: Bool,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        var updatedHabit = habit
        updatedHabit.isArchived = isArchived
        updatedHabit.updatedAt = Date()
        updateHabit(updatedHabit, completion: completion)
    }
    
    func upsertLog(
            _ log: HabitLog,
            completion: @escaping (Result<Void, Error>) -> Void
        ) {
            guard !log.userId.isEmpty else {
                completion(.failure(NSError(domain: "HabitRepository", code: 0, userInfo: [NSLocalizedDescriptionKey: "Missing userId on HabitLog"])))
                return
            }
            
            let docId = log.id ?? "\(log.habitId)_\(log.dateString)"
            
            do {
                try logsCollection(for: log.userId)
                    .document(docId)
                    .setData(from: log, merge: true) { error in
                        if let error = error {
                            completion(.failure(error))
                        } else {
                            completion(.success(()))
                        }
                    }
            } catch {
                completion(.failure(error))
            }
        }
    
    func fetchLogsForHabit(
        userId: String,
        habitId: String,
        lastNDays days: Int,
        completion: @escaping (Result<[HabitLog], Error>) -> Void
    ) {
        let calendar = Calendar.current
        let startDate = calendar.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        let startString = startDate.toHabitDateString(calendar: calendar)

        // Simpler query: only filter by habitId; order by dateString
        let query = logsCollection(for: userId)
            .whereField("habitId", isEqualTo: habitId)
            .whereField("dateString", isGreaterThanOrEqualTo: startString)
            .order(by: "dateString", descending: false)

        query.getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            let allLogs: [HabitLog] = snapshot?.documents.compactMap { doc in
                do {
                    return try doc.data(as: HabitLog.self)
                } catch {
                    print("Failed to decode HabitLog: \(error)")
                    return nil
                }
            } ?? []

            // Filter in memory for last N days
            let filtered = allLogs.filter { $0.dateString >= startString }

            completion(.success(filtered))
        }
    }
    
    func fetchLogsForLastNDays(
            userId: String,
            days: Int,
            completion: @escaping (Result<[HabitLog], Error>) -> Void
        ) {
            let calendar = Calendar.current
            let startDate = calendar.date(byAdding: .day, value: -days, to: Date()) ?? Date()
            let startString = startDate.toHabitDateString(calendar: calendar)
            
            let query = logsCollection(for: userId)
                .whereField("dateString", isGreaterThanOrEqualTo: startString)
                .order(by: "dateString", descending: false)
            
            query.getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                let logs: [HabitLog] = snapshot?.documents.compactMap { doc in
                    do {
                        return try doc.data(as: HabitLog.self)
                    } catch {
                        print("Failed to decode HabitLog: \(error)")
                        return nil
                    }
                } ?? []
                
                completion(.success(logs))
            }
        }
    
    
    
}
