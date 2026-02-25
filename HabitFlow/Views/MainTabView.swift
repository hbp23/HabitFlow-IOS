//
//  MainTabView.swift
//  HabitFlow
//
//  Created by Harsh Patel.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var habitListVM = HabitListViewModel()
    
    var body: some View {
        TabView {
            NavigationStack {
                TodayView()
            }
            .tabItem {
                Label("Today", systemImage: "checkmark.circle")
            }
            
            NavigationStack {
                HabitsView()
            }
            .tabItem {
                Label("Habits", systemImage: "list.bullet")
            }
            
            NavigationStack {
                StatsView()
            }
            .tabItem {
                Label("Stats", systemImage: "chart.bar")
            }
            
            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape")
            }
        }
        .environmentObject(habitListVM)
        .onAppear {
            if let userId = authVM.userId {
                habitListVM.startListening(userID: userId)
            }
        }
        .onDisappear {
            habitListVM.stopListening()
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(
            AuthViewModel(authService: FirebaseAuthService())
        )
}
