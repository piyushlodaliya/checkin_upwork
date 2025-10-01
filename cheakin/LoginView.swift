import SwiftUI

struct LoginView: View {
    @EnvironmentObject var supabaseManager: SupabaseManager
    @Environment(\.dismiss) var dismiss
    
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 8) {
                Text("Welcome Back")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.primary)
                
                Text("Sign in to continue your wellness journey")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 40)
            
            // Form Fields
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Email")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)
                    
                    TextField("Enter your email", text: $email)
                        .textFieldStyle(CustomTextFieldStyle())
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Password")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)
                    
                    SecureField("Enter your password", text: $password)
                        .textFieldStyle(CustomTextFieldStyle())
                }
            }
            .padding(.horizontal, 32)
            
            // Error Message
            if let errorMessage = supabaseManager.errorMessage {
                Text(errorMessage)
                    .font(.system(size: 14))
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            Spacer()
            
            // Action Buttons
            VStack(spacing: 16) {
                Button(action: {
                    Task {
                        await signIn()
                    }
                }) {
                    HStack {
                        if supabaseManager.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        }
                        Text(supabaseManager.isLoading ? "Signing In..." : "Sign In")
                            .font(.system(size: 18, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.blue)
                    .cornerRadius(12)
                }
                .disabled(supabaseManager.isLoading || !isFormValid)
                .opacity(isFormValid ? 1.0 : 0.6)
                
                // Divider
                HStack {
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.gray.opacity(0.3))
                    Text("or")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 16)
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.gray.opacity(0.3))
                }
                .padding(.horizontal, 32)
                
                Button(action: {
                    Task {
                        await supabaseManager.signInWithGoogle()
                    }
                }) {
                    HStack {
                        Image(systemName: "globe")
                            .font(.system(size: 18))
                        Text("Continue with Google")
                            .font(.system(size: 18, weight: .medium))
                    }
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                .disabled(supabaseManager.isLoading)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 40)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Back") {
                    dismiss()
                }
            }
        }
    }
    
    private var isFormValid: Bool {
        !email.isEmpty && !password.isEmpty && email.contains("@")
    }
    
    private func signIn() async {
        guard isFormValid else { return }
        
        await supabaseManager.signIn(email: email, password: password)
    }
}

#Preview {
    NavigationStack {
        LoginView()
            .environmentObject(SupabaseManager.shared)
    }
}
