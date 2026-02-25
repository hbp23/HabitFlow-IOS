//
//  SettingsView.swift
//  HabitFlow
//
//  Created by Harsh Patel.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authVM: AuthViewModel
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Account") {
                    if let email = authVM.email.isEmpty ? nil : authVM.email {
                        HStack {
                            Text("Signed in as")
                            Spacer()
                            Text(email)
                                .foregroundColor(.secondary)
                        }
                    }
                    Button(role: .destructive) {
                        authVM.signOut()
                    } label: {
                        Text("Sign Out")
                    }
                 }
                Section("About") {
                    Text("HabitFlow")
                    Text("Created By Harsh Patel")
                    Text("Version 1.0")
                        .foregroundColor(.secondary)
                        .font(.footnote)
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}
