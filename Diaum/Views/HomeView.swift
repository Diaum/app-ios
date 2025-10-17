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

  var body: some View {
    ZStack {
      // Background - Dynamic theme
      Color(isBlocking ? Color(red: 0.07, green: 0.07, blue: 0.07) : Color.white)
        .ignoresSafeArea()
        .animation(.easeInOut(duration: 0.3), value: isBlocking)
      
      VStack(spacing: 0) {
        Spacer()
        
        // Main Content - Centered vertically and horizontally
        VStack(spacing: 16) {
          // Label Above Button - Always visible
          Text(isBlocking ? "TAP TO UNBRICK" : "TAP TO BRICK")
            .font(.system(size: 16, weight: .regular, design: .monospaced))
            .foregroundColor(isBlocking ? .white : .black)
            .multilineTextAlignment(.center)
            .animation(.easeInOut(duration: 0.3), value: isBlocking)
          
          // Main BRICK Button
          Button(action: {
            if isBlocking {
              if let activeProfile = strategyManager.activeSession?.blockedProfile {
                strategyButtonPress(activeProfile)
              }
            } else {
              // Only allow blocking if there's a valid profile selected
              if let selectedProfile = selectedProfile {
                strategyButtonPress(selectedProfile)
              } else if profiles.isEmpty {
                showNewProfileView = true
              } else {
                // Show profile selection if no profile is selected
                showProfileModal = true
              }
            }
          }) {
            ZStack {
              // Button background with enhanced lighting and shadow
              RoundedRectangle(cornerRadius: 16)
                .fill(
                  LinearGradient(
                    gradient: Gradient(colors: isBlocking ? [
                      Color(red: 0.55, green: 0.55, blue: 0.62), // Dark theme
                      Color(red: 0.42, green: 0.42, blue: 0.48)
                    ] : [
                      Color(red: 0.15, green: 0.15, blue: 0.20), // Black when unlocked
                      Color(red: 0.10, green: 0.10, blue: 0.15)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                  )
                )
                .frame(width: 120, height: 120)
                .overlay(
                  RoundedRectangle(cornerRadius: 16)
                    .stroke(
                      LinearGradient(
                        gradient: Gradient(colors: isBlocking ? [
                          Color.white.opacity(0.3),
                          Color.clear,
                          Color.black.opacity(0.2)
                        ] : [
                          Color.white.opacity(0.4),
                          Color.clear,
                          Color.black.opacity(0.3)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                      ),
                      lineWidth: isBlocking ? 1 : 2
                    )
                )
                .shadow(color: isBlocking ? .black.opacity(0.3) : .black.opacity(0.4), radius: isBlocking ? 8 : 12, x: 0, y: isBlocking ? 4 : 6)
                .shadow(color: isBlocking ? .white.opacity(0.1) : .white.opacity(0.2), radius: isBlocking ? 2 : 4, x: 0, y: isBlocking ? -1 : -2)
                .animation(.easeInOut(duration: 0.3), value: isBlocking)
              
              // Button text
              Text("BRICK")
                .font(.system(size: 18, weight: .medium, design: .monospaced))
                .foregroundColor(.white) // Always white since button is always dark
                .shadow(color: .black.opacity(0.5), radius: 1, x: 0, y: 1)
                .animation(.easeInOut(duration: 0.3), value: isBlocking)
            }
          }
          .buttonStyle(PlainButtonStyle())
          
          // Label Below Button - Profile Name (Clickable)
          Button(action: {
            showProfileModal = true
          }) {
            Text(selectedProfile?.name ?? "MODE")
              .font(.system(size: 14, weight: .medium, design: .monospaced))
              .foregroundColor(isBlocking ? .white.opacity(0.8) : .black.opacity(0.8))
              .padding(.horizontal, 20)
              .padding(.vertical, 10)
              .background(
                RoundedRectangle(cornerRadius: 16)
                  .stroke(isBlocking ? Color.white.opacity(0.4) : Color.black.opacity(0.4), lineWidth: 2)
                  .background(
                    RoundedRectangle(cornerRadius: 16)
                      .fill(isBlocking ? Color.black.opacity(0.2) : Color.white.opacity(0.2))
                  )
              )
              .animation(.easeInOut(duration: 0.3), value: isBlocking)
          }
          .buttonStyle(PlainButtonStyle())
          
          // Timer Counter - Always visible with different content
          VStack(spacing: 4) {
            if isBlocking {
              Text("YOU'VE BEEN BRICKED FOR")
                .font(.system(size: 12, weight: .regular, design: .monospaced))
                .foregroundColor(.white.opacity(0.6))
              
              Text(formatElapsedTime(strategyManager.elapsedTime))
                .font(.system(size: 12, weight: .regular, design: .monospaced))
                .foregroundColor(.white.opacity(0.6))
            } else {
              Text("TOTAL BLOCKED TODAY")
                .font(.system(size: 12, weight: .regular, design: .monospaced))
                .foregroundColor(.black.opacity(0.6))
              
              Text(formatElapsedTime(getDailyBlockedTime()))
                .font(.system(size: 12, weight: .regular, design: .monospaced))
                .foregroundColor(.black.opacity(0.6))
            }
          }
          .animation(.easeInOut(duration: 0.3), value: isBlocking)
        }
        
        Spacer()
      }
    }
    .refreshable {
      loadApp()
    }
    .sheet(isPresented: $isProfileListPresent) {
      BlockedProfileListView()
    }
    .frame(
      minWidth: 0,
      maxWidth: .infinity,
      minHeight: 0,
      maxHeight: .infinity,
      alignment: .topLeading
    )
    .onChange(of: navigationManager.profileId) { _, newValue in
      if let profileId = newValue, let url = navigationManager.link {
        toggleSessionFromDeeplink(profileId, link: url)
        navigationManager.clearNavigation()
      }
    }
    .onChange(of: navigationManager.navigateToProfileId) { _, newValue in
      if let profileId = newValue {
        navigateToProfileId = UUID(uuidString: profileId)
        navigationManager.clearNavigation()
      }
    }
    .onChange(of: requestAuthorizer.isAuthorized) { _, newValue in
      if newValue {
        showIntroScreen = false
      } else {
        showIntroScreen = true
      }
    }
    .onChange(of: profiles) { oldValue, newValue in
      if !newValue.isEmpty {
        loadApp()
        // Auto-select first profile if none selected
        if selectedProfile == nil {
          selectedProfile = newValue.first
        }
      }
    }
    .onChange(of: scenePhase) { oldPhase, newPhase in
      if newPhase == .active {
        loadApp()
      } else if newPhase == .background {
        unloadApp()
      }
    }
    .onReceive(strategyManager.$errorMessage) { errorMessage in
      if let message = errorMessage {
        showErrorAlert(message: message)
      }
    }
    .onAppear {
      onAppearApp()
    }
    .sheet(isPresented: $showIntroScreen) {
      IntroView {
        requestAuthorizer.requestAuthorization()
      }.interactiveDismissDisabled()
    }
    .sheet(item: $profileToEdit) { profile in
      BlockedProfileView(profile: profile)
    }
    .sheet(item: $profileToShowStats) { profile in
      ProfileInsightsView(profile: profile)
    }
    .sheet(isPresented: $showNewProfileView) {
      BlockedProfileView(profile: nil) { newProfile in
        strategyManager.toggleBlocking(context: context, activeProfile: newProfile)
      }
    }
    .sheet(isPresented: $strategyManager.showCustomStrategyView) {
      BlockingStrategyActionView(
        customView: strategyManager.customStrategyView
      )
    }
    .sheet(isPresented: $showDonationView) {
      SupportView()
    }
    .sheet(isPresented: $showEmergencyView) {
      EmergencyView()
        .presentationDetents([.height(350)])
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
        }
      )
    }
    .alert(alertTitle, isPresented: $showingAlert) {
      Button("OK", role: .cancel) { dismissAlert() }
    } message: {
      Text(alertMessage)
    }
  }

  private func toggleSessionFromDeeplink(_ profileId: String, link: URL) {
    strategyManager.toggleSessionFromDeeplink(profileId, url: link, context: context)
  }

  private func strategyButtonPress(_ profile: BlockedProfiles) {
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
    if !lastUsedProfileId.isEmpty {
      if let profileId = UUID(uuidString: lastUsedProfileId) {
        selectedProfile = profiles.first { $0.id == profileId }
      }
    }
  }
  
  private func saveLastUsedProfile(_ profile: BlockedProfiles) {
    lastUsedProfileId = profile.id.uuidString
  }

  private func unloadApp() {
    strategyManager.stopTimer()
  }

  private func showErrorAlert(message: String) {
    alertTitle = "Whoops"
    alertMessage = message
    showingAlert = true
  }

  private func dismissAlert() {
    showingAlert = false
  }
  
  private func formatElapsedTime(_ timeInterval: TimeInterval) -> String {
    let hours = Int(timeInterval) / 3600
    let minutes = Int(timeInterval) % 3600 / 60
    let seconds = Int(timeInterval) % 60
    
    if hours > 0 {
      return String(format: "%d:%02d:%02d", hours, minutes, seconds)
    } else {
      return String(format: "%02d:%02d", minutes, seconds)
    }
  }
  
  private func getDailyBlockedTime() -> TimeInterval {
    let calendar = Calendar.current
    let today = Date()
    let startOfDay = calendar.startOfDay(for: today)
    let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
    
    var totalTime: TimeInterval = 0
    
    for profile in profiles {
      let todaySessions = profile.sessions.filter { session in
        guard let endTime = session.endTime else { return false }
        return session.startTime >= startOfDay && endTime < endOfDay
      }
      
      for session in todaySessions {
        if let endTime = session.endTime {
          totalTime += endTime.timeIntervalSince(session.startTime)
        }
      }
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
      UserDefaults(suiteName: "preview")!.set(
        false,
        forKey: "showIntroScreen"
      )
    }
}
