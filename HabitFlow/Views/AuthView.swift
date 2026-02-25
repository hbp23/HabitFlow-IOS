//
//  AuthView.swift
//  HabitFlow
//
//  Created by Harsh Patel.
//

import SwiftUI

struct AuthView: View {
    @EnvironmentObject var authVM: AuthViewModel
    
    
    var body: some View {
        VStack(spacing: 24) {
            Text("HabitFlow")
                .font(.largeTitle.bold())
            VStack(spacing: 16) {
                TextField("Email", text: $authVM.email)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .padding()
                    .background(.thinMaterial)
                    .cornerRadius(8)
                
                SecureField("Password", text: $authVM.password)
                    .padding()
                    .background(.thinMaterial)
                    .cornerRadius(8)
                
            }
            
            if let error = authVM.errorMessage {
                Text(error)
                    .foregroundStyle(.red)
                    .font(.footnote)
            }
            
            if authVM.isLoading {
                ProgressView()
            } else {
                VStack(spacing: 12) {
                    Button("Sign In") {
                        authVM.signIn()
                    }
                    .buttonStyle(.borderedProminent)
                    .frame(maxWidth: .infinity)
                    
                    Button("Create Account") {
                        authVM.signUp()
                    }
                    .buttonStyle(.bordered)
                    .frame(maxWidth: .infinity)
                }
            }
            Spacer()
        }
        .padding()
    }
}

#Preview {
    AuthView()
        .environmentObject(AuthViewModel(authService: FirebaseAuthService()))
}
