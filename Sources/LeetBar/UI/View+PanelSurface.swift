import SwiftUI

extension View {
    @ViewBuilder
    func panelSurface(cornerRadius: CGFloat, interactive: Bool = false) -> some View {
        if #available(macOS 26, *) {
            if interactive {
                InteractiveGlassSurface(content: self, cornerRadius: cornerRadius)
            } else {
                StaticGlassSurface(content: self, cornerRadius: cornerRadius)
            }
        } else {
            self.background(.regularMaterial, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        }
    }
}

@available(macOS 26, *)
private struct InteractiveGlassSurface<Content: View>: View {
    let content: Content
    let cornerRadius: CGFloat

    var body: some View {
        content.glassEffect(.regular.interactive(), in: .rect(cornerRadius: cornerRadius))
    }
}

@available(macOS 26, *)
private struct StaticGlassSurface<Content: View>: View {
    let content: Content
    let cornerRadius: CGFloat

    var body: some View {
        content.glassEffect(.regular, in: .rect(cornerRadius: cornerRadius))
    }
}
