import Combine

public extension Publisher {
    func track(action: @escaping (Self.Output) -> Void) -> Publishers.HandleEvents<Self> {
        handleEvents(receiveOutput: action)
    }
}
