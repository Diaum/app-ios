import FamilyControls
import Foundation
import SwiftData
import SwiftUI

struct NewModeModal: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject private var nfcWriter: NFCWriter
    @EnvironmentObject private var strategyManager: StrategyManager
    
    var onProfileCreated: ((BlockedProfiles) -> Void)?
    var profileToEdit: BlockedProfiles?
    
    @State private var name: String = ""
    @State private var enableLiveActivity = false
    @State private var enableReminder = false
    @State private var enableBreaks = false
    @State private var enableStrictMode = false
    @State private var reminderTimeInMinutes = 15
    @State private var customReminderMessage = ""
    @State private var enableAllowMode = false
    @State private var enableAllowModeDomains = false
    @State private var disableBackgroundStops = false
    @State private var domains: [String] = []
    @State private var schedule: BlockedProfileSchedule
    @State private var selectedActivity = FamilyActivitySelection()
    @State private var selectedStrategy: BlockingStrategy? = ManualBlockingStrategy()
    
    @State private var showingActivityPicker = false
    @State private var showingDomainPicker = false
    @State private var showingSchedulePicker = false
    
    @State private var errorMessage: String?
    @State private var showError = false
    
    init(profileToEdit: BlockedProfiles? = nil, onProfileCreated: ((BlockedProfiles) -> Void)? = nil) {
        self.profileToEdit = profileToEdit
        self.onProfileCreated = onProfileCreated
        _name = State(initialValue: profileToEdit?.name ?? "")
        _enableLiveActivity = State(initialValue: profileToEdit?.enableLiveActivity ?? true)
        _enableBreaks = State(initialValue: profileToEdit?.enableBreaks ?? false)
        _enableStrictMode = State(initialValue: profileToEdit?.enableStrictMode ?? false)
        _enableAllowMode = State(initialValue: profileToEdit?.enableAllowMode ?? false)
        _enableAllowModeDomains = State(initialValue: profileToEdit?.enableAllowModeDomains ?? false)
        _enableReminder = State(initialValue: profileToEdit?.reminderTimeInSeconds != nil)
        _disableBackgroundStops = State(initialValue: profileToEdit?.disableBackgroundStops ?? false)
        _reminderTimeInMinutes = State(initialValue: profileToEdit?.reminderTimeInSeconds != nil ? Int(profileToEdit!.reminderTimeInSeconds! / 60) : 5)
        _customReminderMessage = State(initialValue: profileToEdit?.customReminderMessage ?? "")
        _domains = State(initialValue: profileToEdit?.domains ?? [])
        _schedule = State(initialValue: profileToEdit?.schedule ?? BlockedProfileSchedule(days: [], startHour: 9, startMinute: 0, endHour: 17, endMinute: 0, updatedAt: Date()))
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                
                // Header
                HStack {
                    Text(profileToEdit != nil ? "EDIT MODE" : "NEW MODE")
                        .font(.system(size: 26, weight: .bold, design: .monospaced))
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .medium, design: .monospaced))
                            .foregroundColor(.black)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 10)
                
                Divider().background(Color.black)
                
                // Scrollable content
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        
                        // NAME
                        section(title: "NAME", stepNumber: 1) {
                            TextField("Profile Name", text: $name)
                                .font(.system(size: 14, weight: .regular, design: .monospaced))
                                .padding(10)
                                .background(Color.white)
                                .overlay(Rectangle().stroke(Color.black, lineWidth: 1))
                        }
                        
                        // BLOCKED APPS
                        section(title: (enableAllowMode ? "ALLOWED" : "BLOCKED") + " APPS & WEBSITES", stepNumber: 2) {
                            BlockedProfileAppSelector(
                                selection: selectedActivity,
                                buttonAction: { showingActivityPicker = true },
                                allowMode: enableAllowMode,
                                disabled: false
                            )
                            
                            CustomToggle(
                                title: "Apps Allow Mode",
                                description: "Pick apps or websites to allow and block everything else. This will erase any other selection you've made.",
                                isOn: $enableAllowMode,
                                isDisabled: false
                            )
                        }
                        
                        // DOMAINS
                        section(title: (enableAllowModeDomains ? "ALLOWED" : "BLOCKED") + " DOMAINS", stepNumber: 3) {
                            BlockedProfileDomainSelector(
                                domains: domains,
                                buttonAction: { showingDomainPicker = true },
                                allowMode: enableAllowModeDomains,
                                disabled: false
                            )
                            
                            CustomToggle(
                                title: "Domain Allow Mode",
                                description: "Pick domains to allow and block everything else. This will erase any other selection you've made.",
                                isOn: $enableAllowModeDomains,
                                isDisabled: false
                            )
                        }
                        
                        // SCHEDULE
                        section(title: "SCHEDULE", stepNumber: 4) {
                            BlockedProfileScheduleSelector(
                                schedule: schedule,
                                buttonAction: { showingSchedulePicker = true },
                                disabled: false
                            )
                        }
                        
                        // SAFEGUARDS
                        section(title: "SAFEGUARDS", stepNumber: 5) {
                            CustomToggle(title: "Breaks",
                                         description: "Have the option to take a single break, you choose when to start/stop the break",
                                         isOn: $enableBreaks, isDisabled: false)
                            
                            CustomToggle(title: "Strict",
                                         description: "Block deleting apps from your phone, stops you from deleting Diaum to access apps",
                                         isOn: $enableStrictMode, isDisabled: false)
                            
                            CustomToggle(title: "Disable Background Stops",
                                         description: "Disable the ability to stop a profile from the background, this includes shortcuts and scanning links from NFC tags or QR codes.",
                                         isOn: $disableBackgroundStops, isDisabled: false)
                        }
                        
                        // NOTIFICATIONS
                        section(title: "NOTIFICATIONS", stepNumber: 6) {
                            CustomToggle(title: "Live Activity",
                                         description: "Shows a live activity on your lock screen with some inspirational quote",
                                         isOn: $enableLiveActivity, isDisabled: false)
                            
                            CustomToggle(title: "Reminder",
                                         description: "Sends a reminder to start this profile when it ends",
                                         isOn: $enableReminder, isDisabled: false)
                            
                            if enableReminder {
                                HStack {
                                    Text("Reminder time")
                                        .font(.system(size: 14, weight: .regular, design: .monospaced))
                                    Spacer()
                                    TextField("", value: $reminderTimeInMinutes, format: .number)
                                        .font(.system(size: 14, weight: .regular, design: .monospaced))
                                        .multilineTextAlignment(.trailing)
                                        .frame(width: 50)
                                        .overlay(Rectangle().stroke(Color.black, lineWidth: 1))
                                    Text("minutes")
                                        .font(.system(size: 14, weight: .regular, design: .monospaced))
                                }
                            }
                        }
                        
                        // SAVE / CANCEL BUTTONS
                        VStack(spacing: 12) {
                            Button(action: saveProfile) {
                                Text(profileToEdit != nil ? "UPDATE MODE" : "SAVE MODE")
                                    .font(.system(size: 14, weight: .regular, design: .monospaced))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(Color.black)
                                    .cornerRadius(8)
                            }
                            .disabled(name.isEmpty)
                            
                            Button(action: { dismiss() }) {
                                Text("CANCEL")
                                    .font(.system(size: 14, weight: .regular, design: .monospaced))
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .overlay(Rectangle().stroke(Color.black, lineWidth: 1))
                                    .background(Color.white)
                                    .cornerRadius(8)
                            }
                        }
                        
                        Text("Enter mode name and configure settings")
                            .font(.system(size: 14, weight: .regular, design: .monospaced))
                            .foregroundColor(Color.gray.opacity(0.6))
                            .padding(.top, 8)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 24)
                }
            }
            .background(Color.white)
            .preferredColorScheme(.light)
            .onChange(of: enableAllowMode) { _, newValue in
                selectedActivity = FamilyActivitySelection(includeEntireCategory: newValue)
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
    
     @ViewBuilder
     func section<Content: View>(title: String, stepNumber: Int, @ViewBuilder content: () -> Content) -> some View {
         ZStack(alignment: .topLeading) {
             VStack(alignment: .leading, spacing: 8) {
                 Text(title)
                     .font(.system(size: 14, weight: .regular, design: .monospaced))
                     .foregroundColor(.black)
                 content()
             }
             .padding()
             .overlay(Rectangle().stroke(Color.black, lineWidth: 1))
             
             // Step indicator circle
             HStack(spacing: 0) {
                 Circle()
                     .fill(Color.black)
                     .frame(width: 24, height: 24)
                     .overlay(
                         Text("\(stepNumber)")
                             .font(.system(size: 14, weight: .bold, design: .monospaced))
                             .foregroundColor(.white)
                     )
                 
                 Rectangle()
                     .fill(Color.black)
                     .frame(width: 1, height: 12)
             }
             .offset(x: -12, y: -12)
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

 #Preview {
     NewModeModal()
         .environmentObject(NFCWriter())
         .environmentObject(StrategyManager())
         .modelContainer(for: BlockedProfiles.self, inMemory: true)
         .preferredColorScheme(.light)
 }
