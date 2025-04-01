//
//  FocusQuestWidget.swift
//  FocusQuestWidget
//
//  Created by Christian Riccio on 01/04/25.
//



import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    let appGroupIdentifier = "group.com.ChristianRiccio.FocusQuest" // Assicurati che sia lo stesso

    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), isTimerRunning: false, isWorking: true, timeRemaining: 25 * 60)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let sharedDefaults = UserDefaults(suiteName: appGroupIdentifier)
        let isTimerRunning = sharedDefaults?.bool(forKey: "isTimerRunning") ?? false
        let isWorking = sharedDefaults?.bool(forKey: "isWorking") ?? true
        let timeRemaining = sharedDefaults?.double(forKey: "timeRemaining") ?? 25 * 60

        let entry = SimpleEntry(date: Date(), isTimerRunning: isTimerRunning, isWorking: isWorking, timeRemaining: timeRemaining)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let sharedDefaults = UserDefaults(suiteName: appGroupIdentifier)
        let isTimerRunning = sharedDefaults?.bool(forKey: "isTimerRunning") ?? false
        let isWorking = sharedDefaults?.bool(forKey: "isWorking") ?? true
        let timeRemaining = sharedDefaults?.double(forKey: "timeRemaining") ?? 25 * 60

        let entry = SimpleEntry(date: Date(), isTimerRunning: isTimerRunning, isWorking: isWorking, timeRemaining: timeRemaining)

        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let isTimerRunning: Bool
    let isWorking: Bool
    let timeRemaining: TimeInterval
}

struct FocusQuestWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack {
            Text("FocusQuest")
                .font(.headline)
                .padding(.bottom, 5)

            if entry.isTimerRunning {
                Text(entry.isWorking ? "Lavoro" : "Pausa")
                    .font(.subheadline)
                Text(formatTime(entry.timeRemaining))
                    .font(.title3)
            } else {
                Text("Timer Fermo")
                    .font(.subheadline)
            }
        }
    }

    func formatTime(_ totalSeconds: TimeInterval) -> String {
        let minutes = Int(totalSeconds) / 60
        let seconds = Int(totalSeconds) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct FocusQuestWidget: Widget {
    let kind: String = "FocusQuestWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            FocusQuestWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("FocusQuest Timer") // Nome visualizzato quando si aggiunge il widget
        .description("Mostra lo stato del tuo timer FocusQuest.") // Descrizione visualizzata
    }
}

#Preview(as: .systemSmall) {
    FocusQuestWidget()
} timeline: {
    SimpleEntry(date: .now, isTimerRunning: true, isWorking: true, timeRemaining: 25 * 60)
}
