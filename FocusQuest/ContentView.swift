//
//  ContentView.swift
//  FocusQuest
//
//  Created by Christian Riccio on 01/04/25.
//

import SwiftUI
import UserNotifications

struct ContentView: View {
    let appGroupIdentifier: String = "group.ChristianRiccio.FocusQuest"
    
    @State private var workDurationMinutes = 10
    @State private var breakDurationMinutes = 5
    @State private var timeRemaining = 25 * 60
    @State private var isWorking = true
    @State private var isTimerRunning = false
    @State private var showingSettings = false
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var currentCuriosity: Curiosity?
    
    @State private var selectedCategories: Set<String> = ["Sport", "Tecnologia", "Storia", "Animali", "Musica", "Cucina", "Viaggio", "Stile di Vita", "Arte", "Scienza"]
    
    let curiosities = [
        Curiosity(text: "Lo sapevi che il miele non scade mai?", imageName: "placeholder", category: "Scienza"),
        Curiosity(text: "La Grande Muraglia Cinese è visibile dallo spazio (anche se non sempre facilmente).", imageName: "placeholder", category: "Storia"),
        Curiosity(text: "Il Colosseo di Roma poteva ospitare fino a 80.000 spettatori.", imageName: "colosseum", category: "Storia"),
        Curiosity(text: "Le banane sono tecnicamente delle bacche.", imageName: "placeholder", category: "Scienza"),
        Curiosity(text: "Il gatto è stato il primo animale domestico in Egitto.", imageName: "placeholder", category: "Storia")
    ]
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Text("FocusQuest")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Spacer()
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.title2)
                    }
                }
                .padding()
                
                Spacer()
                Text(formatTime(timeRemaining)).font(.system(size: 80, weight: .thin)).padding()
                
                Text("Stato: \(isWorking ? "Lavoro" : "Pausa")").font(.headline).padding(.bottom, 40)
                
                Button(isTimerRunning ? "Pausa Timer" : (isWorking ? "Avvia Lavoro" : "Avvia Pausa")){
                    isTimerRunning.toggle()
                }.padding().buttonStyle(.borderedProminent)
                
                Spacer()
                
                if !isWorking {
                    if let curiosity = currentCuriosity {
                        VStack {
                            Text("Curiosità del Giorno")
                                .font(.headline)
                                .padding(.bottom, 5)
                            Text(curiosity.text)
                                .font(.subheadline)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            
                            if let image = UIImage(named: curiosity.imageName) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 100)
                                    .padding(.top, 10)
                            } else {
                                Text("Immagine non trovata")
                                    .font(.caption)
                                    .foregroundColor(.red)
                                    .padding(.top, 10)
                            }
                            
                        }
                        .padding().background(Color.gray.opacity(0.2)).cornerRadius(10).transition(.scale)
                    } else {
                        Text("Tempo di pausa !")
                            .font(.subheadline)
                    }
                }
            }
            .padding()
            .onReceive(timer) { _ in
                if isTimerRunning {
                    if timeRemaining > 0 {
                        timeRemaining -= 1
                    } else {
                        isTimerRunning = false
                        sendNotification()
                        isWorking.toggle()
                        timeRemaining = Int(isWorking ? TimeInterval(workDurationMinutes * 60) : TimeInterval(breakDurationMinutes * 60))
                        
                        if !isWorking {
                            let filteredCuriosities: [Curiosity]
                            if !selectedCategories.isEmpty {
                                filteredCuriosities = curiosities.filter { curiosity in
                                    selectedCategories.contains(curiosity.category)
                                }
                            } else {
                                
                                filteredCuriosities = curiosities
                            }
                            currentCuriosity = curiosities.randomElement()
                        } else {
                            currentCuriosity = nil
                        }
                    }
                    if let sharedDefaults = UserDefaults(suiteName: appGroupIdentifier) {
                        sharedDefaults.set(isTimerRunning, forKey: "isTimerRunning")
                        sharedDefaults.set(isWorking, forKey: "isWorking")
                        sharedDefaults.set(timeRemaining, forKey: "timeRemaining")
                    } else {
                        
                        if let sharedDefaults = UserDefaults(suiteName: appGroupIdentifier) {
                            sharedDefaults.set(isTimerRunning, forKey: "isTimerRunning")
                            sharedDefaults.set(isWorking, forKey: "isWorking")
                            sharedDefaults.set(timeRemaining, forKey: "timeRemaining")
                        }
                    }
                }
            }
            .onAppear{
                requestNotificationAUthorization()
                timeRemaining = Int(TimeInterval(workDurationMinutes * 60))
            }
        }.sheet(isPresented: $showingSettings) {
            SettingsView(workDurationMinutes: $workDurationMinutes, breakDurationMinutes: $breakDurationMinutes, selectedCategories: $selectedCategories)
                .onDisappear {
                    timeRemaining = Int(isWorking ? TimeInterval(workDurationMinutes * 60) : TimeInterval(breakDurationMinutes * 60))
                }
        }
    }
    
    func formatTime(_ totalSeconds: Int) -> String {
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func requestNotificationAUthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("Permesso per le notifiche concesso.")
            } else if let error = error {
                print("Errore nella richesta dei permessi per le notifiche: \(error.localizedDescription)")
            }
        }
    }
    
    func sendNotification() {
        let content = UNMutableNotificationContent()
        content.title = isWorking ? "Pausa Terminata !" : "Sessione di Lavoro Terminata !"
        content.body = isWorking ? "È ora di tornare al lavoro!" : "Goditi la tua pausa e scopri qualcosa di nuovo!"
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        print("Tentativo di inviare la notifica: \(content.title ?? ""), \(content.body ?? "")")
        UNUserNotificationCenter.current().add(request){ error in
            if let error = error {
                print("Errore nell'invio della notifica: \(error.localizedDescription)")
            }
        }
        
    }
}

#Preview {
    ContentView()
}
