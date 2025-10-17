import SwiftUI

struct BlockedProfileDomainSelector: View {
  var domains: [String]
  var buttonAction: () -> Void
  var allowMode: Bool = false
  var disabled: Bool = false
  var disabledText: String?

  private var title: String {
    return allowMode ? "Allowed" : "Blocked"
  }

  private var domainCount: Int {
    return domains.count
  }

  private var buttonText: String {
    return allowMode
      ? "Select domains to allow"
      : "Select domains to restrict"
  }

  var body: some View {
    Button(action: buttonAction) {
      HStack {
        Text(buttonText)
          .font(.system(size: 16, weight: .regular, design: .monospaced))
        Spacer()
        Image(systemName: "chevron.right")
          .foregroundStyle(.gray)
      }
    }
    .disabled(disabled)

    if let disabledText = disabledText, disabled {
      Text(disabledText)
        .foregroundStyle(.red)
        .padding(.top, 4)
        .font(.system(size: 12, weight: .regular, design: .monospaced))
    } else if domainCount == 0 {
      Text("No domains selected")
        .font(.system(size: 14, weight: .regular, design: .monospaced))
        .foregroundStyle(.gray)
    } else {
      Text("\(domainCount) \(domainCount == 1 ? "domain" : "domains") selected")
        .font(.system(size: 14, weight: .regular, design: .monospaced))
        .foregroundStyle(.gray)
        .padding(.top, 4)
    }
  }
}

#Preview {
  VStack(spacing: 20) {
    BlockedProfileDomainSelector(
      domains: ["example.com", "test.org"],
      buttonAction: {}
    )

    BlockedProfileDomainSelector(
      domains: [],
      buttonAction: {},
      allowMode: true
    )

    BlockedProfileDomainSelector(
      domains: ["example.com"],
      buttonAction: {},
      disabled: true,
      disabledText: "Disable the current session to edit domains"
    )
  }
  .padding()
}
