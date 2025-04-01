import SwiftUI

struct SettingsView: View {
    @Binding var workDurationMinutes: Int
    @Binding var breakDurationMinutes: Int
    @Binding var selectedCategories: Set<String>
    
    let workDurationOptions = Array(stride(from: 10, through: 360, by: 10))
    let breakDurationOptions = Array(stride(from: 5, through: 60, by: 5))
    
    let allCategories: [String] = ["Sport", "Tecnologia", "Storia", "Animali", "Musica", "Cucina", "Viaggio", "Stile di Vita", "Arte", "Scienza"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Durata Lavoro (minuti)")) {
                    Picker("Seleziona i minuti", selection: $workDurationMinutes) {
                        ForEach(workDurationOptions, id: \.self) { minutes in
                            Text("\(minutes)")
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section(header: Text("Durata Pausa (minuti)")) {
                    Picker("Seleziona i minuti", selection: $breakDurationMinutes) {
                        ForEach(breakDurationOptions, id: \.self) { minutes in
                            Text("\(minutes)")
                        }
                    }
                    .pickerStyle(.menu)
                }
                Section(header: Text("Categorie Curiosità")) {
                    ForEach(allCategories, id: \.self) { category in
                        Toggle(category, isOn: Binding(
                            get: { selectedCategories.contains(category) },
                            set: { newValue in
                                if newValue {
                                    selectedCategories.insert(category)
                                } else {
                                    selectedCategories.remove(category)
                                }
                            }
                        ))
                    }
                }
            }
            .navigationTitle("Imposta Durate e Categorie")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    SettingsView(workDurationMinutes: .constant(25), breakDurationMinutes: .constant(5), selectedCategories: .constant(["Scienza"]))
}
