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

  // UI States
  @State private var opacityValue = 1.0
  @State private var emergencyProgress: Double = 0.0
  @State private var emergencyStopTimer: Timer?
  @State private var isEmergencyStopActive = false

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
      // Background - Dark gradient/solid color (#121212)
      Color(red: 0.07, green: 0.07, blue: 0.07) // #121212
        .ignoresSafeArea()
      
      VStack(spacing: 0) {
        Spacer()
        
        // Main Content - Centered vertically and horizontally
        VStack(spacing: 16) {
          // Label Above Button - Always visible
          Text(isBlocking ? "TAP TO UNBRICK" : "TAP TO BRICK")
            .font(.system(size: 16, weight: .regular, design: .monospaced))
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
          
          // Main BRICK Button
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
                // Use first profile if none selected
                strategyButtonPress(profiles[0])
              }
            }
          }) {
            ZStack {
              // Button background
              RoundedRectangle(cornerRadius: 12)
                .fill(Color(red: 0.48, green: 0.48, blue: 0.55)) // #7B7B8C
                .frame(width: 120, height: 120)
                .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
              
              // Emergency progress bar (red, growing from bottom to top) - inside button
              if isEmergencyStopActive {
                VStack {
                  Spacer()
                  RoundedRectangle(cornerRadius: 12)
                    .fill(Color.red.opacity(0.3))
                    .frame(width: 120, height: 120 * emergencyProgress)
                    .animation(.linear(duration: 0.1), value: emergencyProgress)
                }
              }
              
              // Button text
              Text("BRICK")
                .font(.system(size: 18, weight: .regular, design: .monospaced))
                .foregroundColor(.white)
                .zIndex(1) // Ensure text stays on top
            }
          }
          .buttonStyle(PlainButtonStyle())
          .onLongPressGesture(minimumDuration: 2.0, maximumDistance: 50) {
            // Emergency stop - force stop any active session
            emergencyStop()
          } onPressingChanged: { pressing in
            if pressing {
              startEmergencyStopTimer()
            } else {
              cancelEmergencyStopTimer()
            }
          }
          
          // Label Below Button - "DEFAULT" or Profile Name (Clickable)
          Button(action: {
            showProfileModal = true
          }) {
            Text(selectedProfile?.name ?? "DEFAULT")
              .font(.system(size: 14, weight: .regular, design: .monospaced))
              .foregroundColor(.white.opacity(0.7))
              .padding(.horizontal, 16)
              .padding(.vertical, 8)
              .background(
                RoundedRectangle(cornerRadius: 8)
                  .stroke(Color.white.opacity(0.3), lineWidth: 1)
              )
          }
          .buttonStyle(PlainButtonStyle())
          
          // Timer Counter - Only when blocking
          if isBlocking {
            VStack(spacing: 4) {
              Text("YOU'VE BEEN BRICKED FOR")
                .font(.system(size: 12, weight: .regular, design: .monospaced))
                .foregroundColor(.white.opacity(0.6))
              
              Text(formatElapsedTime(strategyManager.elapsedTime))
                .font(.system(size: 12, weight: .regular, design: .monospaced))
                .foregroundColor(.white.opacity(0.6))
            }
          }
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
    strategyManager.toggleBlocking(context: context, activeProfile: profile)
    ratingManager.incrementLaunchCount()
  }

  private func loadApp() {
    strategyManager.loadActiveSession(context: context)
  }

  private func onAppearApp() {
    strategyManager.loadActiveSession(context: context)
    strategyManager.cleanUpGhostSchedules(context: context)
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
  
  // Emergency Stop Functions
  private func emergencyStop() {
    // Force stop any active session immediately using emergency unblock
    if isBlocking {
      strategyManager.emergencyUnblock(context: context)
    }
    // Clear any timers and reset progress
    cancelEmergencyStopTimer()
    emergencyProgress = 0.0
    isEmergencyStopActive = false
  }
  
  private func startEmergencyStopTimer() {
    cancelEmergencyStopTimer() // Cancel any existing timer
    isEmergencyStopActive = true
    emergencyProgress = 0.0
    
    // Start progress animation
    emergencyStopTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
      emergencyProgress += 0.025 // 2 seconds total (0.05 * 40 = 2.0)
      if emergencyProgress >= 1.0 {
        emergencyStop()
      }
    }
  }
  
  private func cancelEmergencyStopTimer() {
    emergencyStopTimer?.invalidate()
    emergencyStopTimer = nil
    isEmergencyStopActive = false
    emergencyProgress = 0.0
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