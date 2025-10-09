import Combine
import Foundation
import SwiftUI

protocol ImagesInteractor {
    func load(image: LoadableSubject<UIImage>, url: URL?)
}

struct RealImagesInteractor: ImagesInteractor {
    let webRepository: ImagesWebRepository

    init(webRepository: ImagesWebRepository) {
        self.webRepository = webRepository
    }

    func load(image: LoadableSubject<UIImage>, url: URL?) {
        guard let url else {
            image.wrappedValue = .notRequested; return
        }
        image.load {
            try await webRepository.loadImage(url: url)
        }
    }
}

struct StubImagesInteractor: ImagesInteractor {
    func load(image _: LoadableSubject<UIImage>, url _: URL?) {}
}
