import Foundation
import Contacts
import Combine

class ContactsManager: ObservableObject {
  @Published var contacts: [Contact] = []
  @Published var allContacts: [Contact] = []
  @Published var isAuthorized = false
  @Published var selectedContactIds: Set<UUID> = []
  
  func requestAccess() {
    print("🔍 Requesting contacts access...")
    let store = CNContactStore()
    
    store.requestAccess(for: .contacts) { [weak self] granted, error in
      print("✅ Contacts access granted: \(granted)")
      if let error = error {
        print("❌ Contacts error: \(error)")
      }
      DispatchQueue.main.async {
        self?.isAuthorized = granted
        if granted {
          print("🎉 Fetching contacts...")
          self?.fetchContacts()
        }
      }
    }
  }
  
  func fetchContacts() {
    DispatchQueue.global(qos: .userInitiated).async {
      let store = CNContactStore()
      let keysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey] as [CNKeyDescriptor]
      let request = CNContactFetchRequest(keysToFetch: keysToFetch)
      
      var fetchedContacts: [Contact] = []
      
      do {
        try store.enumerateContacts(with: request) { contact, _ in
          let name = "\(contact.givenName) \(contact.familyName)".trimmingCharacters(in: .whitespaces)
          if !name.isEmpty {
            print("📇 Found contact: \(name)")
            let randomEmotion = ["happy-cry", "angry", "cold-face", "crying", "flushed", "gasp", "grimacing"].randomElement()!
            let randomColor = ["#FF6B6B", "#4ECDC4", "#95E1D3", "#F3A683", "#786FA6", "#45B7D1"].randomElement()!
            fetchedContacts.append(Contact(name: name, emotion: randomEmotion, profileColor: randomColor))
          }
        }
        
        print("✅ Total contacts fetched: \(fetchedContacts.count)")
        
        DispatchQueue.main.async {
          self.allContacts = fetchedContacts
          self.contacts = fetchedContacts.filter { self.selectedContactIds.contains($0.id) }
        }
      } catch {
        print("❌ Failed to fetch contacts: \(error)")
      }
    }
  }
  
  func toggleContact(_ contact: Contact) {
    if selectedContactIds.contains(contact.id) {
      selectedContactIds.remove(contact.id)
    } else {
      selectedContactIds.insert(contact.id)
    }
    updateDisplayedContacts()
  }
  
  func isFollowing(_ contact: Contact) -> Bool {
    return selectedContactIds.contains(contact.id)
  }
  
  private func updateDisplayedContacts() {
    contacts = allContacts.filter { selectedContactIds.contains($0.id) }
  }
}
