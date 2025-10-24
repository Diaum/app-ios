import ActivityKit
import SwiftUI
import WidgetKit

struct DiaumWidgetAttributes: ActivityAttributes {
  public struct ContentState: Codable, Hashable {
    var startTime: Date
    var isBreakActive: Bool = false

    func getTimeIntervalSinceNow() -> Double {
      return startTime.timeIntervalSince1970
        - Date().timeIntervalSince1970
    }
  }

  var name: String
  var message: String
}

struct DiaumWidgetLiveActivity: Widget {
  var body: some WidgetConfiguration {
    ActivityConfiguration(for: DiaumWidgetAttributes.self) { context in
      // Lock screen/banner UI with black background and white border
      VStack(spacing: 0) {
        Spacer()
        
        // Centered content with proper spacing
        VStack(spacing: 8) {
          // Top section: App name (centered, uppercase)
          Text("FOCCO")
            .font(.system(size: 18, weight: .bold, design: .monospaced))
            .foregroundColor(.white)
          
          // Bottom section: Timer or break indicator (centered)
          if context.state.isBreakActive {
            Text("On a Break")
              .font(.system(size: 16, weight: .regular, design: .monospaced))
              .foregroundColor(Color(red: 0.75, green: 0.75, blue: 0.75))
          } else {
            Text(
              Date(
                timeIntervalSinceNow: context.state
                  .getTimeIntervalSinceNow()
              ),
              style: .timer
            )
            .font(.system(size: 16, weight: .regular, design: .monospaced))
            .foregroundColor(Color(red: 0.75, green: 0.75, blue: 0.75))
          }
        }
        
        Spacer()
      }
      .padding(2) // 2px padding from all sides
      .frame(width: 320, height: 100)
      .background(Color.black) // #000000
      .overlay(
        RoundedRectangle(cornerRadius: 14)
          .stroke(Color.white, lineWidth: 1.5)
      )
      .cornerRadius(14)
      .shadow(color: .black.opacity(0.5), radius: 12, x: 0, y: 0)

    } dynamicIsland: { context in
      DynamicIsland {
        DynamicIslandExpandedRegion(.center) {
          VStack(spacing: 8) {
            HStack(spacing: 6) {
              Image(systemName: "hourglass")
                .foregroundColor(.purple)
              Text(context.attributes.name)
                .font(.headline)
                .fontWeight(.medium)
            }

            Text(context.attributes.message)
              .font(.subheadline)
              .foregroundColor(.secondary)
              .multilineTextAlignment(.center)

            if context.state.isBreakActive {
              VStack(spacing: 2) {
                Image(systemName: "cup.and.heat.waves.fill")
                  .font(.title2)
                  .foregroundColor(.orange)
                Text("On a Break")
                  .font(.subheadline)
                  .fontWeight(.semibold)
                  .foregroundColor(.orange)
              }
            } else {
              Text(
                Date(
                  timeIntervalSinceNow: context.state
                    .getTimeIntervalSinceNow()
                ),
                style: .timer
              )
              .font(.title2)
              .fontWeight(.semibold)
              .multilineTextAlignment(.center)
            }
          }
          .padding(.horizontal, 16)
          .padding(.vertical, 4)
        }
      } compactLeading: {
        // Compact leading state
        Image(systemName: "hourglass")
          .foregroundColor(.purple)
      } compactTrailing: {
        // Compact trailing state
        Text(
          context.attributes.name
        )
        .font(.caption)
        .fontWeight(.semibold)
      } minimal: {
        // Minimal state
        Image(systemName: "hourglass")
          .foregroundColor(.purple)
      }
      .widgetURL(URL(string: "http://www.foqos.app"))
      .keylineTint(Color.purple)
    }
  }
}

extension DiaumWidgetAttributes {
  fileprivate static var preview: DiaumWidgetAttributes {
    DiaumWidgetAttributes(
      name: "Focus Session",
      message: "Stay focused and avoid distractions")
  }
}

extension DiaumWidgetAttributes.ContentState {
  fileprivate static var shortTime: DiaumWidgetAttributes.ContentState {
    DiaumWidgetAttributes
      .ContentState(startTime: Date(timeInterval: 60, since: Date.now))
  }

  fileprivate static var longTime: DiaumWidgetAttributes.ContentState {
    DiaumWidgetAttributes.ContentState(startTime: Date(timeInterval: 60, since: Date.now))
  }

  fileprivate static var breakActive: DiaumWidgetAttributes.ContentState {
    DiaumWidgetAttributes.ContentState(
      startTime: Date(timeInterval: 60, since: Date.now),
      isBreakActive: true
    )
  }
}

#Preview("Notification", as: .content, using: DiaumWidgetAttributes.preview) {
  DiaumWidgetLiveActivity()
} contentStates: {
  DiaumWidgetAttributes.ContentState.shortTime
  DiaumWidgetAttributes.ContentState.longTime
  DiaumWidgetAttributes.ContentState.breakActive
}
