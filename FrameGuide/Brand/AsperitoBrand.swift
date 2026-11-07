import SwiftUI

enum AsperitoPalette {
    static let gold = Color("AsperitoGold")
    static let midnight = Color(red: 16.0/255, green: 21.0/255, blue: 29.0/255)
    static let graphite = Color(red: 29.0/255, green: 38.0/255, blue: 50.0/255)
    static let ivory = Color(red: 247.0/255, green: 243.0/255, blue: 234.0/255)
    static let mist = Color(red: 180.0/255, green: 191.0/255, blue: 202.0/255)
    static let focusCyan = Color(red: 115.0/255, green: 210.0/255, blue: 211.0/255)
    static let systemSurface = Color(uiColor: .secondarySystemBackground)
}

struct AsperitoWordmark: View {
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "viewfinder")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(AsperitoPalette.gold)
            Text("ASPERITO")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .tracking(2.2)
                .foregroundStyle(AsperitoPalette.ivory)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Asperito camera")
    }
}
