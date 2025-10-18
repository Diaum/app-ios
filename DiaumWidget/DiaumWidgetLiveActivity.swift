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
      // Lock screen/banner UI with dark design
      VStack(spacing: 0) {
        // Top section: App name with hourglass icon
        HStack(spacing: 8) {
          Image(systemName: "hourglass")
            .font(.system(size: 18, weight: .medium, design: .monospaced))
            .foregroundColor(.white)
          
          Text("Diaum")
            .font(.system(size: 20, weight: .bold, design: .monospaced))
            .foregroundColor(.white)
        }
        .padding(.top, 16)
        
        Spacer()
        
        // Bottom section: Timer or break indicator
        VStack(spacing: 6) {
          if context.state.isBreakActive {
            HStack(spacing: 4) {
              Image(systemName: "cup.and.saucer.fill")
                .font(.system(size: 16, weight: .medium, design: .monospaced))
                .foregroundColor(Color(red: 0.75, green: 0.75, blue: 0.75))
              Text("On a Break")
                .font(.system(size: 28, weight: .semibold, design: .monospaced))
                .foregroundColor(Color(red: 0.75, green: 0.75, blue: 0.75))
            }
          } else {
            Text(
              Date(
                timeIntervalSinceNow: context.state
                  .getTimeIntervalSinceNow()
              ),
              style: .timer
            )
            .font(.system(size: 28, weight: .semibold, design: .monospaced))
            .foregroundColor(Color(red: 0.75, green: 0.75, blue: 0.75))
          }
        }
        .padding(.bottom, 16)
      }
      .frame(width: 320, height: 100)
      .background(Color(red: 0.047, green: 0.047, blue: 0.047)) // #0C0C0C
      .cornerRadius(24)
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
