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
    return createFoccoShieldConfiguration(
      for: .app, title: application.localizedDisplayName ?? "App")
  }

  override func configuration(shielding application: Application, in category: ActivityCategory)
    -> ShieldConfiguration
  {
    return createFoccoShieldConfiguration(
      for: .app, title: application.localizedDisplayName ?? "App")
  }

  override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
    return createFoccoShieldConfiguration(for: .website, title: webDomain.domain ?? "Website")
  }

  override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory)
    -> ShieldConfiguration
  {
    return createFoccoShieldConfiguration(for: .website, title: webDomain.domain ?? "Website")
  }

  private func createFoccoShieldConfiguration(for type: BlockedContentType, title: String)
    -> ShieldConfiguration
  {
    // FOCCO theme colors - dark theme with specific hex colors
    let backgroundColor = UIColor(red: 0x11/255.0, green: 0x11/255.0, blue: 0x11/255.0, alpha: 1.0) // #111111
    let textColor = UIColor.white
    let buttonColor = UIColor(red: 0x1a/255.0, green: 0x1a/255.0, blue: 0x1a/255.0, alpha: 1.0) // #1a1a1a

    // Create FOCCO icon - using a custom drawn icon that represents the FOCCO concept
    let foccoIcon = createFoccoIcon()

    return ShieldConfiguration(
      backgroundBlurStyle: nil,
      backgroundColor: backgroundColor,
      icon: foccoIcon,
      title: ShieldConfiguration.Label(
        text: "FOCCO",
        color: textColor
      ),
      subtitle: ShieldConfiguration.Label(
        text: "TAP TO UNFOCCO",
        color: textColor
      ),
      primaryButtonLabel: ShieldConfiguration.Label(
        text: "FOCCO",
        color: textColor
      ),
      primaryButtonBackgroundColor: buttonColor,
      secondaryButtonLabel: ShieldConfiguration.Label(
        text: "YOU'VE BEEN FOCCUSED FOR 00:05",
        color: textColor
      )
    )
  }

  private func createFoccoIcon() -> UIImage? {
    // Create a custom FOCCO icon that represents the concept
    // Using a square with rounded corners to represent the "FOCCO" button
    let size = CGSize(width: 120, height: 120)
    let renderer = UIGraphicsImageRenderer(size: size)
    
    return renderer.image { context in
      let cgContext = context.cgContext
      
      // Set the background to transparent
      cgContext.clear(CGRect(origin: .zero, size: size))
      
      // Create the rounded rectangle for the FOCCO button
      let rect = CGRect(x: 20, y: 20, width: 80, height: 80)
      let path = UIBezierPath(roundedRect: rect, cornerRadius: 16)
      
      // Fill with #1a1a1a color
      UIColor(red: 0x1a/255.0, green: 0x1a/255.0, blue: 0x1a/255.0, alpha: 1.0).setFill()
      path.fill()
      
      // Add inner shadow effect (simulated with darker border)
      UIColor.black.withAlphaComponent(0.3).setStroke()
      path.lineWidth = 2
      path.stroke()
      
      // Add outer shadow effect (simulated with lighter border)
      let outerPath = UIBezierPath(roundedRect: rect.insetBy(dx: -2, dy: -2), cornerRadius: 18)
      UIColor.white.withAlphaComponent(0.1).setStroke()
      outerPath.lineWidth = 1
      outerPath.stroke()
      
      // Add "FOCCO" text in the center
      let text = "FOCCO"
      let font = UIFont(name: "Courier New", size: 16) ?? UIFont.monospacedSystemFont(ofSize: 16, weight: .regular)
      let attributes: [NSAttributedString.Key: Any] = [
        .font: font,
        .foregroundColor: UIColor.white
      ]
      
      let textSize = text.size(withAttributes: attributes)
      let textRect = CGRect(
        x: rect.midX - textSize.width / 2,
        y: rect.midY - textSize.height / 2,
        width: textSize.width,
        height: textSize.height
      )
      
      text.draw(in: textRect, withAttributes: attributes)
    }
  }
}

enum BlockedContentType {
  case app
  case website
}
