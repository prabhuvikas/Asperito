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
                                        Color(red:0.13,green:0.19,blue:0.22)
                                        OverlayCanvas(kind:kind,opacity:0.95)
                                            .padding(9)
                                    }
                                    .frame(height:82)
                                    .clipShape(RoundedRectangle(cornerRadius:8))
                                    Text(kind.title).font(.caption.weight(.medium)).lineLimit(1)
                                }
                                .padding(10)
                                .frame(maxWidth:.infinity,alignment:.leading)
                                .background(selected == kind ? .yellow.opacity(0.18) : .white.opacity(0.07),in:RoundedRectangle(cornerRadius:12))
                                .overlay(RoundedRectangle(cornerRadius:12).stroke(selected == kind ? .yellow : .clear,lineWidth:1.5))
                            }
                            .foregroundStyle(.white)
                            .accessibilityLabel("Choose \(kind.title)")
                        }
                    }
                    extraSettings
                    Button(action:onLearn) {
                        Label("Learn \(selected.title)",systemImage:"book.closed.fill")
                            .frame(maxWidth:.infinity)
                    }.buttonStyle(.borderedProminent).tint(.yellow).foregroundStyle(.black)
                }
                .padding()
            }
            .navigationTitle("Composition guides")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement:.topBarTrailing) { Button("Done") { dismiss() } } }
        }
    }
    @ViewBuilder private var extraSettings: some View {
        VStack(alignment:.leading,spacing:12) {
            switch selected {
            case .custom:
                Stepper("Rows: \(rows)",value:$rows,in:2...10)
                Stepper("Columns: \(columns)",value:$columns,in:2...10)
            case .goldenSpiral:
                Button("Rotate spiral 90°") { spiralTurns = (spiralTurns + 1) % 4 }
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
