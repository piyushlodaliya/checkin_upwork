import SwiftUI
import Lottie

struct ContactsView: View {
    @State private var selectedTab = 0
    @State private var showingDiscover = false
    @EnvironmentObject var contactsManager: ContactsManager
    @EnvironmentObject var healthManager: HealthKitManager

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack {
                    NavigationLink {
                        DiscoverContactsView()
                            .environmentObject(contactsManager)
                    } label: {
                        Image(systemName: "person.badge.plus")
                            .font(.system(size: 20))
                            .foregroundColor(.blue)
                            .padding(8)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 12) {
                        TabButton(title: "Followers", isSelected: selectedTab == 0) {
                            selectedTab = 0
                        }
                        TabButton(title: "Following", isSelected: selectedTab == 1) {
                            selectedTab = 1
                        }
                    }
                    
                    Spacer()
                    
                    Color.clear.frame(width: 36)
                }
                .padding(.horizontal)
                .padding(.top, 16)
                .padding(.bottom, 12)

                ScrollView {
                    VStack(spacing: 8) {
                        if contactsManager.contacts.isEmpty {
                            Text("No contacts yet\nTap + to discover people")
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.top, 40)
                        } else {
                            ForEach(contactsManager.contacts) { contact in
                                NavigationLink {
                                    ContactDetailView(contact: contact)
                                        .environmentObject(healthManager)
                                } label: {
                                    ContactRow(contact: contact)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    Spacer(minLength: 100)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct DiscoverContactsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var contactsManager: ContactsManager
    @State private var searchText = ""
    
    var filteredContacts: [Contact] {
        if searchText.isEmpty {
            return contactsManager.allContacts
        }
        return contactsManager.allContacts.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Search contacts", text: $searchText)
                    .textFieldStyle(.plain)
            }
            .padding(10)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, 12)
            
            ScrollView {
                VStack(spacing: 8) {
                    if filteredContacts.isEmpty {
                        Text("No contacts found")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                            .padding(.top, 40)
                    } else {
                        ForEach(filteredContacts) { contact in
                            ContactRowWithButton(contact: contact)
                        }
                    }
                }
                .padding(.horizontal)
                Spacer(minLength: 100)
            }
        }
        .navigationTitle("Discover")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: isSelected ? .semibold : .regular))
                .foregroundColor(isSelected ? .primary : .gray)
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? Color(.systemGray6) : Color.clear)
                )
        }
    }
}

struct ContactRow: View {
    let contact: Contact

    var body: some View {
        HStack(spacing: 16) {
            LottieView(animation: .named(contact.emotion))
                .playing(loopMode: .loop)
                .frame(width: 50, height: 50)

            Text(contact.name)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.primary)

            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
        )
    }
}

struct ContactRowWithButton: View {
    let contact: Contact
    @EnvironmentObject var contactsManager: ContactsManager
    
    var body: some View {
        HStack(spacing: 16) {
            LottieView(animation: .named(contact.emotion))
                .playing(loopMode: .loop)
                .frame(width: 50, height: 50)

            Text(contact.name)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.primary)

            Spacer()
            
            Button(action: {
                contactsManager.toggleContact(contact)
            }) {
                Text(contactsManager.isFollowing(contact) ? "Following" : "Follow")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(contactsManager.isFollowing(contact) ? .gray : .white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(contactsManager.isFollowing(contact) ? Color(.systemGray5) : Color.blue)
                    )
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
        )
    }
}

struct Contact: Identifiable {
    let id = UUID()
    let name: String
    let emotion: String
    let profileColor: String
}

#Preview {
    ContactsView()
        .environmentObject(ContactsManager())
        .environmentObject(HealthKitManager())
}
