//
//  ContentView.swift
//  HabitFlow
//
//  Created by Harsh Patel on 12/7/25.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    @StateObject private var authVM: AuthViewModel
    
    init() {
        let authService = FirebaseAuthService()
        _authVM = StateObject(wrappedValue: AuthViewModel(authService: authService))
    }
    var body: some View {
        Group {
            if !hasSeenOnboarding {
                FirstPageView()
            } else if authVM.isSignedIn {
                MainTabView()
                    .environmentObject(authVM)
            } else {
                AuthView()
                    .environmentObject(authVM)
            }
        }
    }
}

#Preview {
    ContentView()
}
