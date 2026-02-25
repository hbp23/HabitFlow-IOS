//
//  FirebaseAuthService.swift
//  HabitFlow
//
//  Created by Harsh Patel.
//

import Foundation
import FirebaseAuth
import Combine

@MainActor
final class FirebaseAuthService: ObservableObject {
    @Published var user: User? = Auth.auth().currentUser
    private var authHandle: AuthStateDidChangeListenerHandle?
    
    
    init() {
        authHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.user = user
        }
    }
    
    deinit {
        if let handle = authHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    var userId: String? {
        user?.uid
    }
    
    func signUp(email: String, password: String) async throws {
        try await Auth.auth().createUser(withEmail: email, password: password)
    }
    
    func signIn(email: String, password: String) async throws {
        try await Auth.auth().signIn(withEmail: email, password: password)
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("Sign out error: \(error.localizedDescription)")
        }
    }
    
    
}
