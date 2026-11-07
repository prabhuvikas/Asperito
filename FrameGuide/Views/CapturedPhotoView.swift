import SwiftUI
import UIKit

struct CapturedPhotoView: View {
    let image: UIImage
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            Image(uiImage:image)
                .resizable().scaledToFit()
                .frame(maxWidth:.infinity,maxHeight:.infinity)
            VStack {
                HStack {
                    Button { dismiss() } label: {
                        Label("Back to camera",systemImage:"chevron.left")
                            .padding(12).background(.black.opacity(0.55),in:Capsule())
                    }
                    Spacer()
                    Text("Saved to Photos")
                        .font(.caption).padding(12).background(.black.opacity(0.55),in:Capsule())
                }
                Spacer()
            }.padding()
        }
    }
}
