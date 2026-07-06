import SwiftUI

struct BouncyButtonStyle: ButtonStyle {
    var scale: CGFloat = 0.95

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

struct QRGenerationAnimation: ViewModifier {
    @State private var isVisible: Bool = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isVisible ? 1 : 0.5)
            .opacity(isVisible ? 1 : 0)
            .rotation3DEffect(
                .degrees(isVisible ? 0 : 180),
                axis: (x: 0, y: 1, z: 0)
            )
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    isVisible = true
                }
            }
    }
}

extension View {
    func qrGenerationAnimation() -> some View {
        modifier(QRGenerationAnimation())
    }

    func bouncyButton(scale: CGFloat = 0.95) -> some View {
        buttonStyle(BouncyButtonStyle(scale: scale))
    }
}
