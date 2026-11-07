import SwiftUI

struct OnboardingView: View {
    var onContinue: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Spacer(minLength: 12)
            Image("DirectorLogo")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 280)
                .accessibilityLabel("Film director framing a landscape with his hands")

            VStack(spacing: 8) {
                Text("ASPERITO")
                    .font(.system(.title3, design: .rounded, weight: .bold))
                    .tracking(3)
                    .foregroundStyle(AsperitoPalette.gold)
                Text("Compose. Learn. Capture.")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(AsperitoPalette.ivory)
                Text("12 live composition guides and short photography lessons to help you frame the perfect shot.")
                    .foregroundStyle(AsperitoPalette.mist)
                    .multilineTextAlignment(.center)
            }
            VStack(alignment: .leading, spacing: 15) {
                Label("Choose a composition guide", systemImage: "square.grid.3x3")
                Label("Learn to compose your shot", systemImage: "book.closed")
                Label("Save photos without guide lines", systemImage: "camera")
            }
            .font(.subheadline)
            .foregroundStyle(AsperitoPalette.ivory)
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AsperitoPalette.graphite, in: RoundedRectangle(cornerRadius: 18))
            Spacer(minLength: 12)
            Button(action: onContinue) {
                Text("Start photographing")
                    .font(.headline)
                    .frame(maxWidth: .infinity, minHeight: 48)
            }
            .buttonStyle(.borderedProminent)
            .tint(AsperitoPalette.gold)
            .foregroundStyle(AsperitoPalette.midnight)
            Text("Private by design · Works offline")
                .font(.caption)
                .foregroundStyle(AsperitoPalette.mist)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AsperitoPalette.midnight.ignoresSafeArea())
    }
}
