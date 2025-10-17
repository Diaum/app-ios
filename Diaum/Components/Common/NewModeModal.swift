import FamilyControls
import Foundation
import SwiftData
import SwiftUI

struct NewModeModal: View {
  @Environment(\.modelContext) private var modelContext
  @Environment(\.dismiss) private var dismiss

  @EnvironmentObject private var nfcWriter: NFCWriter
  @EnvironmentObject private var strategyManager: StrategyManager

  // Callback to notify when a new profile is created and should be activated
  var onProfileCreated: ((BlockedProfiles) -> Void)?

  @State private var name: String = ""
  @State private var enableLiveActivity: Bool = false
  @State private var enableReminder: Bool = false
  @State private var enableBreaks: Bool = false
  @State private var enableStrictMode: Bool = false
  @State private var reminderTimeInMinutes: Int = 15
  @State private var customReminderMessage: String
  @State private var enableAllowMode: Bool = false
  @State private var enableAllowModeDomain: Bool = false
  @State private var disableBackgroundStops: Bool = false
  @State private var domains: [String] = []

  @State private var physicalUnblockNFCTagId: String?
  @State private var physicalUnblockQRCodeId: String?

  @State private var schedule: BlockedProfileSchedule

  // QR code generator
  @State private var showingGeneratedQRCode = false

  // Sheet for activity picker
  @State private var showingActivityPicker = false

  // Sheet for domain picker
  @State private var showingDomainPicker = false

  // Sheet for schedule picker
  @State private var showingSchedulePicker = false

  // Error states
  @State private var errorMessage: String?
  @State private var showError = false

  // Sheet for physical unblock
  @State private var showingPhysicalUnblockView = false

  // Alert for cloning
  @State private var showingClonePrompt = false
  @State private var cloneName: String = ""

  // Sheet for insights modal
  @State private var showingInsights = false

  @State private var selectedActivity = FamilyActivitySelection()
  @State private var selectedStrategy: BlockingStrategy? = nil

  private let physicalReader: PhysicalReader = PhysicalReader()

  init(onProfileCreated: ((BlockedProfiles) -> Void)? = nil) {
    self.onProfileCreated = onProfileCreated
    _name = State(initialValue: "")
    _selectedActivity = State(
      initialValue: FamilyActivitySelection()
    )
    _enableLiveActivity = State(
      initialValue: true
    )
    _enableBreaks = State(
      initialValue: false
    )
    _enableStrictMode = State(
      initialValue: false
    )
    _enableAllowMode = State(
      initialValue: false
    )
    _enableAllowModeDomain = State(
      initialValue: false
    )
    _enableReminder = State(
      initialValue: true
    )
    _disableBackgroundStops = State(
      initialValue: false
    )
    _reminderTimeInMinutes = State(
      initialValue: 5
    )
    _customReminderMessage = State(
      initialValue: ""
    )
    _domains = State(
      initialValue: []
    )
    _physicalUnblockNFCTagId = State(
      initialValue: nil
    )
    _physicalUnblockQRCodeId = State(
      initialValue: nil
    )
    _schedule = State(
      initialValue: BlockedProfileSchedule(
        days: [],
        startHour: 9,
        startMinute: 0,
        endHour: 17,
        endMinute: 0,
        updatedAt: Date()
      )
    )

    _selectedStrategy = State(initialValue: NFCBlockingStrategy())
  }

