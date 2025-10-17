import SwiftUI
import FamilyControls

struct ProfileModalView: View {
  let profiles: [BlockedProfiles]
  @Binding var selectedProfile: BlockedProfiles?
  let onEditProfile: (BlockedProfiles) -> Void
  let onCreateProfile: () -> Void
  
  @Environment(\.dismiss) private var dismiss
  
  var body: some View {
    NavigationView {
      VStack(spacing: 0) {
        // Header
        HStack {
          Button(action: {
            dismiss()
          }) {
            Image(systemName: "chevron.left")
              .font(.system(.title2, design: .monospaced))
              .foregroundColor(.primary)
          }
          
          Spacer()
          
          Text("SELECT PROFILE")
            .font(.system(.headline, design: .monospaced))
            .fontWeight(.bold)
            .foregroundColor(.primary)
          
          Spacer()
          
          Button(action: {
            onCreateProfile()
          }) {
            Image(systemName: "plus")
              .font(.system(.title2, design: .monospaced))
              .foregroundColor(.primary)
          }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        
        // Profile List
        if profiles.isEmpty {
          VStack(spacing: 16) {
            Spacer()
            
            Image(systemName: "person.crop.circle.badge.plus")
              .font(.system(.largeTitle, design: .monospaced))
              .foregroundColor(.gray)
            
            Text("No profiles yet")
              .font(.system(.headline, design: .monospaced))
              .foregroundColor(.secondary)
            
            Text("Create your first profile to get started")
              .font(.system(.subheadline, design: .monospaced))
              .foregroundColor(.secondary)
              .multilineTextAlignment(.center)
            
            Button(action: {
              onCreateProfile()
            }) {
              Text("CREATE PROFILE")
                .font(.system(.headline, design: .monospaced))
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(
                  RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray)
                )
            }
            
            Spacer()
          }
        } else {
          List {
            ForEach(profiles) { profile in
              HStack {
                VStack(alignment: .leading, spacing: 4) {
                  Text(profile.name)
                    .font(.system(.headline, design: .monospaced))
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                  
                  Text("\(FamilyActivityUtil.countSelectedActivities(profile.selectedActivity)) apps selected")
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if selectedProfile?.id == profile.id {
                  Image(systemName: "checkmark")
                    .font(.system(.title3, design: .monospaced))
                    .foregroundColor(.primary)
                }
                
                Button(action: {
                  onEditProfile(profile)
                }) {
                  Image(systemName: "pencil")
                    .font(.system(.title3, design: .monospaced))
                    .foregroundColor(.secondary)
                }
                .buttonStyle(PlainButtonStyle())
              }
              .padding(.vertical, 8)
              .contentShape(Rectangle())
              .onTapGesture {
                selectedProfile = profile
                dismiss()
              }
            }
          }
          .listStyle(PlainListStyle())
        }
      }
      .navigationBarHidden(true)
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
    onCreateProfile: {}
  )
}
