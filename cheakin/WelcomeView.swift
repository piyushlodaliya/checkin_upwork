import SwiftUI

struct WelcomeView: View {
    @State private var showingSignUp = false
    @State private var showingLogin = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                Spacer()
                
                // App Logo/Title
                VStack(spacing: 16) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                    
                    Text("cheakin")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("Your personal wellness companion")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 16) {
                    Button(action: {
                        showingSignUp = true
                    }) {
                        Text("Sign Up")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    
                    Button(action: {
                        showingLogin = true
                    }) {
                        Text("Login")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 32)
                
                Spacer()
            }
            .navigationDestination(isPresented: $showingSignUp) {
                SignUpView()
            }
            .navigationDestination(isPresented: $showingLogin) {
                LoginView()
            }
        }
    }
}

#Preview {
    WelcomeView()
}
