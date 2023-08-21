import Combine

public extension Publisher {
    static func createJust<T, E: Error>(value: T) -> AnyPublisher<T, E> {
        Just(value).setFailureType(to: E.self).eraseToAnyPublisher()
    }
}
