//
//  AuthViewModel.swift
//  HabitFlow
//
//  Created by Harsh Patel.
//

import Foundation
import Combine
import FirebaseAuth

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    
    @Published private(set) var userId: String?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let authService: FirebaseAuthService
    private var cancellables = Set<AnyCancellable>()
    
    init(authService: FirebaseAuthService) {
        self.authService = authService
            
        authService.$user
            .map { $0?.uid }
            .receive(on: RunLoop.main)
            .assign(to: \.userId, on: self)
            .store(in: &cancellables)
    }
    
    var isSignedIn: Bool {
        userId != nil
    }
    
    
    
    func signIn() {
        errorMessage = nil
        
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter both email and password."
            return
        }
        
        isLoading = true
        
        Task {
            do {
                try await authService.signIn(email: email, password: password)
                isLoading = false
            } catch {
                isLoading = false
                errorMessage = error.localizedDescription
            }
        }
    }
    
    func signUp() {
        errorMessage = nil
        
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter both email and password."
            return
        }
        
        isLoading = true
        
        Task {
            do {
                try await authService.signUp(email: email, password: password)
                isLoading = false
            } catch {
                isLoading = false
                errorMessage = error.localizedDescription
            }
        }
    }
    
    func signOut() {
        authService.signOut()
    }
    
    func clearError() {
        errorMessage = nil
    }
    
}
