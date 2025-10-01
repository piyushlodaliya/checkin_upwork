import SwiftUI
import Auth

struct AuthHomeView: View {
    @EnvironmentObject var supabaseManager: SupabaseManager
    
    var body: some View {
        VStack(spacing: 24) {
            // Welcome Header
            VStack(spacing: 8) {
                Text("Welcome to cheakin!")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.primary)
                
                if let user = supabaseManager.currentUser {
                    Text("Hello, \(user.email ?? "User")")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.top, 40)
            
            // App Content Placeholder
            VStack(spacing: 16) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                Text("You're successfully authenticated!")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.primary)
                
                Text("This is where your main app content will go.")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 32)
            
            Spacer()
            
            // Sign Out Button
            Button(action: {
                Task {
                    await supabaseManager.signOut()
                }
            }) {
                Text("Sign Out")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(12)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 40)
        }
    }
}

#Preview {
    AuthHomeView()
        .environmentObject(SupabaseManager.shared)
}
