import Combine

public extension Publisher where Self.Output == Void, Self.Failure == Never {
    func sink(receiveValue: @escaping (() -> Void)) -> AnyCancellable {
        sink { _ in
            receiveValue()
        }
    }
}

public extension Publisher where Self.Output == Void {
    func sink(
        receiveCompletion: @escaping ((Subscribers.Completion<Self.Failure>) -> Void),
        receiveValue: @escaping (() -> Void)
    ) -> AnyCancellable {
        sink {
            receiveCompletion($0)
        } receiveValue: { _ in
            receiveValue()
        }
    }
}
