import SwiftUI

struct TutorialView: View {
    let kind: OverlayKind
    var onApply: () -> Void
    @Environment(\.dismiss) private var dismiss
    private var lesson: OverlayLesson { .forKind(kind) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment:.leading,spacing:20) {
                    ZStack {
                        LinearGradient(colors:[AsperitoPalette.graphite,AsperitoPalette.midnight],startPoint:.topLeading,endPoint:.bottomTrailing)
                        OverlayCanvas(kind:kind,color:AsperitoPalette.gold,opacity:0.95).padding(18)
                    }
                    .frame(height:220)
                    .clipShape(RoundedRectangle(cornerRadius:18))
                    Text(kind.title).font(.largeTitle.bold())
                    Text(lesson.summary).font(.body)
                    VStack(alignment:.leading,spacing:6) {
                        Label("When to use",systemImage:"camera.macro").font(.headline)
                        Text(lesson.useFor)
                    }
                    .padding().frame(maxWidth:.infinity,alignment:.leading)
                    .background(.white.opacity(0.07),in:RoundedRectangle(cornerRadius:12))
                    VStack(alignment:.leading,spacing:6) {
                        Label("Try it yourself",systemImage:"lightbulb.fill").font(.headline)
                        Text(lesson.exercise)
                    }
                    .padding().frame(maxWidth:.infinity,alignment:.leading)
                    .background(AsperitoPalette.gold.opacity(0.13),in:RoundedRectangle(cornerRadius:12))
                    Button { onApply(); dismiss() } label: {
                        Label("Use this guide",systemImage:"camera.viewfinder")
                            .frame(maxWidth:.infinity)
                    }
                    .buttonStyle(.borderedProminent).tint(AsperitoPalette.gold).foregroundStyle(.black)
                }
                .padding()
            }
            .navigationTitle("Photography lesson")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement:.topBarTrailing) { Button("Close") { dismiss() } } }
        }
    }
}
