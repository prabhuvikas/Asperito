import SwiftUI

struct SettingsView: View {
    @Binding var colorRaw: String
    @Binding var opacity: Double
    @Binding var visible: Bool
    @Binding var timerSeconds: Int
    @Environment(\.dismiss) private var dismiss
    @State private var showingPrivacy = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Composition overlay") {
                    Toggle("Show guide",isOn:$visible)
                    Picker("Line color",selection:$colorRaw) {
                        ForEach(GuideColor.allCases) { color in
                            Label(color.rawValue.capitalized,systemImage:"circle.fill")
                                .tag(color.rawValue)
                        }
                    }
                    VStack(alignment:.leading) {
                        Text("Line opacity: \(Int(opacity * 100))%")
                        Slider(value:$opacity,in:0.2...1)
                    }
                }
                Section("Camera") {
                    Picker("Shutter timer",selection:$timerSeconds) {
                        Text("Off").tag(0); Text("3 seconds").tag(3); Text("10 seconds").tag(10)
                    }
                }
                Section("About and privacy") {
                    Button("Privacy policy") { showingPrivacy = true }
                    Text("Photos are saved without composition guides. Tutorials and preferences are stored on this device; no account or internet connection is needed.")
                        .font(.footnote).foregroundStyle(.secondary)
                }
            }
            .sheet(isPresented: $showingPrivacy) {
                NavigationStack {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Asperito Privacy").font(.title2.bold())
                            Text("Asperito uses your camera for the live viewfinder and captures photos when you press the shutter.")
                            Text("Photos are saved locally to your iPhone Photos library. Asperito does not upload photos, track usage, collect analytics or require an account.")
                            Text("The Horizon Level guide reads device motion locally for alignment; motion data is not saved or sent anywhere.")
                            Text("Guide selection and settings are stored on this device. Delete Asperito to remove local preferences; saved photos stay in Photos.")
                            Text("You can revoke Camera and Add Photos permissions in iOS Settings at any time.")
                            Text("Policy revision: November 2026.").font(.footnote).foregroundStyle(.secondary)
                        }.padding()
                    }
                    .navigationTitle("Privacy policy")
                    .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Done") { showingPrivacy = false } } }
                }
            }
            .navigationTitle("Settings")
            .tint(AsperitoPalette.accessibleAction)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement:.topBarTrailing) { Button("Done") { dismiss() }.foregroundStyle(AsperitoPalette.accessibleAction) } }
        }
    }
}
