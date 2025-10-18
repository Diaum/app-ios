import FamilyControls
import SwiftUI

struct BlockedProfileAppSelector: View {
  var selection: FamilyActivitySelection
  var buttonAction: () -> Void
  var allowMode: Bool = false
  var disabled: Bool = false
  var disabledText: String?

  private var title: String {
    return allowMode ? "Allowed" : "Blocked"
  }

  private var catAndAppCount: Int {
    return FamilyActivityUtil.countSelectedActivities(selection, allowMode: allowMode)
  }

  private var countDisplayText: String {
    return FamilyActivityUtil.getCountDisplayText(selection, allowMode: allowMode)
  }

  private var shouldShowWarning: Bool {
    return FamilyActivityUtil.shouldShowAllowModeWarning(selection, allowMode: allowMode)
  }

  private var buttonText: String {
    return allowMode
      ? "Select apps & websites to allow"
      : "Select apps & websites to restrict"
  }

  var body: some View {
    VStack(spacing: 12) {
      // Main button with improved styling
      Button(action: buttonAction) {
        HStack(spacing: 12) {
          // Icon
          Image(systemName: catAndAppCount > 0 ? "checkmark.circle.fill" : "plus.circle")
            .font(.system(size: 20, weight: .medium))
            .foregroundColor(catAndAppCount > 0 ? .green : .blue)
          
          VStack(alignment: .leading, spacing: 2) {
            Text(buttonText)
              .font(.system(size: 16, weight: .medium, design: .monospaced))
              .foregroundColor(.primary)
            
            if catAndAppCount > 0 {
              Text("\(countDisplayText) selected")
                .font(.system(size: 12, weight: .regular, design: .monospaced))
                .foregroundColor(.secondary)
            }
          }
          
          Spacer()
          
          // Arrow icon
          Image(systemName: "chevron.right")
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
          RoundedRectangle(cornerRadius: 12)
            .fill(Color(.systemGray6))
            .overlay(
              RoundedRectangle(cornerRadius: 12)
                .stroke(catAndAppCount > 0 ? Color.green.opacity(0.3) : Color.blue.opacity(0.3), lineWidth: 1)
            )
        )
      }
      .disabled(disabled)
      .opacity(disabled ? 0.6 : 1.0)
      
      // Status messages
      if let disabledText = disabledText, disabled {
        HStack {
          Image(systemName: "exclamationmark.triangle.fill")
            .foregroundColor(.red)
            .font(.system(size: 12))
          Text(disabledText)
            .font(.system(size: 12, weight: .regular, design: .monospaced))
            .foregroundColor(.red)
        }
        .padding(.horizontal, 4)
      } else if catAndAppCount == 0 {
        HStack {
          Image(systemName: "info.circle")
            .foregroundColor(.orange)
            .font(.system(size: 12))
          Text("No apps or websites selected")
            .font(.system(size: 12, weight: .regular, design: .monospaced))
            .foregroundColor(.orange)
        }
        .padding(.horizontal, 4)
      } else if shouldShowWarning {
        HStack {
          Image(systemName: "exclamationmark.triangle.fill")
            .foregroundColor(.orange)
            .font(.system(size: 12))
          Text("Categories expand to individual apps in Allow mode")
            .font(.system(size: 12, weight: .regular, design: .monospaced))
            .foregroundColor(.orange)
        }
        .padding(.horizontal, 4)
      }
    }
  }
}

#Preview {
  BlockedProfileAppSelector(
    selection: FamilyActivitySelection(),
    buttonAction: {},
    disabled: true,
    disabledText: "Disable the current session to edit apps for blocking"
  )

  BlockedProfileAppSelector(
    selection: FamilyActivitySelection(),
    buttonAction: {},
    allowMode: true,
    disabled: true,
    disabledText: "Disable the current session to edit apps for blocking"
  )
}
