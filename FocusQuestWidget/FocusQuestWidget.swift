import WidgetKit
import SwiftUI
import AppIntents

struct SimpleEntry: TimelineEntry {
    let date: Date
    let isTimerRunning: Bool
    let isWorking: Bool
    let timeRemaining: TimeInterval
}

struct Provider: TimelineProvider {
    let appGroupIdentifier = "group.com.ChristianRiccio.FocusQuest"
    
    typealias Entry = SimpleEntry
    
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
    

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        let sharedDefaults = UserDefaults(suiteName: appGroupIdentifier)
        let isTimerRunning = sharedDefaults?.bool(forKey: "isTimerRunning") ?? false
        let isWorking = sharedDefaults?.bool(forKey: "isWorking") ?? true
        let timeRemaining = max(0, sharedDefaults?.double(forKey: "timeRemaining") ?? 25 * 60)
        
        print("Widget getTimeline: isTimerRunning=\(isTimerRunning), timeRemaining=\(timeRemaining)")
        
        var entries: [SimpleEntry] = []
        let currentDate = Date()
        
        if isTimerRunning {
            for secondOffset in 0..<60 {
                let entryDate = Calendar.current.date(byAdding: .second, value: secondOffset, to: currentDate)!
                entries.append(SimpleEntry(
                    date: entryDate,
                    isTimerRunning: isTimerRunning,
                    isWorking: isWorking,
                    timeRemaining: timeRemaining
                ))
            }
            
            let timeline = Timeline(entries: entries, policy: .atEnd)
            completion(timeline)
        } else {
            let entry = SimpleEntry(
                date: currentDate,
                isTimerRunning: isTimerRunning,
                isWorking: isWorking,
                timeRemaining: timeRemaining
            )
            
            let refreshDate = Calendar.current.date(byAdding: .minute, value: 5, to: currentDate)!
            let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
            completion(timeline)
        }
    }
}

struct ToggleTimerIntent: AppIntent {
    static var title: LocalizedStringResource = "Avvia/Pausa Timer FocusQuest"
    

    @MainActor
    func perform() async throws -> some IntentResult {
        print("Widget toggle intent eseguito")
        
        if let sharedDefaults = UserDefaults(suiteName: "group.com.ChristianRiccio.FocusQuest") {
            let currentTimerState = sharedDefaults.bool(forKey: "isTimerRunning")
            
            sharedDefaults.set(!currentTimerState, forKey: "isTimerRunning")
            sharedDefaults.set(true, forKey: "widgetToggleTimer")
            
            print("Widget ha impostato: isTimerRunning=\(!currentTimerState), widgetToggleTimer=true")
            
            sharedDefaults.synchronize()
        }
        
        WidgetCenter.shared.reloadAllTimelines()
        
        return .result()
    }
}

struct FocusQuestWidgetEntryView : View {
    var entry: SimpleEntry
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.7), Color.purple.opacity(0.7)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            VStack(spacing: 8) {
            
                
                if entry.isTimerRunning {
                    Text(entry.isWorking ? "Lavoro" : "Pausa")
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(entry.isWorking ? Color.blue.opacity(0.7) : Color.green.opacity(0.7))
                        )
                        .padding(.bottom, 2)
                    
                    Text(formatTime(entry.timeRemaining))
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.bottom, 6)
                } else {
                    Text("Timer in pausa")
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding(.bottom, 6)
                }
                
                Button(intent: ToggleTimerIntent()) {
                    HStack(spacing: 5) {
                        Image(systemName: entry.isTimerRunning ? "pause.fill" : "play.fill")
                        Text(entry.isTimerRunning ? "Pausa" : "Avvia")
                            .font(.footnote)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .foregroundColor(.black)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white.opacity(0.9))
                    )
                }
                .padding(.top, 2)
            }
            .padding(12)
        }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .init(horizontal: .center, vertical: .top))
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
        .configurationDisplayName("FocusQuest Timer")
        .description("Mostra lo stato del tuo timer FocusQuest.")
    }
}

#Preview(as: .systemSmall) {
    FocusQuestWidget()
} timeline: {
    SimpleEntry(date: .now, isTimerRunning: true, isWorking: true, timeRemaining: 25 * 60)
}
