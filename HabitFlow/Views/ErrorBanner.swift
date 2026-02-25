//
//  ErrorBanner.swift
//  HabitFlow
//
//  Created by Harsh Patel.
//

import SwiftUI

struct ErrorBanner: View {
    let message: String
    
    var body: some View {
        Text(message)
            .font(.footnote)
            .foregroundColor(.white)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.red)
            
    }
}

#Preview {
    ErrorBanner(message: "Error")
}
