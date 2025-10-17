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
    
    // Profile to edit (nil for new profile)
    var profileToEdit: BlockedProfiles?
    
    @State private var name: String = ""
    @State private var enableLiveActivity: Bool = false
    @State private var enableReminder: Bool = false
    @State private var enableBreaks: Bool = false
    @State private var enableStrictMode: Bool = false
    @State private var reminderTimeInMinutes: Int = 15
    @State private var customReminderMessage: String
    @State private var enableAllowMode: Bool = false
    @State private var enableAllowModeDomains: Bool = false
    @State private var disableBackgroundStops: Bool = false
    @State private var domains: [String] = []
    
    
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
    
    
    // Alert for cloning
    @State private var showingClonePrompt = false
    @State private var cloneName: String = ""
    
    // Sheet for insights modal
    @State private var showingInsights = false
    
    @State private var selectedActivity = FamilyActivitySelection()
    @State private var selectedStrategy: BlockingStrategy? = nil
    
    
    init(profileToEdit: BlockedProfiles? = nil, onProfileCreated: ((BlockedProfiles) -> Void)? = nil) {
        self.profileToEdit = profileToEdit
        self.onProfileCreated = onProfileCreated
        _name = State(initialValue: profileToEdit?.name ?? "")
        _selectedActivity = State(
            initialValue: profileToEdit?.selectedActivity ?? FamilyActivitySelection()
        )
        _enableLiveActivity = State(
            initialValue: profileToEdit?.enableLiveActivity ?? true
        )
        _enableBreaks = State(
            initialValue: profileToEdit?.enableBreaks ?? false
        )
        _enableStrictMode = State(
            initialValue: profileToEdit?.enableStrictMode ?? false
        )
        _enableAllowMode = State(
            initialValue: profileToEdit?.enableAllowMode ?? false
        )
        _enableAllowModeDomains = State(
            initialValue: profileToEdit?.enableAllowModeDomains ?? false
        )
        _enableReminder = State(
            initialValue: profileToEdit?.reminderTimeInSeconds != nil
        )
        _disableBackgroundStops = State(
            initialValue: profileToEdit?.disableBackgroundStops ?? false
        )
        _reminderTimeInMinutes = State(
            initialValue: profileToEdit?.reminderTimeInSeconds != nil ? Int(profileToEdit!.reminderTimeInSeconds! / 60) : 5
        )
        _customReminderMessage = State(
            initialValue: profileToEdit?.customReminderMessage ?? ""
        )
        _domains = State(
            initialValue: profileToEdit?.domains ?? []
        )
        _schedule = State(
            initialValue: profileToEdit?.schedule ?? BlockedProfileSchedule(
                days: [],
                startHour: 9,
                startMinute: 0,
                endHour: 17,
                endMinute: 0,
                updatedAt: Date()
            )
        )
        
        _selectedStrategy = State(initialValue: ManualBlockingStrategy())
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header with NEW MODE title
                HStack {
                    Text(profileToEdit != nil ? "EDIT MODE" : "NEW MODE")
                        .font(.system(size: 32, weight: .bold, design: .monospaced))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .medium, design: .monospaced))
                            .foregroundColor(.primary)
                    }
                    .accessibilityLabel("Cancel")
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 30)
                
                // Content
                Form {
                    Section {
                        Text("NAME")
                            .font(.system(size: 12, weight: .regular, design: .monospaced))
                            .foregroundColor(.primary)
                            .padding(.horizontal, 20)
                        
                        TextField("Profile Name", text: $name)
                            .font(.system(size: 16, weight: .regular, design: .monospaced))
                            .textContentType(.none)
                            .onChange(of: name) { _, newValue in
                                if newValue.count > 25 {
                                    name = String(newValue.prefix(25))
                                }
                            }
                            .padding(.horizontal, 20)
                    }
                    
                    Section {
                        Text(enableAllowMode ? "ALLOWED" : "BLOCKED" + " APPS & WEBSITES")
                            .font(.system(size: 12, weight: .regular, design: .monospaced))
                            .foregroundColor(.primary)
                            .padding(.horizontal, 20)
                        
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
                    
                    Section {
                        Text(enableAllowModeDomains ? "ALLOWED" : "BLOCKED" + " DOMAINS")
                            .font(.system(size: 12, weight: .regular, design: .monospaced))
                            .foregroundColor(.primary)
                            .padding(.horizontal, 20)
                        
                        BlockedProfileDomainSelector(
                            domains: domains,
                            buttonAction: { showingDomainPicker = true },
                            allowMode: enableAllowModeDomains,
                            disabled: false
                        )
                        
                        CustomToggle(
                            title: "Domain Allow Mode",
                            description:
                                "Pick domains to allow and block everything else. This will erase any other selection you've made.",
                            isOn: $enableAllowModeDomains,
                            isDisabled: false
                        )
                    }
                    
                    Section {
                        Text("SCHEDULE")
                            .font(.system(size: 12, weight: .regular, design: .monospaced))
                            .foregroundColor(.primary)
                            .padding(.horizontal, 20)
                        
                        BlockedProfileScheduleSelector(
                            schedule: schedule,
                            buttonAction: { showingSchedulePicker = true },
                            disabled: false
                        )
                    }
                    
                    Section {
                        Text("SAFEGUARDS")
                            .font(.system(size: 12, weight: .regular, design: .monospaced))
                            .foregroundColor(.primary)
                            .padding(.horizontal, 20)
                        
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
                    
                    Section {
                        Text("NOTIFICATIONS")
                            .font(.system(size: 12, weight: .regular, design: .monospaced))
                            .foregroundColor(.primary)
                            .padding(.horizontal, 20)
                        
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
                                    .font(.system(size: 14, weight: .regular, design: .monospaced))
                                Spacer()
                                TextField(
                                    "",
                                    value: $reminderTimeInMinutes,
                                    format: .number
                                )
                                .font(.system(size: 14, weight: .regular, design: .monospaced))
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 50)
                                .disabled(false)
                                .foregroundColor(.secondary)
                                
                                Text("minutes")
                                    .font(.system(size: 14, weight: .regular, design: .monospaced))
                                    .foregroundColor(.secondary)
                            }.listRowSeparator(.visible)
                            VStack(alignment: .leading) {
                                Text("Reminder message")
                                    .font(.system(size: 14, weight: .regular, design: .monospaced))
                                TextField(
                                    "Reminder message",
                                    text: $customReminderMessage,
                                    prompt: Text(strategyManager.defaultReminderMessage(forProfile: nil)),
                                    axis: .vertical
                                )
                                .font(.system(size: 14, weight: .regular, design: .monospaced))
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
                                .font(.system(size: 12, weight: .regular, design: .monospaced))
                        }
                    }
                    
                    // Bottom buttons
                    VStack(spacing: 12) {
                        // Black SAVE MODE Button
                        Button(action: { saveProfile() }) {
                            Text(profileToEdit != nil ? "UPDATE MODE" : "SAVE MODE")
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
                        .disabled(name.isEmpty)
                        
                        // Gray CANCEL Button
                        Button(action: { dismiss() }) {
                            Text("CANCEL")
                                .font(.system(size: 16, weight: .regular, design: .monospaced))
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color(.systemGray6))
                                )
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 8)
                    }
                    
                    // Small message at the bottom
                    Text("Enter mode name and configure settings")
                        .font(.system(size: 10, weight: .regular, design: .monospaced))
                        .foregroundColor(.secondary)
                        .padding(.bottom, 20)
                }
                .background(Color.white)
                .preferredColorScheme(.light)
                .onChange(of: enableAllowMode) {
                    _,
                    newValue in
                    selectedActivity = FamilyActivitySelection(
                        includeEntireCategory: newValue
                    )
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
                        allowMode: enableAllowModeDomains
                    )
                }
                .sheet(isPresented: $showingSchedulePicker) {
                    SchedulePicker(
                        schedule: $schedule,
                        isPresented: $showingSchedulePicker
                    )
                }
                .alert("Error", isPresented: $showError) {
                    Button("OK") {}
                } message: {
                    Text(errorMessage ?? "An unknown error occurred")
                }
             }
         }
     }
     
     func showError(message: String) {
         errorMessage = message
         showError = true
     }
     
    func saveProfile() {
        // Check for duplicate names (only for new profiles or when name changed)
        if profileToEdit == nil || profileToEdit?.name.lowercased() != name.lowercased() {
            let existingProfiles = try? modelContext.fetch(FetchDescriptor<BlockedProfiles>())
            if let profiles = existingProfiles {
                let duplicateName = profiles.contains { $0.name.lowercased() == name.lowercased() }
                if duplicateName {
                    showError(message: "A mode with this name already exists. Please choose a different name.")
                    return
                }
            }
        }
        
        do {
            // Update schedule date
            schedule.updatedAt = Date()
            
            // Calculate reminder time in seconds or nil if disabled
            let reminderTimeSeconds: UInt32? =
                enableReminder ? UInt32(reminderTimeInMinutes * 60) : nil
            
            if let existingProfile = profileToEdit {
                // Update existing profile
                existingProfile.name = name
                existingProfile.selectedActivity = selectedActivity
                existingProfile.enableLiveActivity = enableLiveActivity
                existingProfile.reminderTimeInSeconds = reminderTimeSeconds
                existingProfile.customReminderMessage = customReminderMessage.isEmpty ? nil : customReminderMessage
                existingProfile.enableBreaks = enableBreaks
                existingProfile.enableStrictMode = enableStrictMode
                existingProfile.enableAllowMode = enableAllowMode
                existingProfile.enableAllowModeDomains = enableAllowModeDomains
                existingProfile.domains = domains
                existingProfile.schedule = schedule
                existingProfile.disableBackgroundStops = disableBackgroundStops
                
                // Schedule restrictions
                DeviceActivityCenterUtil.scheduleRestrictions(for: existingProfile)
                
                // Call the callback to notify that the profile was updated
                onProfileCreated?(existingProfile)
            } else {
                // Create new profile
                let newProfile = try BlockedProfiles.createProfile(
                    in: modelContext,
                    name: name,
                    selection: selectedActivity,
                    blockingStrategyId: ManualBlockingStrategy.id,
                    enableLiveActivity: enableLiveActivity,
                    reminderTimeInSeconds: reminderTimeSeconds,
                    customReminderMessage: customReminderMessage,
                    enableBreaks: enableBreaks,
                    enableStrictMode: enableStrictMode,
                    enableAllowMode: enableAllowMode,
                    enableAllowModeDomains: enableAllowModeDomains,
                    domains: domains,
                    physicalUnblockNFCTagId: nil,
                    physicalUnblockQRCodeId: nil,
                    schedule: schedule,
                    disableBackgroundStops: disableBackgroundStops
                )
                
                // Schedule restrictions
                DeviceActivityCenterUtil.scheduleRestrictions(for: newProfile)
                
                // Call the callback to notify that a new profile was created
                onProfileCreated?(newProfile)
            }
            
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
            .preferredColorScheme(.light)
    }
