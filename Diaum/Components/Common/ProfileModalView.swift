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
  @State private var isDeleteModeActive = false
  @State private var showingNewModeModal = false
  @State private var profileToEdit: BlockedProfiles? = nil
  
  // Dynamic height calculation
  // MARK: - Computed Properties
  private var sortedProfiles: [BlockedProfiles] {
    if let selectedProfile = selectedProfile {
      // Colocar o perfil selecionado no topo
      return [selectedProfile] + profiles.filter { $0.id != selectedProfile.id }
    } else {
      return profiles
    }
  }
  
  private var modalHeight: CGFloat {
    let baseHeight: CGFloat = 200 // Header + bottom button + padding
    let profileRowHeight: CGFloat = 60 // Each profile row height
    let emptyStateHeight: CGFloat = 120 // Empty state height (reduced)
    
    if profiles.isEmpty {
      return max(400, baseHeight + emptyStateHeight)
    } else {
      let contentHeight = baseHeight + (CGFloat(profiles.count) * profileRowHeight)
      return max(400, min(contentHeight, 600)) // Min 400, Max 600
    }
  }
  
  var body: some View {
    NavigationStack {
      VStack(spacing: 0) {
        // Header with BRICK MODES title
        HStack {
          Text("BRICK MODES")
            .font(.system(size: 32, weight: .bold, design: .monospaced))
            .foregroundColor(.black)
          
          Spacer()
          
          Button(action: { 
            isDeleteModeActive.toggle()
          }) {
            Image(systemName: isDeleteModeActive ? "trash.fill" : "trash")
              .font(.system(size: 18, weight: .medium, design: .monospaced))
              .foregroundColor(isDeleteModeActive ? .red : .black)
          }
          .accessibilityLabel(isDeleteModeActive ? "Exit Delete Mode" : "Enter Delete Mode")
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 30)
        
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
            
          }
        }
        
        // Black ADD MODE Button at the very bottom
        Button(action: { 
          showingNewModeModal = true
        }) {
          Text("ADD MODE")
            .font(.system(size: 16, weight: .semibold, design: .monospaced))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
              RoundedRectangle(cornerRadius: 12)
                .fill(.black)
            )
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 20)
        .padding(.bottom, 8)
        
        // Small message at the bottom
        Text(isDeleteModeActive ? "Tap mode to delete" : "Tap to select • Gear to edit")
          .font(.system(size: 10, weight: .regular, design: .monospaced))
          .foregroundColor(.gray.opacity(0.6))
          .padding(.bottom, 20)
      }
      .background(Color.white)
    }
    .alert("Delete Profile", isPresented: $showingDeleteAlert) {
      Button("Cancel", role: .cancel) { 
        profileToDelete = nil
      }
      Button("Delete", role: .destructive) {
        if let profile = profileToDelete {
          onDeleteProfile(profile)
          profileToDelete = nil
          // Não fechar o modal após deletar
        }
      }
    } message: {
      Text("Are you sure you want to delete '\(profileToDelete?.name ?? "")'? This action cannot be undone.")
    }
    .presentationDetents([.height(modalHeight)])
    .presentationDragIndicator(.visible)
    .presentationBackground(.regularMaterial)
    .sheet(isPresented: $showingNewModeModal) {
      NewModeModal(profileToEdit: profileToEdit, onProfileCreated: { newProfile in
        // Selecionar automaticamente o novo modo criado
        selectedProfile = newProfile
        profileToEdit = nil
        dismiss()
      })
    }
  }
  
  // MARK: - Empty State View
  private var emptyStateView: some View {
    VStack(spacing: 16) {
      Image(systemName: "person.crop.circle.badge.plus")
        .font(.system(size: 40, weight: .light, design: .monospaced))
        .foregroundColor(.gray)
      
      VStack(spacing: 6) {
        Text("No modes created yet")
          .font(.system(size: 16, weight: .semibold, design: .monospaced))
          .foregroundColor(.black)
        
        Text("Create your first mode to start blocking distractions")
          .font(.system(size: 12, design: .monospaced))
          .foregroundColor(.gray)
          .multilineTextAlignment(.center)
      }
    }
    .padding(.horizontal, 20)
    .padding(.vertical, 20)
  }
  
  // MARK: - Modes List View
  private var modesListView: some View {
    VStack(spacing: 0) {
      ForEach(sortedProfiles) { profile in
        ModeRowView(
          profile: profile,
          isSelected: selectedProfile?.id == profile.id,
          isDeleteModeActive: isDeleteModeActive,
          onSelect: {
            selectedProfile = profile
            dismiss()
          },
          onEdit: { 
            profileToEdit = profile
            showingNewModeModal = true
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
  let isDeleteModeActive: Bool
  let onSelect: () -> Void
  let onEdit: () -> Void
  let onDelete: () -> Void
  
  var body: some View {
    HStack {
      Text(profile.name.uppercased())
        .font(.system(size: 16, weight: .regular, design: .monospaced))
        .foregroundColor(.black)
      
      Spacer()
      
      // Edit button
      Button(action: onEdit) {
        Image(systemName: "gearshape")
          .font(.system(size: 14, weight: .medium, design: .monospaced))
          .foregroundColor(.gray)
      }
      .buttonStyle(.plain)
      .accessibilityLabel("Edit Mode")
    }
    .padding(.horizontal, 20)
    .padding(.vertical, 16)
    .background(
      isDeleteModeActive ? Color.red.opacity(0.1) : Color.clear
    )
    .contentShape(Rectangle())
    .onTapGesture {
      if isDeleteModeActive {
        onDelete()
      } else {
        onSelect()
      }
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