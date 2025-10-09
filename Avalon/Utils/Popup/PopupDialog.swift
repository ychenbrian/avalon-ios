import SwiftUI

struct Popup<DialogContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    var tapOutsideToDismiss: Bool = true
    var onDismiss: (() -> Void)? = nil
    @ViewBuilder var content: () -> DialogContent

    func body(content base: Content) -> some View {
        base
            .overlay {
                if isPresented {
                    ZStack {
                        // Backdrop
                        Color.black.opacity(0.35)
                            .ignoresSafeArea()
                            .onTapGesture {
                                guard tapOutsideToDismiss else { return }
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.9)) {
                                    isPresented = false
                                }
                                onDismiss?()
                            }
                            .accessibilityHidden(true)

                        // Dialog
                        dialog
                            .transition(.scale.combined(with: .opacity))
                            .accessibilityAddTraits(.isModal)
                    }
                    // Allow content to extend under keyboard so fields aren't pushed offscreen
                    .ignoresSafeArea(.keyboard, edges: .bottom)
                }
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.9), value: isPresented)
    }

    private var dialog: some View {
        VStack(spacing: 16) {
            content()
        }
        .padding(20)
        .frame(maxWidth: 480)
        .background(.ultraThinMaterial) // blur effect
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous)) // ensures corners cut out
        .shadow(radius: 24)
    }
}

extension View {
    func popup<DialogContent: View>(
        isPresented: Binding<Bool>,
        tapOutsideToDismiss: Bool = true,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> DialogContent
    ) -> some View {
        modifier(Popup(isPresented: isPresented,
                       tapOutsideToDismiss: tapOutsideToDismiss,
                       onDismiss: onDismiss,
                       content: content))
    }
}
