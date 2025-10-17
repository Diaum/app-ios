import SwiftUI

struct StrategyRow: View {
  let strategy: BlockingStrategy
  let isSelected: Bool
  let onTap: () -> Void

  var body: some View {
    Button(action: onTap) {
      HStack(spacing: 16) {
        Image(systemName: strategy.iconType)
          .font(.title2)
          .foregroundColor(.gray)
          .frame(width: 24, height: 24)

        VStack(alignment: .leading, spacing: 4) {
          Text(strategy.name)
            .font(.system(size: 16, weight: .semibold, design: .monospaced))

          Text(strategy.description)
            .font(.system(size: 14, weight: .regular, design: .monospaced))
            .foregroundColor(.secondary)
            .lineLimit(3)
        }
        .padding(.vertical, 8)

        Spacer()

        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
          .foregroundColor(isSelected ? .green : .secondary)
          .font(.system(size: 20))
      }
    }
    .buttonStyle(PlainButtonStyle())
  }
}

#Preview {
  StrategyRow(strategy: NFCBlockingStrategy(), isSelected: true, onTap: {})
}

#Preview {
  StrategyRow(strategy: NFCBlockingStrategy(), isSelected: true, onTap: {})
}
