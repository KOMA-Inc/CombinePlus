import Combine

public extension Publisher where Output == Bool {
    func toggled() -> Publishers.Map<Self, Bool> {
       map { !$0 }
    }
}
