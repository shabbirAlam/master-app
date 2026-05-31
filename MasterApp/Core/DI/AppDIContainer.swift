import Foundation

struct AppDIContainer {
    let networking: Networking

    init(networking: Networking = NetworkingImpl()) {
        self.networking = networking
    }
}
