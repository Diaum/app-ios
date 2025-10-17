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
  @State private var isAllowingMode = false
  
  var body: some View {
    NavigationStack {
      VStack(spacing: 0) {
        // Header with BRICK MODES title
        VStack(spacing: 20) {
          HStack {
            Text("BRICK MODES")
              .font(.system(size: 24, weight: .bold, design: .monospaced))
              .foregroundColor(.black)
            
            Spacer()
            
            Button(action: { dismiss() }) {
              Text("Edit")
                .font(.system(size: 16, weight: .regular, design: .monospaced))
                .foregroundColor(.black)
            }
            .accessibilityLabel("Close")
          }
          .padding(.horizontal, 20)
          .padding(.top, 20)
          
          // Toggle for ALLOWING CHOSEN APPS
          Button(action: {
            isAllowingMode.toggle()
          }) {
            HStack {
              Text("ALLOWING CHOSEN APPS")
                .font(.system(size: 14, weight: .regular, design: .monospaced))
                .foregroundColor(.gray)
              Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
              RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray6))
            )
          }
          .buttonStyle(.plain)
          .padding(.horizontal, 20)
        }
        
        // Content
        ScrollView {
          VStack(spacing: 24) {
            // CHOOSE FROM YOUR MODES section
            VStack(alignment: .leading, spacing: 16) {
              Text("CHOOSE FROM YOUR MODES")
                .font(.system(size: 16, weight: .regular, design: .monospaced))
                .foregroundColor(.black)
                .padding(.horizontal, 20)
              
              if profiles.isEmpty {
                emptyStateView
              } else {
                modesListView
              }
            }
            
            Spacer(minLength: 40)
            
            // Action Buttons
            VStack(spacing: 12) {
              Button(action: {
                if let selectedProfile = selectedProfile {
                  onEditProfile(selectedProfile)
                }
              }) {
                Text("CUSTOMIZE DEFAULT APPS")
                  .font(.system(size: 16, weight: .regular, design: .monospaced))
                  .foregroundColor(.black)
                  .frame(maxWidth: .infinity)
                  .padding(.vertical, 14)
                  .background(
                    RoundedRectangle(cornerRadius: 8)
                      .fill(Color(.systemGray6))
                  )
              }
              .buttonStyle(.plain)
              .disabled(selectedProfile == nil)
              
              Button(action: { onCreateProfile() }) {
                Text("ADD MODE")
                  .font(.system(size: 16, weight: .regular, design: .monospaced))
                  .foregroundColor(.black)
                  .frame(maxWidth: .infinity)
                  .padding(.vertical, 14)
                  .background(
                    RoundedRectangle(cornerRadius: 8)
                      .fill(Color(.systemGray6))
                  )
              }
              .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
          }
        }
      }
      .background(Color.white)
    }
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
  
  // MARK: - Empty State View
  private var emptyStateView: some View {
    VStack(spacing: 20) {
      Text("No modes created yet")
        .font(.system(size: 16, weight: .regular, design: .monospaced))
        .foregroundColor(.gray)
        .padding(.horizontal, 20)
    }
  }
  
  // MARK: - Modes List View
  private var modesListView: some View {
    VStack(spacing: 0) {
      ForEach(profiles) { profile in
        ModeRowView(
          profile: profile,
          isSelected: selectedProfile?.id == profile.id,
          onSelect: {
            selectedProfile = profile
          },
          onDelete: {
            profileToDelete = profile
            showingDeleteAlert = true
          }
        )
        
        if profile.id != profiles.last?.id {
          Divider()
            .background(Color(.systemGray5))
            .padding(.horizontal, 20)
        }
      }
    }
    .background(Color.white)
    .overlay(
      RoundedRectangle(cornerRadius: 0)
        .stroke(Color(.systemGray5), lineWidth: 0.5)
    )
    .padding(.horizontal, 20)
  }
}

// MARK: - Mode Row View
struct ModeRowView: View {
  let profile: BlockedProfiles
  let isSelected: Bool
  let onSelect: () -> Void
  let onDelete: () -> Void
  
  var body: some View {
    HStack {
      Text(profile.name.uppercased())
        .font(.system(size: 16, weight: .regular, design: .monospaced))
        .foregroundColor(.black)
      
      Spacer()
      
      if isSelected {
        Image(systemName: "checkmark")
          .font(.system(size: 14, weight: .medium, design: .monospaced))
          .foregroundColor(.black)
          .accessibilityLabel("Selected")
      }
      
      Button(action: onDelete) {
        Image(systemName: "trash")
          .font(.system(size: 14, weight: .medium, design: .monospaced))
          .foregroundColor(.gray)
      }
      .buttonStyle(.plain)
      .accessibilityLabel("Delete Mode")
    }
    .padding(.horizontal, 20)
    .padding(.vertical, 16)
    .contentShape(Rectangle())
    .onTapGesture {
      onSelect()
    }
    .accessibilityElement(children: .combine)
    .accessibilityAddTraits(isSelected ? .isSelected : [])
  }
}

#Preview {
  ProfileModalView(
    profiles: [
      BlockedProfiles(name: "GYM"),
      BlockedProfiles(name: "ULTRA STRICT"),
      BlockedProfiles(name: "WORK"),
      BlockedProfiles(name: "DEFAULT")
    ],
    selectedProfile: .constant(nil),
    onEditProfile: { _ in },
    onCreateProfile: {},
    onDeleteProfile: { _ in }
  )
}