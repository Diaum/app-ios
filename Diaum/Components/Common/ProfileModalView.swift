import SwiftUI
import FamilyControls

struct ProfileModalView: View {
  let profiles: [BlockedProfiles]
  @Binding var selectedProfile: BlockedProfiles?
  let onEditProfile: (BlockedProfiles) -> Void
  let onCreateProfile: () -> Void
  let onDeleteProfile: (BlockedProfiles) -> Void
  
  @Environment(\.dismiss) private var dismiss
  @State private var profileToDelete: BlockedProfiles?
  @State private var showingDeleteAlert = false
  
  var body: some View {
    NavigationView {
      VStack(spacing: 0) {
        // Compact Header
        HStack {
          Button(action: { dismiss() }) {
            Image(systemName: "xmark")
              .font(.system(.title3, design: .monospaced))
              .foregroundColor(.primary)
          }
          
          Spacer()
          
          Text("SELECT PROFILE")
            .font(.system(.subheadline, design: .monospaced))
            .fontWeight(.bold)
            .foregroundColor(.primary)
          
          Spacer()
          
          Button(action: { onCreateProfile() }) {
            Image(systemName: "plus")
              .font(.system(.title3, design: .monospaced))
              .foregroundColor(.primary)
          }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        
        Divider()
        
        // Compact Profile List
        if profiles.isEmpty {
          VStack(spacing: 16) {
            Spacer()
            
            Image(systemName: "person.crop.circle.badge.plus")
              .font(.system(.title, design: .monospaced))
              .foregroundColor(.gray)
            
            Text("No profiles yet")
              .font(.system(.subheadline, design: .monospaced))
              .foregroundColor(.secondary)
            
            Button(action: { onCreateProfile() }) {
              Text("CREATE PROFILE")
                .font(.system(.subheadline, design: .monospaced))
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                  RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray)
                )
            }
            
            Spacer()
          }
          .padding(.horizontal, 20)
        } else {
          ScrollView {
            LazyVStack(spacing: 8) {
              ForEach(profiles) { profile in
                HStack {
                  VStack(alignment: .leading, spacing: 2) {
                    Text(profile.name)
                      .font(.system(.subheadline, design: .monospaced))
                      .fontWeight(.medium)
                      .foregroundColor(.primary)
                    
                    Text("\(FamilyActivityUtil.countSelectedActivities(profile.selectedActivity)) apps")
                      .font(.system(.caption2, design: .monospaced))
                      .foregroundColor(.secondary)
                  }
                  
                  Spacer()
                  
                  if selectedProfile?.id == profile.id {
                    Image(systemName: "checkmark.circle.fill")
                      .font(.system(.title3, design: .monospaced))
                      .foregroundColor(.blue)
                  }
                  
                  HStack(spacing: 8) {
                    Button(action: { onEditProfile(profile) }) {
                      Image(systemName: "pencil")
                        .font(.system(.caption, design: .monospaced))
                        .foregroundColor(.secondary)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: {
                      profileToDelete = profile
                      showingDeleteAlert = true
                    }) {
                      Image(systemName: "trash")
                        .font(.system(.caption, design: .monospaced))
                        .foregroundColor(.red)
                    }
                    .buttonStyle(PlainButtonStyle())
                  }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                  RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemGray6))
                )
                .contentShape(Rectangle())
                .onTapGesture {
                  selectedProfile = profile
                  dismiss()
                }
              }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
          }
        }
      }
      .navigationBarHidden(true)
    }
    .presentationDetents([.height(400)])
    .alert("Delete Profile", isPresented: $showingDeleteAlert) {
      Button("Cancel", role: .cancel) { }
      Button("Delete", role: .destructive) {
        if let profile = profileToDelete {
          onDeleteProfile(profile)
        }
      }
    } message: {
      Text("Are you sure you want to delete '\(profileToDelete?.name ?? "")'? This action cannot be undone.")
    }
  }
}

#Preview {
  ProfileModalView(
    profiles: [
      BlockedProfiles(name: "Work Focus"),
      BlockedProfiles(name: "Study Mode")
    ],
    selectedProfile: .constant(nil),
    onEditProfile: { _ in },
    onCreateProfile: {},
    onDeleteProfile: { _ in }
  )
}