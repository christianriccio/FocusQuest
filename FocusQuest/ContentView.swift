import SwiftUI
import UserNotifications
import WidgetKit

struct ContentView: View {
    let appGroupIdentifier: String = "group.com.ChristianRiccio.FocusQuest"
    private let flagCheckTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    @State private var workDurationMinutes = 10
    @State private var breakDurationMinutes = 5
    @State private var timeRemaining = 10 * 60
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
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.7), Color.purple.opacity(0.7)]),
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
                    .ignoresSafeArea()
                
                VStack {
                    HStack {
                        Text("FocusQuest")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Spacer()
                        Button {
                            showingSettings = true
                        } label: {
                            Image(systemName: "gearshape.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                        }
                        
                       
                    }
                    .padding()
                    
                    Spacer()
                    
                    Button {
                        isTimerRunning = false
                        timeRemaining = isWorking ? workDurationMinutes * 60 : breakDurationMinutes * 60
                        
                        if let sharedDefaults = UserDefaults(suiteName: appGroupIdentifier) {
                            sharedDefaults.set(isTimerRunning, forKey: "isTimerRunning")
                            sharedDefaults.set(timeRemaining, forKey: "timeRemaining")
                            sharedDefaults.synchronize()
                        }
                        
                        refreshWidget()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding()
                            .background(Circle().fill(Color.black.opacity(0.3)))
                    }
                    .padding(.all, 10) 
                    Text(formatTime(timeRemaining))
                        .font(.system(size: 80, weight: .thin))
                        .foregroundColor(.white)
                        .padding()
                        .shadow(radius: 10)
                    
                    Text("Stato: \(isWorking ? "Lavoro" : "Pausa")")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.bottom, 40)
                    
                    Button {
                        isTimerRunning.toggle()
                    } label: {
                        Text(isTimerRunning ? "Pausa Timer" : (isWorking ? "Avvia Lavoro" : "Avvia Pausa"))
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white.opacity(0.9))
                            .foregroundColor(.black)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    if !isWorking {
                        Group {
                            if let curiosity = currentCuriosity {
                                VStack {
                                    Text("Curiosità del Giorno")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .padding(.bottom, 5)
                                    
                                    Text(curiosity.text)
                                        .font(.subheadline)
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(.white)
                                        .padding(.horizontal)
                                    
                                    if let image = UIImage(named: curiosity.imageName) {
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 100, height: 100)
                                            .padding(.top, 10)
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                            .shadow(radius: 5)
                                    } else {
                                        Text("Immagine non trovata")
                                            .font(.caption)
                                            .foregroundColor(.red)
                                            .padding(.top, 10)
                                    }
                                }
                                .padding()
                                .background(Color.black.opacity(0.3))
                                .cornerRadius(15)
                                .transition(.scale)
                            } else {
                                Text("Tempo di pausa !")
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding()
            }
            .navigationBarHidden(true)
            .onReceive(timer) { _ in
                print("Tick del timer - isTimerRunning = \(isTimerRunning)")
                  
                  guard isTimerRunning else {
                      print("Timer in pausa, nessuna azione")
                      return
                  }
                if timeRemaining > 0 {
                    timeRemaining -= 1
                    if timeRemaining % 10 == 0 { 
                               updateSharedDefaults()
                           }
                } else {
                    isTimerRunning = false
                    sendNotification()
                    isWorking.toggle()
                    timeRemaining = isWorking ? workDurationMinutes * 60 : breakDurationMinutes * 60
                    
                    updateSharedDefaults()
                    if !isWorking {
                        let filteredCuriosities = selectedCategories.isEmpty ? curiosities : curiosities.filter { selectedCategories.contains($0.category) }
                        currentCuriosity = filteredCuriosities.randomElement()
                    } else {
                        currentCuriosity = nil
                    }
                }
                
                if let sharedDefaults = UserDefaults(suiteName: appGroupIdentifier) {
                    sharedDefaults.set(isTimerRunning, forKey: "isTimerRunning")
                    sharedDefaults.set(isWorking, forKey: "isWorking")
                    sharedDefaults.set(timeRemaining, forKey: "timeRemaining")
                    sharedDefaults.synchronize()
                }
                
                WidgetCenter.shared.reloadAllTimelines()
            }
            .onReceive(NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)) { _ in
                if let sharedDefaults = UserDefaults(suiteName: appGroupIdentifier) {
                    if sharedDefaults.bool(forKey: "widgetToggleTimer") {
                        let updatedTimerState = sharedDefaults.bool(forKey: "isTimerRunning")
                        print("Ricevuto comando dal widget: isTimerRunning = \(updatedTimerState)")
                        
                        DispatchQueue.main.async {
                            isTimerRunning = updatedTimerState
                            
                            if !isTimerRunning {
                                print("Timer messo in pausa da comando widget")
                                
                            }
                        }
                        
                        sharedDefaults.set(false, forKey: "widgetToggleTimer")
                        sharedDefaults.synchronize()
                        
                        refreshWidget()
                    }
                }
            }
            .onReceive(flagCheckTimer) { _ in
                if let sharedDefaults = UserDefaults(suiteName: appGroupIdentifier) {
                    if sharedDefaults.bool(forKey: "widgetToggleTimer") {
                        print("Flag widgetToggleTimer trovato attivo durante controllo periodico")
                        
                        let updatedTimerState = sharedDefaults.bool(forKey: "isTimerRunning")
                        
                        isTimerRunning = updatedTimerState
                        
                        sharedDefaults.set(false, forKey: "widgetToggleTimer")
                        sharedDefaults.synchronize()
                        
                        refreshWidget()
                    }
                }
            }
            .onAppear {
                
                print("App avviata - App Group: \(appGroupIdentifier)")
                if UserDefaults(suiteName: appGroupIdentifier) != nil {
                    print("UserDefaults trovato!")
                } else {
                    print("ERRORE: UserDefaults NON trovato!")
                }
                requestNotificationAuthorization()
                
                if let sharedDefaults = UserDefaults(suiteName: appGroupIdentifier) {
                    let widgetTimerRunning = sharedDefaults.bool(forKey: "isTimerRunning")
                    let widgetTimeRemaining = sharedDefaults.double(forKey: "timeRemaining")
                    
                    if widgetTimerRunning && widgetTimeRemaining > 0 {
                        isTimerRunning = true
                        timeRemaining = Int(widgetTimeRemaining)
                    } else {
                        timeRemaining = workDurationMinutes * 60
                        
                        sharedDefaults.set(isTimerRunning, forKey: "isTimerRunning")
                        sharedDefaults.set(isWorking, forKey: "isWorking")
                        sharedDefaults.set(timeRemaining, forKey: "timeRemaining")
                        sharedDefaults.synchronize()
                    }
                } else {
                    timeRemaining = workDurationMinutes * 60
                }
                
                refreshWidget()
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView(workDurationMinutes: $workDurationMinutes,
                             breakDurationMinutes: $breakDurationMinutes,
                             selectedCategories: $selectedCategories)
                .onDisappear {
                    timeRemaining = isWorking ? workDurationMinutes * 60 : breakDurationMinutes * 60
                }
            }
        }
    }
    
    
    private func updateSharedDefaults() {
        if let sharedDefaults = UserDefaults(suiteName: appGroupIdentifier) {
            print("Prima dell'aggiornamento - isTimerRunning: \(sharedDefaults.bool(forKey: "isTimerRunning")), timeRemaining: \(sharedDefaults.double(forKey: "timeRemaining"))")
            
            sharedDefaults.set(isTimerRunning, forKey: "isTimerRunning")
            sharedDefaults.set(isWorking, forKey: "isWorking")
            sharedDefaults.set(Double(timeRemaining), forKey: "timeRemaining")
            sharedDefaults.synchronize()
            
            print("Dopo l'aggiornamento - isTimerRunning: \(sharedDefaults.bool(forKey: "isTimerRunning")), timeRemaining: \(sharedDefaults.double(forKey: "timeRemaining"))")
            
            WidgetCenter.shared.reloadAllTimelines()
        } else {
            print("ERRORE: Impossibile accedere a UserDefaults con identifier: \(appGroupIdentifier)")
        }
    }
    
    private func refreshWidget() {
        WidgetCenter.shared.reloadAllTimelines()
    }

    
    func formatTime(_ totalSeconds: Int) -> String {
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func requestNotificationAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("Permesso per le notifiche concesso.")
            } else if let error = error {
                print("Errore nella richiesta dei permessi: \(error.localizedDescription)")
            }
        }
    }
    
    func sendNotification() {
        let content = UNMutableNotificationContent()
        content.title = isWorking ? "Pausa Terminata!" : "Sessione di Lavoro Terminata!"
        content.body = isWorking ? "È ora di tornare al lavoro!" : "Goditi la tua pausa e scopri qualcosa di nuovo!"
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString,
                                            content: content,
                                            trigger: trigger)
        print("Invio notifica: \(content.title), \(content.body)")
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Errore nell'invio della notifica: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    ContentView()
}
