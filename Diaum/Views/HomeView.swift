import FamilyControls
import SwiftData
import SwiftUI

struct HomeView: View {
  @Environment(\.modelContext) private var context
  @Environment(\.openURL) var openURL
  @Environment(\.scenePhase) private var scenePhase

  @EnvironmentObject var requestAuthorizer: RequestAuthorizer
  @EnvironmentObject var strategyManager: StrategyManager
  @EnvironmentObject var navigationManager: NavigationManager
  @EnvironmentObject var ratingManager: RatingManager

  // Profile management
  @Query(sort: [
    SortDescriptor(\BlockedProfiles.order, order: .forward),
    SortDescriptor(\BlockedProfiles.createdAt, order: .reverse),
  ]) private var profiles: [BlockedProfiles]
  
  @State private var isProfileListPresent = false
  @State private var showNewProfileView = false
  @State private var profileToEdit: BlockedProfiles? = nil
  @State private var profileToShowStats: BlockedProfiles? = nil
  @State private var showDonationView = false
  @State private var showEmergencyView = false
  @State private var navigateToProfileId: UUID? = nil
  @State private var selectedProfile: BlockedProfiles? = nil
  @State private var showProfileModal = false

  // Alerts
  @State private var showingAlert = false
  @State private var alertTitle = ""
  @State private var alertMessage = ""

  // Intro sheet
  @AppStorage("showIntroScreen") private var showIntroScreen = true
  
  // Last used profile
  @AppStorage("lastUsedProfileId") private var lastUsedProfileId: String = ""

  // UI States
  @State private var opacityValue = 1.0

  var isBlocking: Bool {
    return strategyManager.isBlocking
  }

  var activeSessionProfileId: UUID? {
    return strategyManager.activeSession?.blockedProfile.id
  }

  var isBreakAvailable: Bool {
    return strategyManager.isBreakAvailable
  }

  var isBreakActive: Bool {
    return strategyManager.isBreakActive
  }

  // MARK: - VIEW BODY (substituído e ajustado)
  var body: some View {
    ZStack {
      // Fundo preto fosco
      Color(red: 0.07, green: 0.07, blue: 0.07)
        .ignoresSafeArea()

      VStack {
        // Topo
        HStack {
          Spacer()
          Text("FOCCO")
          .font(.system(size: 28, weight: .black, design: .default))
          Spacer()

          // Ícone de menu hamburguer
          VStack(spacing: 5) {
            ForEach(0..<3) { _ in
              Rectangle()
                .fill(Color.white)
                .frame(width: 24, height: 2)
            }
          }
          .padding(.trailing, 28)
        }
        .padding(.top, 32)

        Spacer()

        // Texto de instrução
        Text(isBlocking ? "TAP TO UNFOCCO" : "TAP TO FOCCO")
          .font(.system(size: 14, weight: .regular, design: .monospaced))
          .foregroundColor(.white)
          .tracking(2)
          .padding(.bottom, 28)

        // Botão principal
        Button(action: {
          if isBlocking {
            if let activeProfile = strategyManager.activeSession?.blockedProfile {
              strategyButtonPress(activeProfile)
            }
          } else {
            if let selectedProfile = selectedProfile {
              strategyButtonPress(selectedProfile)
            } else if profiles.isEmpty {
              showNewProfileView = true
            } else {
              showProfileModal = true
            }
          }
        }) {
          ZStack {
            RoundedRectangle(cornerRadius: 28)
              .fill(Color(red: 0.11, green: 0.11, blue: 0.11))
              .frame(width: 220, height: 220)
              .shadow(color: Color.black.opacity(0.7), radius: 16, x: 0, y: 8)
              .overlay(
                RoundedRectangle(cornerRadius: 28)
                  .stroke(Color.black.opacity(0.5), lineWidth: 3)
                  .blur(radius: 2)
              )
              .overlay(
                RoundedRectangle(cornerRadius: 28)
                  .stroke(Color.white.opacity(0.05), lineWidth: 1)
                  .offset(x: -1, y: -1)
              )

            Text("FOCCO")
              .font(.system(size: 28, weight: .black, design: .default))
          }
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.bottom, 36)

        // Modo
        VStack(spacing: 6) {
          Text("MODE")
            .font(.system(size: 12, weight: .regular, design: .monospaced))
            .foregroundColor(.white.opacity(0.8))

          Text("BASIC")
            .font(.system(size: 14, weight: .bold, design: .monospaced))
            .foregroundColor(.black)
            .padding(.horizontal, 24)
            .padding(.vertical, 8)
            .background(Color.white)
            .cornerRadius(6)
        }

        Spacer()

        // Rodapé
        VStack(spacing: 4) {
          Text(isBlocking ? "YOU’VE BEEN FOCCUSED FOR" : "TOTAL BLOCKED TODAY")
            .font(.system(size: 13, weight: .regular, design: .monospaced))
            .foregroundColor(.white.opacity(0.8))

          Text(isBlocking ? formatElapsedTime(strategyManager.elapsedTime)
                          : formatElapsedTime(getDailyBlockedTime()))
            .font(.system(size: 14, weight: .semibold, design: .monospaced))
            .foregroundColor(.white)
        }
        .padding(.bottom, 40)
      }
    }
    .sheet(isPresented: $showProfileModal) {
      ProfileModalView(
        profiles: profiles,
        selectedProfile: $selectedProfile,
        onEditProfile: { profile in
          profileToEdit = profile
          showProfileModal = false
        },
        onCreateProfile: {
          showNewProfileView = true
          showProfileModal = false
        },
        onDeleteProfile: { profile in
          deleteProfile(profile)
          showProfileModal = false
        }
      )
    }
    .sheet(isPresented: $showNewProfileView) {
      BlockedProfileView(profile: nil) { newProfile in
        strategyManager.toggleBlocking(context: context, activeProfile: newProfile)
        showNewProfileView = false
      }
    }
    .sheet(item: $profileToEdit) { profile in
      BlockedProfileView(profile: profile) { _ in
        profileToEdit = nil
      }
    }
    .onChange(of: scenePhase) { _, newPhase in
      if newPhase == .active {
        loadApp()
      } else if newPhase == .background {
        unloadApp()
      }
    }
    .onAppear { onAppearApp() }
  }

