import SwiftUI

struct SettingsView: View {
    @Binding var colorRaw: String
    @Binding var opacity: Double
    @Binding var visible: Bool
    @Binding var timerSeconds: Int
    @Environment(\.dismiss) private var dismiss

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
                Section {
                    Text("Photos are saved without composition guides. Tutorials and preferences are stored on this device; no account or internet connection is needed.")
                        .font(.footnote).foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Settings")
            .tint(AsperitoPalette.gold)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement:.topBarTrailing) { Button("Done") { dismiss() } } }
        }
    }
}
