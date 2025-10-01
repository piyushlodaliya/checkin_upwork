import Foundation
import Supabase
import Combine

class SupabaseManager: ObservableObject {
    static let shared = SupabaseManager()
    
    let client: SupabaseClient
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private init() {
        client = SupabaseClient(
            supabaseURL: URL(string: "https://pqjcprsjyznopekrrzgp.supabase.co")!,
            supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBxamNwcnNqeXpub3Bla3JyemdwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTkyOTAxMjQsImV4cCI6MjA3NDg2NjEyNH0.DEaIXeqz81PRqHuo_UAIdxUwkQfXj-oE5c-OGagM094"
        )
        
        // Check if user is already authenticated
        checkAuthStatus()
    }
    
    func checkAuthStatus() {
        Task {
            do {
                let session = try await client.auth.session
                await MainActor.run {
                    self.currentUser = session.user
                    self.isAuthenticated = true
                }
            } catch {
                await MainActor.run {
                    self.isAuthenticated = false
                    self.currentUser = nil
                }
            }
        }
    }
    
    func signUp(email: String, password: String) async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            let response = try await client.auth.signUp(
                email: email,
                password: password
            )
            
            await MainActor.run {
                self.isLoading = false
                self.currentUser = response.user
                self.isAuthenticated = true
            }
        } catch {
            await MainActor.run {
                self.isLoading = false
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    func signIn(email: String, password: String) async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            let response = try await client.auth.signIn(
                email: email,
                password: password
            )
            
            await MainActor.run {
                self.isLoading = false
                self.currentUser = response.user
                self.isAuthenticated = true
            }
        } catch {
            await MainActor.run {
                self.isLoading = false
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    func signInWithGoogle() async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            _ = try await client.auth.signInWithOAuth(
                provider: .google,
                redirectTo: URL(string: "cheakin://auth-callback")
            )
            
            // Note: OAuth flow will be handled by the system
            await MainActor.run {
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.isLoading = false
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    func signOut() async {
        do {
            try await client.auth.signOut()
            await MainActor.run {
                self.isAuthenticated = false
                self.currentUser = nil
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
            }
        }
    }
}
