import SwiftUI

extension View {
    func panelSurface(cornerRadius: CGFloat, interactive: Bool = false) -> some View {
        self.background(.regularMaterial, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}