  // MARK: - Funções originais (mantidas)

  private func toggleSessionFromDeeplink(_ profileId: String, link: URL) {
    strategyManager.toggleSessionFromDeeplink(profileId, url: link, context: context)
  }

  private func strategyButtonPress(_ profile: BlockedProfiles) {
    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
    impactFeedback.impactOccurred()
    
    saveLastUsedProfile(profile)
    strategyManager.toggleBlocking(context: context, activeProfile: profile)
    ratingManager.incrementLaunchCount()
  }

  private func loadApp() {
    strategyManager.loadActiveSession(context: context)
  }

  private func onAppearApp() {
    strategyManager.loadActiveSession(context: context)
    strategyManager.cleanUpGhostSchedules(context: context)
    loadLastUsedProfile()
  }

  private func loadLastUsedProfile() {
    if !lastUsedProfileId.isEmpty,
       let profileId = UUID(uuidString: lastUsedProfileId) {
      selectedProfile = profiles.first { $0.id == profileId }
    }
  }

  private func saveLastUsedProfile(_ profile: BlockedProfiles) {
    lastUsedProfileId = profile.id.uuidString
  }

  private func deleteProfile(_ profile: BlockedProfiles) {
    if selectedProfile?.id == profile.id {
      selectedProfile = nil
    }
    context.delete(profile)
    try? context.save()
  }

  private func unloadApp() {
    strategyManager.stopTimer()
  }

  private func showErrorAlert(message: String) {
    alertTitle = "Whoops"
    alertMessage = message
    showingAlert = true
  }

  private func dismissAlert() { showingAlert = false }

  private func formatElapsedTime(_ timeInterval: TimeInterval) -> String {
    let hours = Int(timeInterval) / 3600
    let minutes = Int(timeInterval) % 3600 / 60
    let seconds = Int(timeInterval) % 60
    return hours > 0
      ? String(format: "%d:%02d:%02d", hours, minutes, seconds)
      : String(format: "%02d:%02d", minutes, seconds)
  }

  private func getDailyBlockedTime() -> TimeInterval {
    let calendar = Calendar.current
    let startOfDay = calendar.startOfDay(for: Date())
    let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
    var totalTime: TimeInterval = 0
    for profile in profiles {
      let todaySessions = profile.sessions.filter {
        guard let endTime = $0.endTime else { return false }
        return $0.startTime >= startOfDay && endTime < endOfDay
      }
      totalTime += todaySessions.reduce(0) { $0 + ($1.endTime?.timeIntervalSince($1.startTime) ?? 0) }
    }
    return totalTime
  }
}

#Preview {
  HomeView()
    .environmentObject(RequestAuthorizer())
    .environmentObject(TipManager())
    .environmentObject(NavigationManager())
    .environmentObject(StrategyManager())
    .defaultAppStorage(UserDefaults(suiteName: "preview")!)
    .onAppear {
      UserDefaults(suiteName: "preview")!.set(false, forKey: "showIntroScreen")
    }
}
