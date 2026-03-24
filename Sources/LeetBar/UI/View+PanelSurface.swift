import SwiftUI

extension View {
    @ViewBuilder
    func panelSurface(cornerRadius: CGFloat, interactive: Bool = false) -> some View {
        if #available(macOS 26.0, *) {
            if interactive {
                self.glassEffect(
                    .regular.interactive(),
                    in: .rect(cornerRadius: cornerRadius, style: .continuous)
                )
            } else {
                self.glassEffect(
                    .regular,
                    in: .rect(cornerRadius: cornerRadius, style: .continuous)
                )
            }
        } else {
            self.background(
                .regularMaterial,
                in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            )
        }
    }
}
