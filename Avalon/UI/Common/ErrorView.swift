import SwiftUI

struct ErrorView: View {
    let error: Error
    let retryAction: () -> Void

    var body: some View {
        VStack {
            Text("error.view.title")
                .font(.title)
            Text(error.localizedDescription)
                .font(.callout)
                .multilineTextAlignment(.center)
                .padding(.bottom, 40).padding()
            Button(action: retryAction, label: { Text("error.view.retryButton").bold() })
        }
    }
}

#Preview {
    ErrorView(error: NSError(domain: "", code: 0, userInfo: [
        NSLocalizedDescriptionKey: "Something went wrong",
    ]),
    retryAction: {})
}