  var body: some View {
    NavigationStack {
      Form {
        Section("Name") {
          TextField("Profile Name", text: $name)
            .textContentType(.none)
            .onChange(of: name) { _, newValue in
              if newValue.count > 25 {
                name = String(newValue.prefix(25))
              }
            }
        }

        Section(enableAllowMode ? "Allowed" : "Blocked" + " Apps & Websites") {
          BlockedProfileAppSelector(
            selection: selectedActivity,
            buttonAction: { showingActivityPicker = true },
            allowMode: enableAllowMode,
            disabled: false
          )

          CustomToggle(
            title: "Apps Allow Mode",
            description:
              "Pick apps or websites to allow and block everything else. This will erase any other selection you've made.",
            isOn: $enableAllowMode,
            isDisabled: false
          )
        }

        Section(enableAllowModeDomain ? "Allowed" : "Blocked" + " Domains") {
          BlockedProfileDomainSelector(
            domains: domains,
            buttonAction: { showingDomainPicker = true },
            allowMode: enableAllowModeDomain,
            disabled: false
          )

          CustomToggle(
            title: "Domain Allow Mode",
            description:
              "Pick domains to allow and block everything else. This will erase any other selection you've made.",
            isOn: $enableAllowModeDomain,
            disabled: false
          )
        }

        BlockingStrategyList(
          strategies: StrategyManager.availableStrategies,
          selectedStrategy: $selectedStrategy,
          disabled: false
        )

        Section("Schedule") {
          BlockedProfileScheduleSelector(
            schedule: schedule,
            buttonAction: { showingSchedulePicker = true },
            disabled: false
          )
        }

        Section("Safeguards") {
          CustomToggle(
            title: "Breaks",
            description:
              "Have the option to take a single break, you choose when to start/stop the break",
            isOn: $enableBreaks,
            isDisabled: false
          )

          CustomToggle(
            title: "Strict",
            description:
              "Block deleting apps from your phone, stops you from deleting Diaum to access apps",
            isOn: $enableStrictMode,
            isDisabled: false
          )

          CustomToggle(
            title: "Disable Background Stops",
            description:
              "Disable the ability to stop a profile from the background, this includes shortcuts and scanning links from NFC tags or QR codes.",
            isOn: $disableBackgroundStops,
            isDisabled: false
          )
        }

        Section("Strict Unlocks") {
          BlockedProfilePhysicalUnblockSelector(
            nfcTagId: physicalUnblockNFCTagId,
            qrCodeId: physicalUnblockQRCodeId,
            disabled: false,
            onSetNFC: {
              physicalReader.readNFCTag(
                onSuccess: { physicalUnblockNFCTagId = $0 },
              )
            },
            onSetQRCode: {
              showingPhysicalUnblockView = true
            },
            onUnsetNFC: { physicalUnblockNFCTagId = nil },
            onUnsetQRCode: { physicalUnblockQRCodeId = nil }
          )
        }

        Section("Notifications") {
          CustomToggle(
            title: "Live Activity",
            description:
              "Shows a live activity on your lock screen with some inspirational quote",
            isOn: $enableLiveActivity,
            isDisabled: false
          )

          CustomToggle(
            title: "Reminder",
            description:
              "Sends a reminder to start this profile when its ended",
            isOn: $enableReminder,
            isDisabled: false
          )
          if enableReminder {
            HStack {
              Text("Reminder time")
              Spacer()
              TextField(
                "",
                value: $reminderTimeInMinutes,
                format: .number
              )
              .keyboardType(.numberPad)
              .multilineTextAlignment(.trailing)
              .frame(width: 50)
              .disabled(false)
              .font(.subheadline)
              .foregroundColor(.secondary)

              Text("minutes")
                .font(.subheadline)
                .foregroundColor(.secondary)
            }.listRowSeparator(.visible)
            VStack(alignment: .leading) {
              Text("Reminder message")
              TextField(
                "Reminder message",
                text: $customReminderMessage,
                prompt: Text(strategyManager.defaultReminderMessage(forProfile: nil)),
                axis: .vertical
              )
              .foregroundColor(.secondary)
              .lineLimit(...3)
              .onChange(of: customReminderMessage) { _, newValue in
                if newValue.count > 178 {
                  customReminderMessage = String(newValue.prefix(178))
                }
              }
              .disabled(false)
            }
          }

          Button {
            if let url = URL(
              string: UIApplication.openSettingsURLString
            ) {
              UIApplication.shared.open(url)
            }
          } label: {
            Text("Go to settings to disable globally")
              .font(.caption)
          }
        }

      }
      .onChange(of: enableAllowMode) {
        _,
        newValue in
        selectedActivity = FamilyActivitySelection(
          includeEntireCategory: newValue
        )
      }
      .navigationTitle("New Mode")
      .toolbar {
        ToolbarItem(placement: .topBarLeading) {
          Button(action: { dismiss() }) {
            Image(systemName: "xmark")
          }
          .accessibilityLabel("Cancel")
        }

        ToolbarItem(placement: .topBarTrailing) {
          Button(action: { saveProfile() }) {
            Image(systemName: "checkmark")
          }
          .disabled(name.isEmpty)
          .accessibilityLabel("Create")
        }
      }
      .sheet(isPresented: $showingActivityPicker) {
        AppPicker(
          selection: $selectedActivity,
          isPresented: $showingActivityPicker,
          allowMode: enableAllowMode
        )
      }
      .sheet(isPresented: $showingDomainPicker) {
        DomainPicker(
          domains: $domains,
          isPresented: $showingDomainPicker,
          allowMode: enableAllowModeDomain
        )
      }
      .sheet(isPresented: $showingSchedulePicker) {
        SchedulePicker(
          schedule: $schedule,
          isPresented: $showingSchedulePicker
        )
      }
      .sheet(isPresented: $showingPhysicalUnblockView) {
        BlockingStrategyActionView(
          customView: physicalReader.readQRCode(
            onSuccess: {
              showingPhysicalUnblockView = false
              physicalUnblockQRCodeId = $0
            },
            onFailure: { _ in
              showingPhysicalUnblockView = false
              showError(
                message: "Failed to read QR code, please try again or use a different QR code."
              )
            }
          )
        )
      }
      .alert("Error", isPresented: $showError) {
        Button("OK") {}
      } message: {
        Text(errorMessage ?? "An unknown error occurred")
      }
    }
  }

  private func showError(message: String) {
    errorMessage = message
    showError = true
  }

  private func saveProfile() {
    do {
      // Update schedule date
      schedule.updatedAt = Date()

      // Calculate reminder time in seconds or nil if disabled
      let reminderTimeSeconds: UInt32? =
        enableReminder ? UInt32(reminderTimeInMinutes * 60) : nil

      let newProfile = try BlockedProfiles.createProfile(
        in: modelContext,
        name: name,
        selection: selectedActivity,
        blockingStrategyId: selectedStrategy?
          .getIdentifier() ?? NFCBlockingStrategy.id,
        enableLiveActivity: enableLiveActivity,
        reminderTimeInSeconds: reminderTimeSeconds,
        customReminderMessage: customReminderMessage,
        enableBreaks: enableBreaks,
        enableStrictMode: enableStrictMode,
        enableAllowMode: enableAllowMode,
        enableAllowModeDomains: enableAllowModeDomain,
        domains: domains,
        physicalUnblockNFCTagId: physicalUnblockNFCTagId,
        physicalUnblockQRCodeId: physicalUnblockQRCodeId,
        schedule: schedule,
        disableBackgroundStops: disableBackgroundStops
      )

      // Schedule restrictions
      DeviceActivityCenterUtil.scheduleRestrictions(for: newProfile)
      
      // Call the callback to notify that a new profile was created
      onProfileCreated?(newProfile)

      dismiss()
    } catch {
      errorMessage = error.localizedDescription
      showError = true
    }
  }
}

// Preview provider for SwiftUI previews
#Preview {
  NewModeModal()
    .environmentObject(NFCWriter())
    .environmentObject(StrategyManager())
    .modelContainer(for: BlockedProfiles.self, inMemory: true)
}
