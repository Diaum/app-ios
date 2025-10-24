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
        strategyManager.isBlocking
    }
    
    var activeSessionProfileId: UUID? {
        strategyManager.activeSession?.blockedProfile.id
    }
    
    var isBreakAvailable: Bool {
        strategyManager.isBreakAvailable
    }
    
    var isBreakActive: Bool {
        strategyManager.isBreakActive
    }
    
    var backgroundColor: Color {
        isBlocking ? Color(red: 0x11/255.0, green: 0x11/255.0, blue: 0x11/255.0) : Color.white
    }
    
    // MARK: - VIEW BODY
    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.3), value: isBlocking)
            
            if isBlocking {
                darkModeView
            } else {
                lightModeView
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
            showIntroScreen = !newValue
        }
        .onChange(of: profiles) { _, newValue in
            if !newValue.isEmpty {
                loadApp()
                if selectedProfile == nil {
                    selectedProfile = newValue.first
                }
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
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
        .onAppear { onAppearApp() }
        .sheet(isPresented: $showIntroScreen) {
            IntroView {
                requestAuthorizer.requestAuthorization()
            }.interactiveDismissDisabled()
        }
        .alert(alertTitle, isPresented: $showingAlert) {
            Button("OK", role: .cancel) { dismissAlert() }
        } message: {
            Text(alertMessage)
        }
    }
    
    // MARK: - DARK MODE VIEW
    private var darkModeView: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("FOCCO")
                    .font(.system(size: 24, weight: .bold, design: .default))
                    .foregroundColor(.white)
                
                Spacer()
                
                VStack(spacing: 4) {
                    ForEach(0..<3) { _ in
                        Rectangle()
                            .fill(Color.white)
                            .frame(width: 20, height: 2)
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            
            Spacer()
            
            // Main content
            VStack(spacing: 0) {
                Text("TAP TO UNFOCCO")
                    .font(.system(size: 16, weight: .medium, design: .default))
                    .foregroundColor(.white)
                    .tracking(1)
                    .padding(.bottom, 32)
                
                Button(action: {
                    if let activeProfile = strategyManager.activeSession?.blockedProfile {
                        strategyButtonPress(activeProfile)
                    }
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color(red: 0x1a/255.0, green: 0x1a/255.0, blue: 0x1a/255.0))
                            .frame(width: 200, height: 200)
                            .shadow(color: Color.black.opacity(0.8), radius: 8, x: 4, y: 4)
                            .shadow(color: Color.white.opacity(0.1), radius: 8, x: -4, y: -4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                        
                        HStack(spacing: 0) {
                            Text("FOCCO")
                                .font(.system(size: 28, weight: .black, design: .default))
                                .foregroundColor(.white)
                            Text("™")
                                .font(.system(size: 12))
                                .foregroundColor(.white)
                                .baselineOffset(8)
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.bottom, 32)
                
                VStack(spacing: 16) {
                    HStack(spacing: 8) {
                        Text("MODE")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))
                        Image(systemName: "gearshape")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    
                    HStack(spacing: 12) {
                        Button("BASIC") { }
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color(red: 0.1, green: 0.1, blue: 0.1))
                            .cornerRadius(8)
                            .shadow(color: .black.opacity(0.5), radius: 2, x: 1, y: 1)
                        
                        Button("SOCIAL") { }
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.4))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(8)
                    }
                    
                    HStack(spacing: 6) {
                        ForEach(0..<3) { index in
                            Circle()
                                .fill(index == 0 ? Color.white : Color.white.opacity(0.3))
                                .frame(width: 6, height: 6)
                        }
                    }
                }
                .padding(.bottom, 40)
                
                // Timer section
                VStack(spacing: 8) {
                    Text("YOU'VE BEEN BLOCKED FOR")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                        .tracking(0.5)
                    
                    Text(formatElapsedTime(calculateElapsedTime()))
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                }
                .padding(.bottom, 20)
            }
            Spacer()
        }
    }
    
    // MARK: - LIGHT MODE VIEW
    private var lightModeView: some View {
        VStack(spacing: 0) {
            HStack {
                Text("FOCCO")
                    .font(.system(size: 24, weight: .black))
                    .foregroundColor(.black)
                
                Spacer()
                
                VStack(spacing: 4) {
                    ForEach(0..<3) { _ in
                        Rectangle()
                            .fill(Color.black)
                            .frame(width: 20, height: 2)
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            
            Spacer()
            
            VStack(spacing: 0) {
                Text("TAP TO FOCCO")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.black)
                    .tracking(1)
                    .padding(.bottom, 32)
                
                Button(action: {
                    if let selectedProfile = selectedProfile {
                        strategyButtonPress(selectedProfile)
                    } else if profiles.isEmpty {
                        showNewProfileView = true
                    } else {
                        showProfileModal = true
                    }
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color.white)
                            .frame(width: 200, height: 200)
                            .shadow(color: .black.opacity(0.1), radius: 8, x: 4, y: 4)
                            .shadow(color: .white.opacity(0.8), radius: 8, x: -4, y: -4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                            )
                        
                        HStack(spacing: 0) {
                            Text("FOCCO")
                                .font(.system(size: 28, weight: .black))
                                .foregroundColor(.black)
                            Text("™")
                                .font(.system(size: 12))
                                .foregroundColor(.black)
                                .baselineOffset(8)
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.bottom, 32)
                
                VStack(spacing: 16) {
                    HStack(spacing: 8) {
                        Text("MODE")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                        Image(systemName: "gearshape")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                    
                    HStack(spacing: 12) {
                        Button("BASIC") { }
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.black)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color.white)
                            .cornerRadius(8)
                            .shadow(color: .black.opacity(0.1), radius: 2, x: 1, y: 1)
                        
                        Button("SOCIAL") { }
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }
                    
                    HStack(spacing: 6) {
                        ForEach(0..<3) { index in
                            Circle()
                                .fill(index == 0 ? Color.black : Color.gray.opacity(0.3))
                                .frame(width: 6, height: 6)
                        }
                    }
                }
                .padding(.bottom, 40)
            }
            Spacer()
        }
    }
    
    // MARK: - FUNÇÕES
    
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
    
    private func calculateElapsedTime() -> TimeInterval {
        guard let session = strategyManager.activeSession else { return 0 }
        
        let startTime = session.startTime
        let endTime = session.endTime ?? Date()
        
        return endTime.timeIntervalSince(startTime)
    }
    
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
