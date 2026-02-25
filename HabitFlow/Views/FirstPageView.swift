//
//  FirstPageView.swift
//  HabitFlow
//
//  Created by Harsh Patel.
//

import SwiftUI

struct FirstPageView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    
    var body: some View {
        TabView {
            onboardingPage(
                title: "Welcome to HabitFlow",
                subtitle: "Track your daily habits and build streaks.",
                systemImage: "checkmark.circle"
            )
            
            onboardingPage(
                title: "Stay Consistent",
                subtitle: "See your progress over time and keep your streak alive.",
                systemImage: "flame.fill"
            )
            
            lastPage
        }
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .always))
    }
    
    private func onboardingPage(title: String, subtitle: String, systemImage: String) -> some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: systemImage)
                .font(.system(size: 72))
            Text(title)
                .font(.title)
                .bold()
            Text(subtitle)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            Spacer()
        }
    }
    
    private var lastPage: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "hand.thumbsup.fill")
                .font(.system(size: 72))
            Text("Get Started")
                .font(.title)
                .bold()
            Text("Create your first habit and start tracking today.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            Button {
                hasSeenOnboarding = true
            } label: {
                Text("Continue")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .padding(.horizontal)
            }
            Spacer()
        }
    }
}

#Preview {
    FirstPageView()
}
