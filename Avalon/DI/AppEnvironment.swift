import SwiftData
import UIKit

@MainActor
struct AppEnvironment {
    let isRunningTests: Bool
    let diContainer: DIContainer
    let modelContainer: ModelContainer
    let systemEventsHandler: SystemEventsHandler
}

extension AppEnvironment {
    static func bootstrap() -> AppEnvironment {
        let appState = Store<AppState>(AppState())
        /*
          To see the deep linking in action:

          1. Launch the app in iOS 13.4 simulator (or newer)
          2. Subscribe on Push Notifications with "Allow Push" button
          3. Minimize the app
          4. Drag & drop "push_with_deeplink.apns" into the Simulator window
          5. Tap on the push notification

          Alternatively, just copy the code below before the "return" and launch:

             DispatchQueue.main.async {
                 deepLinksHandler.open(deepLink: .showCountryFlag(alpha3Code: "AFG"))
             }
         */
        let session = configuredURLSession()
        let webRepositories = configuredWebRepositories(session: session)
        let modelContainer = configuredModelContainer()
        let interactors = configuredInteractors(appState: appState, webRepositories: webRepositories)
        let diContainer = DIContainer(appState: appState, interactors: interactors)
        let deepLinksHandler = RealDeepLinksHandler(container: diContainer)
        let pushNotificationsHandler = RealPushNotificationsHandler(deepLinksHandler: deepLinksHandler)
        let systemEventsHandler = RealSystemEventsHandler(
            container: diContainer,
            deepLinksHandler: deepLinksHandler,
            pushNotificationsHandler: pushNotificationsHandler
        )
        return AppEnvironment(
            isRunningTests: ProcessInfo.processInfo.isRunningTests,
            diContainer: diContainer,
            modelContainer: modelContainer,
            systemEventsHandler: systemEventsHandler
        )
    }

    private static func configuredURLSession() -> URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 60
        configuration.timeoutIntervalForResource = 120
        configuration.waitsForConnectivity = true
        configuration.httpMaximumConnectionsPerHost = 5
        configuration.requestCachePolicy = .returnCacheDataElseLoad
        configuration.urlCache = .shared
        return URLSession(configuration: configuration)
    }

    private static func configuredModelContainer() -> ModelContainer {
        do {
            return try ModelContainer.appModelContainer()
        } catch {
            // Log the error
            return ModelContainer.stub
        }
    }

    private static func configuredWebRepositories(session: URLSession) -> DIContainer.WebRepositories {
        let images = RealImagesWebRepository(session: session)
        return .init(images: images)
    }

    private static func configuredInteractors(
        appState: Store<AppState>,
        webRepositories: DIContainer.WebRepositories
    ) -> DIContainer.Interactors {
        let images = RealImagesInteractor(webRepository: webRepositories.images)
        let userPermissions = RealUserPermissionsInteractor(
            appState: appState, openAppSettings: {
                URL(string: UIApplication.openSettingsURLString).flatMap {
                    UIApplication.shared.open($0, options: [:], completionHandler: nil)
                }
            }
        )

        return .init(images: images, userPermissions: userPermissions)
    }
}
