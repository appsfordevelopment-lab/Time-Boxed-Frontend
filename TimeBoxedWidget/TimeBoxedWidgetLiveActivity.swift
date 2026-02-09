import ActivityKit
import SwiftUI
import WidgetKit

struct TimeBoxedWidgetAttributes: ActivityAttributes {
  public struct ContentState: Codable, Hashable {
    var startTime: Date
    var isBreakActive: Bool = false
    var breakStartTime: Date?
    var breakEndTime: Date?

    func getTimeIntervalSinceNow() -> Double {
      // Calculate the break duration to subtract from elapsed time
      let breakDuration = calculateBreakDuration()

      // Calculate elapsed time minus break duration
      let adjustedStartTime = startTime.addingTimeInterval(breakDuration)

      return adjustedStartTime.timeIntervalSince1970
        - Date().timeIntervalSince1970
    }

    private func calculateBreakDuration() -> TimeInterval {
      guard let breakStart = breakStartTime else {
        return 0
      }

      if let breakEnd = breakEndTime {
        // Break is complete, return the full duration
        return breakEnd.timeIntervalSince(breakStart)
      }

      // Break is not yet ended, don't count it
      return 0
    }
  }

  var name: String
  var message: String
}

struct TimeBoxedWidgetLiveActivity: Widget {
  var body: some WidgetConfiguration {
    ActivityConfiguration(for: TimeBoxedWidgetAttributes.self) { context in
      // Lock screen/banner UI goes here
      HStack(alignment: .center, spacing: 16) {
        // Left side - App info
        VStack(alignment: .leading, spacing: 8) {
          HStack(spacing: 4) {
            Text("Time Boxed")
              .font(.headline)
              .fontWeight(.bold)
              .foregroundColor(.primary)
            Image(systemName: "hourglass")
              .foregroundColor(.purple)
          }

          Text(context.attributes.name)
            .font(.subheadline)
            .foregroundColor(.primary)

          Text(context.attributes.message)
            .font(.caption)
            .foregroundColor(.secondary)
        }

        Spacer()

        // Right side - Timer or break indicator
        VStack(alignment: .trailing, spacing: 4) {
          if context.state.isBreakActive {
            HStack(spacing: 6) {
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
            .font(.title)
            .fontWeight(.semibold)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.trailing)
          }
        }
      }
      .padding(.horizontal, 16)
      .padding(.vertical, 12)

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
      .widgetURL(URL(string: "http://www.timeboxed.app"))
      .keylineTint(Color.purple)
    }
  }
}

extension TimeBoxedWidgetAttributes {
  fileprivate static var preview: TimeBoxedWidgetAttributes {
    TimeBoxedWidgetAttributes(
      name: "Focus Session",
      message: "Stay focused and avoid distractions")
  }
}

extension TimeBoxedWidgetAttributes.ContentState {
  fileprivate static var shortTime: TimeBoxedWidgetAttributes.ContentState {
    TimeBoxedWidgetAttributes
      .ContentState(
        startTime: Date(timeInterval: 60, since: Date.now),
        isBreakActive: false,
        breakStartTime: nil,
        breakEndTime: nil
      )
  }

  fileprivate static var longTime: TimeBoxedWidgetAttributes.ContentState {
    TimeBoxedWidgetAttributes.ContentState(
      startTime: Date(timeInterval: 60, since: Date.now),
      isBreakActive: false,
      breakStartTime: nil,
      breakEndTime: nil
    )
  }

  fileprivate static var breakActive: TimeBoxedWidgetAttributes.ContentState {
    TimeBoxedWidgetAttributes.ContentState(
      startTime: Date(timeInterval: 60, since: Date.now),
      isBreakActive: true,
      breakStartTime: Date.now,
      breakEndTime: nil
    )
  }
}

#Preview("Notification", as: .content, using: TimeBoxedWidgetAttributes.preview) {
  TimeBoxedWidgetLiveActivity()
} contentStates: {
  TimeBoxedWidgetAttributes.ContentState.shortTime
  TimeBoxedWidgetAttributes.ContentState.longTime
  TimeBoxedWidgetAttributes.ContentState.breakActive
}
