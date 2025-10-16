//
//  ShieldConfigurationExtension.swift
//  DiaumShieldConfig
//
//  Created by Ali Waseem on 2025-08-11.
//

import ManagedSettings
import ManagedSettingsUI
import UIKit

// Override the functions below to customize the shields used in various situations.
// The system provides a default appearance for any methods that your subclass doesn't override.
// Make sure that your class name matches the NSExtensionPrincipalClass in your Info.plist.
class ShieldConfigurationExtension: ShieldConfigurationDataSource {
  override func configuration(shielding application: Application) -> ShieldConfiguration {
    return createCustomShieldConfiguration(
      for: .app, title: application.localizedDisplayName ?? "App")
  }

  override func configuration(shielding application: Application, in category: ActivityCategory)
    -> ShieldConfiguration
  {
    return createCustomShieldConfiguration(
      for: .app, title: application.localizedDisplayName ?? "App")
  }

  override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
    return createCustomShieldConfiguration(for: .website, title: webDomain.domain ?? "Website")
  }

  override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory)
    -> ShieldConfiguration
  {
    return createCustomShieldConfiguration(for: .website, title: webDomain.domain ?? "Website")
  }

  private func createCustomShieldConfiguration(for type: BlockedContentType, title: String)
    -> ShieldConfiguration
  {
    // Dark theme colors to match the brick concept
    let backgroundColor = UIColor.black
    let textColor = UIColor.white
    let buttonColor = UIColor.systemGray2

    // Create BRICK icon using SF Symbols
    let brickIcon = createBrickIcon()

    // Get brick-style message
    let brickMessage = getBrickMessage(for: type, title: title)

    return ShieldConfiguration(
      backgroundBlurStyle: nil,
      backgroundColor: backgroundColor,
      icon: brickIcon,
      title: ShieldConfiguration.Label(
        text: brickMessage.title,
        color: textColor
      ),
      subtitle: ShieldConfiguration.Label(
        text: brickMessage.subtitle,
        color: textColor
      ),
      primaryButtonLabel: ShieldConfiguration.Label(
        text: brickMessage.buttonText,
        color: textColor
      ),
      primaryButtonBackgroundColor: buttonColor,
      secondaryButtonLabel: nil
    )
  }

  private func createBrickIcon() -> UIImage? {
    // Create a custom BRICK icon using SF Symbols
    // Using square as it represents the "brick" concept well
    let icon = UIImage(systemName: "square")?.withTintColor(
      UIColor.white, renderingMode: .alwaysOriginal)
    return icon
  }

  private func getBrickMessage(for type: BlockedContentType, title: String) -> (
    title: String, subtitle: String, buttonText: String
  ) {
    let messages = [
      (
        title: "THIS IS A DISTRACTION",
        subtitle: "Your phone is currently Bricked. To access \(title) tap your Brick.",
        buttonText: "OK"
      ),
      (
        title: "BRICKED",
        subtitle: "This app is temporarily blocked. Focus on what matters.",
        buttonText: "OK"
      ),
      (
        title: "DISTRACTION BLOCKED",
        subtitle: "Your phone is Bricked. Stay focused on your goals.",
        buttonText: "OK"
      ),
      (
        title: "FOCUS MODE ACTIVE",
        subtitle: "This app is Bricked. Your attention is protected.",
        buttonText: "OK"
      ),
      (
        title: "BRICK WALL",
        subtitle: "This distraction has been Bricked. Keep going.",
        buttonText: "OK"
      )
    ]
    
    return messages.randomElement() ?? messages[0]
  }

  private func getFunBlockMessage(for type: BlockedContentType, title: String) -> (
    title: String, subtitle: String, buttonText: String
  ) {
    let messages = [
      (
        title: "Quick pause",
        subtitle:
          "Let \(title) wait a minute — your attention is doing real work.",
        buttonText: "Back to it"
      ),
      (
        title: "Small win",
        subtitle:
          "You almost opened \(title). You also chose focus. Nice trade.",
        buttonText: "Keep going"
      ),
      (
        title: "Back on track",
        subtitle:
          "The fastest way to finish is to stay here a little longer.",
        buttonText: "Stay focused"
      ),
      (
        title: "Good call",
        subtitle:
          "\(title) will still be there. This moment won’t.",
        buttonText: "Carry on"
      ),
      (
        title: "Stay in stride",
        subtitle:
          "Tiny distractions add up. So do tiny decisions like this one.",
        buttonText: "Onward"
      ),
      (
        title: "Momentum matters",
        subtitle:
          "A few more minutes beats a few more scrolls.",
        buttonText: "Back to it"
      ),
      (
        title: "Nice restraint",
        subtitle:
          "Curiosity noted. Priorities kept.",
        buttonText: "Resume"
      ),
      (
        title: "Almost there",
        subtitle:
          "Finish the next step, then check \(title) guilt‑free.",
        buttonText: "One more step"
      ),
      (
        title: "Focus pays",
        subtitle:
          "This is the quiet part that makes the loud results.",
        buttonText: "Keep at it"
      ),
      (
        title: "Light nudge",
        subtitle:
          "Take a breath. Reopen the task. You’ll thank yourself later.",
        buttonText: "Return"
      ),
      (
        title: "Streak builder",
        subtitle:
          "Choosing not to open \(title) just kept your streak alive.",
        buttonText: "Stay the course"
      ),
      (
        title: "Clear choice",
        subtitle:
          "If everything is urgent, nothing is. This is not.",
        buttonText: "Not now"
      ),
    ]

    return messages.randomElement() ?? messages[0]
  }
}

enum BlockedContentType {
  case app
  case website
}
