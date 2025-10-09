import Combine
import SwiftUI

// MARK: - RootViewAppearance

struct RootViewAppearance: ViewModifier {
    @Environment(\.injected) private var injected: DIContainer
    @State private var isActive: Bool = false
    let inspection = Inspection<Self>()

    func body(content: Content) -> some View {
        content
            .blur(radius: isActive ? 0 : 10)
            .ignoresSafeArea()
            .onReceive(stateUpdate) { self.isActive = $0 }
            .onReceive(inspection.notice) { self.inspection.visit(self, $0) }
    }

    private var stateUpdate: AnyPublisher<Bool, Never> {
        injected.appState.updates(for: \.system.isActive)
    }
}
