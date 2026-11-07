import SwiftUI

struct OnboardingView: View {
    var onContinue: () -> Void

    var body: some View {
        VStack(spacing:24) {
            Spacer()
            ZStack {
                RoundedRectangle(cornerRadius:22)
                    .fill(LinearGradient(colors:[.black,.teal.opacity(0.38)],startPoint:.top,endPoint:.bottom))
                OverlayCanvas(kind:.thirds,color:.yellow,opacity:0.95)
                    .padding(22)
            }
            .frame(height:240)
            .padding(.horizontal,36)

            VStack(spacing:8) {
                Text("ASPERITO").font(.subheadline.bold()).tracking(4).foregroundStyle(.yellow)
                Text("Compose. Learn. Capture.").font(.title.bold()).multilineTextAlignment(.center)
                Text("12 real-time composition guides, bite-sized photography lessons, and beautiful photos without visible grid lines.")
                    .font(.body).foregroundStyle(.secondary).multilineTextAlignment(.center)
            }.padding(.horizontal,26)
            VStack(alignment:.leading,spacing:14) {
                Label("Choose a composition overlay",systemImage:"square.grid.3x3")
                Label("Tap Learn for a quick camera tip",systemImage:"book.closed")
                Label("Capture without any guide lines",systemImage:"camera")
            }
            .font(.subheadline)
            Spacer()
            Button(action:onContinue) {
                Text("Start photographing").frame(maxWidth:.infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.yellow)
            .foregroundStyle(.black)
            .padding(.horizontal,24)
            Text("Offline · No account · Photos stay on your iPhone")
                .font(.caption).foregroundStyle(.secondary)
                .padding(.bottom,18)
        }
        .background(Color(red:0.055,green:0.063,blue:0.075).ignoresSafeArea())
    }
}
