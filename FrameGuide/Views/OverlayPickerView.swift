import SwiftUI

struct OverlayPickerView: View {
    @Binding var selected: OverlayKind
    @Binding var rows: Int
    @Binding var columns: Int
    @Binding var spiralTurns: Int
    @Binding var spiralMirrored: Bool
    @Binding var eyeLine: Double
    @Binding var perspectiveX: Double
    @Binding var perspectiveY: Double
    @Binding var safeRatio: Double
    @Binding var cinemaRatio: Double
    var onLearn: () -> Void
    @Environment(\.dismiss) private var dismiss

    private let layout = [GridItem(.flexible()),GridItem(.flexible())]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment:.leading,spacing:20) {
                    LazyVGrid(columns:layout,spacing:10) {
                        ForEach(OverlayKind.allCases) { kind in
                            Button {
                                selected = kind
                                UISelectionFeedbackGenerator().selectionChanged()
                            } label: {
                                VStack(alignment:.leading,spacing:10) {
                                    ZStack {
                                        AsperitoPalette.graphite
                                        OverlayCanvas(kind:kind,color:kind == selected ? AsperitoPalette.gold : .white,opacity:0.95)
                                            .padding(9)
                                    }
                                    .frame(height:82)
                                    .clipShape(RoundedRectangle(cornerRadius:8))
                                    Text(kind.title).font(.subheadline.weight(.semibold)).foregroundStyle(kind == selected ? AsperitoPalette.gold : AsperitoPalette.ivory).lineLimit(2).frame(maxWidth:.infinity,alignment:.leading)
                                }
                                .padding(10)
                                .frame(maxWidth:.infinity,alignment:.leading)
                                .background(AsperitoPalette.graphite,in:RoundedRectangle(cornerRadius:12))
                                .overlay(RoundedRectangle(cornerRadius:12).stroke(selected == kind ? AsperitoPalette.gold : .white.opacity(0.1),lineWidth:1.5))
                            }
                            .foregroundStyle(.white)
                            .accessibilityLabel("Choose \(kind.title)")
                        }
                    }
                    extraSettings
                    Button(action:onLearn) {
                        Label("Learn \(selected.title)",systemImage:"book.closed.fill")
                            .frame(maxWidth:.infinity)
                    }.buttonStyle(.borderedProminent).tint(AsperitoPalette.gold).foregroundStyle(.black)
                }
                .padding()
            }
            .background(AsperitoPalette.midnight)
            .navigationTitle("Composition guides")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement:.topBarTrailing) { Button("Done") { dismiss() } } }
        }
        .preferredColorScheme(.dark)
    }
    @ViewBuilder private var extraSettings: some View {
        VStack(alignment:.leading,spacing:12) {
            switch selected {
            case .custom:
                Stepper("Rows: \(rows)",value:$rows,in:2...10)
                Stepper("Columns: \(columns)",value:$columns,in:2...10)
            case .goldenSpiral:
                Button("Rotate spiral 90°") { spiralTurns = (spiralTurns + 1) % 4 }
                Text("The gold arc follows nested golden rectangles. Fine white lines help with framing; no formulas appear on the camera.").font(.footnote).foregroundStyle(.secondary)
                Toggle("Mirror spiral",isOn:$spiralMirrored)
            case .eyeLine:
                Text("Eye-line height: \(Int(eyeLine*100))%")
                Slider(value:$eyeLine,in:0.1...0.9)
            case .perspective:
                Text("Vanishing point — horizontal")
                Slider(value:$perspectiveX,in:0.1...0.9)
                Text("Vanishing point — vertical")
                Slider(value:$perspectiveY,in:0.1...0.9)
            case .safeArea:
                Picker("Guide ratio",selection:$safeRatio) {
                    Text("4:5").tag(0.8)
                    Text("9:16").tag(9.0/16.0)
                }.pickerStyle(.segmented)
            case .cinematic:
                Picker("Cinematic frame",selection:$cinemaRatio) {
                    Text("16:9").tag(16.0/9.0)
                    Text("2.39:1").tag(2.39)
                }.pickerStyle(.segmented)
            default:
                Text("This overlay adapts automatically to the live camera preview.")
                    .foregroundStyle(.secondary).font(.footnote)
            }
        }
        .padding(14)
        .background(.white.opacity(0.06),in:RoundedRectangle(cornerRadius:12))
    }
}
