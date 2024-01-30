import Combine

public extension PassthroughRelay {
    func send(_ value: Output) {
        accept(value)
    }
}


