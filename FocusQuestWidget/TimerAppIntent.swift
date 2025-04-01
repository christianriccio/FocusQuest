//
//  TimerAppIntent.swift
//  FocusQuest
//
//  Created by Christian Riccio on 01/04/25.
//

//import AppIntents
//
//struct ToggleTimerIntent: AppIntent {
//    static var title: LocalizedStringResource = "Avvia/Pausa Timer FocusQuest"
//
//    @MainActor
//    func perform() async throws -> some IntentResult {
//        print("L'intent per avviare/pausare il timer è stato attivato dal widget!")
//
//        if let sharedDefaults = UserDefaults(suiteName: "group.com.ChristianRiccio.FocusQuest") {
//            let currentTimerState = sharedDefaults.bool(forKey: "isTimerRunning")
//            sharedDefaults.set(!currentTimerState, forKey: "widgetToggleTimer") // Usa un'altra chiave per evitare conflitti
//        }
//
//        return .result()
//    }
//}
