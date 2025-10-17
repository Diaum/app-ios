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
    NavigationStack {
      VStack(spacing: 0) {
        // Header with BRICK MODES title
        HStack {
          Text("BRICK MODES")
            .font(.system(size: 32, weight: .bold, design: .monospaced))
            .foregroundColor(.black)
          
          Spacer()
          
          Button(action: { dismiss() }) {
            Image(systemName: "xmark")
              .font(.system(size: 18, weight: .medium, design: .monospaced))
              .foregroundColor(.black)
          }
          .accessibilityLabel("Close")
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
        Button(action: { onCreateProfile() }) {
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
        Text("Tap to edit • Hold to delete")
          .font(.system(size: 10, weight: .regular, design: .monospaced))
          .foregroundColor(.gray.opacity(0.6))
          .padding(.bottom, 20)
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
    VStack(spacing: 24) {
      Image(systemName: "person.crop.circle.badge.plus")
        .font(.system(size: 64, weight: .light, design: .monospaced))
        .foregroundColor(.gray)
      
      VStack(spacing: 8) {
        Text("No modes created yet")
          .font(.system(size: 18, weight: .semibold, design: .monospaced))
          .foregroundColor(.black)
        
        Text("Create your first mode to start blocking distractions")
          .font(.system(size: 14, design: .monospaced))
          .foregroundColor(.gray)
          .multilineTextAlignment(.center)
      }
    }
    .padding(.horizontal, 20)
    .padding(.vertical, 40)
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
          onEdit: { onEditProfile(profile) },
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
  let onEdit: () -> Void
  let onDelete: () -> Void
  
  @State private var longPressProgress: Double = 0.0
  @State private var isLongPressing = false
  
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
      
      // Selection button
      Button(action: onSelect) {
        Image(systemName: "circle")
          .font(.system(size: 16, weight: .medium, design: .monospaced))
          .foregroundColor(.gray)
      }
      .buttonStyle(.plain)
      .accessibilityLabel("Select Mode")
      
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
    .background(
      ZStack {
        // Long press progress indicator
        if isLongPressing {
          Rectangle()
            .fill(Color.blue.opacity(0.1))
            .frame(width: UIScreen.main.bounds.width * longPressProgress)
            .animation(.linear(duration: 0.1), value: longPressProgress)
        }
      }
    )
    .contentShape(Rectangle())
    .onTapGesture {
      onEdit()
    }
    .onLongPressGesture(minimumDuration: 3.0, maximumDistance: 50) {
      onDelete()
    } onPressingChanged: { pressing in
      if pressing {
        startLongPress()
      } else {
        cancelLongPress()
      }
    }
    .accessibilityElement(children: .combine)
    .accessibilityAddTraits(isSelected ? .isSelected : [])
  }
  
  private func startLongPress() {
    isLongPressing = true
    longPressProgress = 0.0
    
    Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
      longPressProgress += 0.033 // 3 seconds total
      if longPressProgress >= 1.0 {
        timer.invalidate()
        isLongPressing = false
      }
    }
  }
  
  private func cancelLongPress() {
    isLongPressing = false
    longPressProgress = 0.0
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