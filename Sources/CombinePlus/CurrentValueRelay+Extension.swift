import Combine

public extension CurrentValueRelay {
    func send(_ value: Output) {
        accept(value)
    }
}
