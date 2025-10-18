//
//  ProfileWidgetEntryView.swift
//  DiaumWidget
//
//  Created by Ali Waseem on 2025-03-11.
//

import AppIntents
import FamilyControls
import SwiftUI
import WidgetKit

// MARK: - Widget View
struct ProfileWidgetEntryView: View {
  var entry: ProfileControlProvider.Entry

  // Computed property to determine if we should use white text
  private var shouldUseWhiteText: Bool {
    return entry.isBreakActive || entry.isSessionActive
  }

  // Computed property to determine if the widget should show as unavailable
  private var isUnavailable: Bool {
    guard let selectedProfileId = entry.selectedProfileId,
      let activeSession = entry.activeSession
    else {
      return false
    }

    // Check if the active session's profile ID matches the widget's selected profile ID
    return activeSession.blockedProfileId.uuidString != selectedProfileId
  }

  private var quickLaunchEnabled: Bool {
    return entry.useProfileURL == true
  }

  private var linkToOpen: URL {
    // Don't open the app via profile to stop the session
    if entry.isBreakActive || entry.isSessionActive {
      return URL(string: "https://foqos.app")!
    }

    return entry.deepLinkURL ?? URL(string: "foqos://")!
  }

  var body: some View {
    ZStack {
      // Main content with dark background and rounded corners
      VStack(spacing: 0) {
        // Top section: Profile name with hourglass icon
        HStack(spacing: 8) {
          Image(systemName: "hourglass")
            .font(.system(size: 18, weight: .medium, design: .monospaced))
            .foregroundColor(.white)
          
          Text(entry.profileName ?? "No Profile")
            .font(.system(size: 20, weight: .bold, design: .monospaced))
            .foregroundColor(.white)
            .lineLimit(1)
        }
        .padding(.top, 16)
        
        Spacer()
        
        // Bottom section: Status message or timer
        VStack(spacing: 6) {
          if entry.isBreakActive {
            HStack(spacing: 4) {
              Image(systemName: "cup.and.saucer.fill")
                .font(.system(size: 16, weight: .medium, design: .monospaced))
                .foregroundColor(Color(red: 0.75, green: 0.75, blue: 0.75))
              Text("On a Break")
                .font(.system(size: 28, weight: .semibold, design: .monospaced))
                .foregroundColor(Color(red: 0.75, green: 0.75, blue: 0.75))
            }
          } else if entry.isSessionActive {
            if let startTime = entry.sessionStartTime {
              Text(
                Date(
                  timeIntervalSinceNow: startTime.timeIntervalSince1970
                    - Date().timeIntervalSince1970
                ),
                style: .timer
              )
              .font(.system(size: 28, weight: .semibold, design: .monospaced))
              .foregroundColor(Color(red: 0.75, green: 0.75, blue: 0.75))
            }
          } else {
            Link(destination: linkToOpen) {
              Text(quickLaunchEnabled ? "Tap to launch" : "Tap to open")
                .font(.system(size: 28, weight: .semibold, design: .monospaced))
                .foregroundColor(Color(red: 0.75, green: 0.75, blue: 0.75))
            }
          }
        }
        .padding(.bottom, 16)
      }
      .frame(width: 320, height: 100)
      .background(Color(red: 0.047, green: 0.047, blue: 0.047)) // #0C0C0C
      .cornerRadius(24)
      .shadow(color: .black.opacity(0.5), radius: 12, x: 0, y: 0)
      .blur(radius: isUnavailable ? 3 : 0)

      // Unavailable overlay
      if isUnavailable {
        VStack(spacing: 4) {
          Image(systemName: "exclamationmark.triangle.fill")
            .font(.system(size: 18, weight: .medium, design: .monospaced))
            .foregroundColor(.orange)

          Text("Unavailable")
            .font(.system(size: 20, weight: .bold, design: .monospaced))
            .foregroundColor(.white)

          Text("Different profile active")
            .font(.system(size: 16, weight: .medium, design: .monospaced))
            .foregroundColor(Color(red: 0.75, green: 0.75, blue: 0.75))
            .multilineTextAlignment(.center)
        }
        .frame(width: 320, height: 100)
        .background(Color(red: 0.047, green: 0.047, blue: 0.047).opacity(0.9))
        .cornerRadius(24)
      }
    }
  }

