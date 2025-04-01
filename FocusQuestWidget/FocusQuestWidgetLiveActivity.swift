////
////  FocusQuestWidgetLiveActivity.swift
////  FocusQuestWidget
////
////  Created by Christian Riccio on 01/04/25.
////
//
//import ActivityKit
//import WidgetKit
//import SwiftUI
//
//struct FocusQuestWidgetAttributes: ActivityAttributes {
//    public struct ContentState: Codable, Hashable {
//        // Dynamic stateful properties about your activity go here!
//        var emoji: String
//    }
//
//    // Fixed non-changing properties about your activity go here!
//    var name: String
//}
//
//struct FocusQuestWidgetLiveActivity: Widget {
//    var body: some WidgetConfiguration {
//        ActivityConfiguration(for: FocusQuestWidgetAttributes.self) { context in
//            // Lock screen/banner UI goes here
//            VStack {
//                Text("Hello \(context.state.emoji)")
//            }
//            .activityBackgroundTint(Color.cyan)
//            .activitySystemActionForegroundColor(Color.black)
//
//        } dynamicIsland: { context in
//            DynamicIsland {
//                // Expanded UI goes here.  Compose the expanded UI through
//                // various regions, like leading/trailing/center/bottom
//                DynamicIslandExpandedRegion(.leading) {
//                    Text("Leading")
//                }
//                DynamicIslandExpandedRegion(.trailing) {
//                    Text("Trailing")
//                }
//                DynamicIslandExpandedRegion(.bottom) {
//                    Text("Bottom \(context.state.emoji)")
//                    // more content
//                }
//            } compactLeading: {
//                Text("L")
//            } compactTrailing: {
//                Text("T \(context.state.emoji)")
//            } minimal: {
//                Text(context.state.emoji)
//            }
//            .widgetURL(URL(string: "http://www.apple.com"))
//            .keylineTint(Color.red)
//        }
//    }
//}
//
//extension FocusQuestWidgetAttributes {
//    fileprivate static var preview: FocusQuestWidgetAttributes {
//        FocusQuestWidgetAttributes(name: "World")
//    }
//}
//
//extension FocusQuestWidgetAttributes.ContentState {
//    fileprivate static var smiley: FocusQuestWidgetAttributes.ContentState {
//        FocusQuestWidgetAttributes.ContentState(emoji: "😀")
//     }
//     
//     fileprivate static var starEyes: FocusQuestWidgetAttributes.ContentState {
//         FocusQuestWidgetAttributes.ContentState(emoji: "🤩")
//     }
//}
//
//#Preview("Notification", as: .content, using: FocusQuestWidgetAttributes.preview) {
//   FocusQuestWidgetLiveActivity()
//} contentStates: {
//    FocusQuestWidgetAttributes.ContentState.smiley
//    FocusQuestWidgetAttributes.ContentState.starEyes
//}