  // Helper function to count total blocked items
  private func getBlockedCount(from profile: SharedData.ProfileSnapshot) -> Int {
    let appCount =
      profile.selectedActivity.categories.count + profile.selectedActivity.applications.count
    let webDomainCount = profile.selectedActivity.webDomains.count
    let customDomainCount = profile.domains?.count ?? 0
    return appCount + webDomainCount + customDomainCount
  }

  // Helper function to count enabled options
  private func getEnabledOptionsCount(from profile: SharedData.ProfileSnapshot) -> Int {
    var count = 0
    if profile.enableLiveActivity { count += 1 }
    if profile.enableBreaks { count += 1 }
    if profile.enableStrictMode { count += 1 }
    if profile.enableAllowMode { count += 1 }
    if profile.enableAllowModeDomains { count += 1 }
    if profile.reminderTimeInSeconds != nil { count += 1 }
    if profile.physicalUnblockNFCTagId != nil { count += 1 }
    if profile.physicalUnblockQRCodeId != nil { count += 1 }
    if profile.schedule != nil { count += 1 }
    if profile.disableBackgroundStops == true { count += 1 }
    return count
  }
}

#Preview(as: .systemSmall) {
  ProfileControlWidget()
} timeline: {
  // Preview 1: No active session
  ProfileWidgetEntry(
    date: .now,
    selectedProfileId: "test-id",
    profileName: "Focus Session",
    activeSession: nil,
    profileSnapshot: SharedData.ProfileSnapshot(
      id: UUID(),
      name: "Focus Session",
      selectedActivity: {
        var selection = FamilyActivitySelection()
        // Simulate some selected apps and domains for preview
        return selection
      }(),
      createdAt: Date(),
      updatedAt: Date(),
      blockingStrategyId: nil,
      order: 0,
      enableLiveActivity: true,
      reminderTimeInSeconds: nil,
      customReminderMessage: nil,
      enableBreaks: true,
      enableStrictMode: true,
      enableAllowMode: true,
      enableAllowModeDomains: true,
      domains: ["facebook.com", "twitter.com", "instagram.com"],
      physicalUnblockNFCTagId: nil,
      physicalUnblockQRCodeId: nil,
      schedule: nil,
      disableBackgroundStops: nil
    ),
    deepLinkURL: URL(string: "https://foqos.app/profile/test-id"),
    focusMessage: "Stay focused and avoid distractions",
    useProfileURL: true
  )

  // Preview 2: Active session matching widget profile
  let activeProfileId = UUID()
  ProfileWidgetEntry(
    date: .now,
    selectedProfileId: activeProfileId.uuidString,
    profileName: "Deep Work Session",
    activeSession: SharedData.SessionSnapshot(
      id: "test-session",
      tag: "test-tag",
      blockedProfileId: activeProfileId,  // Matches selectedProfileId
      startTime: Date(timeIntervalSinceNow: -300),  // Started 5 minutes ago
      endTime: nil,
      breakStartTime: nil,  // No break active
      breakEndTime: nil,
      forceStarted: true
    ),
    profileSnapshot: SharedData.ProfileSnapshot(
      id: activeProfileId,
      name: "Deep Work Session",
      selectedActivity: FamilyActivitySelection(),
      createdAt: Date(),
      updatedAt: Date(),
      blockingStrategyId: nil,
      order: 0,
      enableLiveActivity: true,
      reminderTimeInSeconds: nil,
      customReminderMessage: nil,
      enableBreaks: true,
      enableStrictMode: false,
      enableAllowMode: true,
      enableAllowModeDomains: true,
      domains: ["youtube.com", "reddit.com"],
      physicalUnblockNFCTagId: nil,
      physicalUnblockQRCodeId: nil,
      schedule: nil,
      disableBackgroundStops: nil
    ),
    deepLinkURL: URL(string: "https://foqos.app/profile/\(activeProfileId.uuidString)"),
    focusMessage: "Deep focus time",
    useProfileURL: true
  )

  // Preview 3: Active session with break matching widget profile
  let breakProfileId = UUID()
  ProfileWidgetEntry(
    date: .now,
    selectedProfileId: breakProfileId.uuidString,
    profileName: "Study Session",
    activeSession: SharedData.SessionSnapshot(
      id: "test-session-break",
      tag: "test-tag-break",
      blockedProfileId: breakProfileId,  // Matches selectedProfileId
      startTime: Date(timeIntervalSinceNow: -600),  // Started 10 minutes ago
      endTime: nil,
      breakStartTime: Date(timeIntervalSinceNow: -60),  // Break started 1 minute ago
      breakEndTime: nil,
      forceStarted: true
    ),
    profileSnapshot: SharedData.ProfileSnapshot(
      id: breakProfileId,
      name: "Study Session",
      selectedActivity: FamilyActivitySelection(),
      createdAt: Date(),
      updatedAt: Date(),
      blockingStrategyId: nil,
      order: 0,
      enableLiveActivity: true,
      reminderTimeInSeconds: nil,
      customReminderMessage: nil,
      enableBreaks: true,
      enableStrictMode: true,
      enableAllowMode: false,
      enableAllowModeDomains: false,
      domains: ["tiktok.com", "instagram.com", "snapchat.com"],
      physicalUnblockNFCTagId: nil,
      physicalUnblockQRCodeId: nil,
      schedule: nil,
      disableBackgroundStops: nil
    ),
    deepLinkURL: URL(string: "https://foqos.app/profile/\(breakProfileId.uuidString)"),
    focusMessage: "Take a well-deserved break",
    useProfileURL: true
  )
  // Preview 4: No profile selected
  ProfileWidgetEntry(
    date: .now,
    selectedProfileId: nil,
    profileName: "No Profile Selected",
    activeSession: nil,
    profileSnapshot: nil,
    deepLinkURL: URL(string: "foqos://"),
    focusMessage: "Select a profile to get started",
    useProfileURL: false
  )

  // Preview 5: Unavailable state - different profile active
  let unavailableProfileId = UUID()
  let differentActiveProfileId = UUID()  // Different from unavailableProfileId
  ProfileWidgetEntry(
    date: .now,
    selectedProfileId: unavailableProfileId.uuidString,
    profileName: "Work Focus",
    activeSession: SharedData.SessionSnapshot(
      id: "different-session",
      tag: "different-tag",
      blockedProfileId: differentActiveProfileId,  // Different UUID than selectedProfileId
      startTime: Date(timeIntervalSinceNow: -180),  // Started 3 minutes ago
      endTime: nil,
      breakStartTime: nil,
      breakEndTime: nil,
      forceStarted: true
    ),
    profileSnapshot: SharedData.ProfileSnapshot(
      id: unavailableProfileId,
      name: "Work Focus",
      selectedActivity: FamilyActivitySelection(),
      createdAt: Date(),
      updatedAt: Date(),
      blockingStrategyId: nil,
      order: 0,
      enableLiveActivity: true,
      reminderTimeInSeconds: nil,
      customReminderMessage: nil,
      enableBreaks: true,
      enableStrictMode: true,
      enableAllowMode: false,
      enableAllowModeDomains: false,
      domains: ["linkedin.com", "slack.com"],
      physicalUnblockNFCTagId: nil,
      physicalUnblockQRCodeId: nil,
      schedule: nil,
      disableBackgroundStops: nil
    ),
    deepLinkURL: URL(string: "https://foqos.app/profile/\(unavailableProfileId.uuidString)"),
    focusMessage: "Different profile is currently active",
    useProfileURL: true
  )
}
