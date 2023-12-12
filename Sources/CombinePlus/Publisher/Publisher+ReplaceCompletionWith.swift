import Combine

public extension Publishers {

    final class ReplaceCompletion<Upstream: Publisher>: Publisher {

        public typealias Output = Upstream.Output
        public typealias Failure = Upstream.Failure

        private let upstream: Upstream
        private let output: Output

        init(upstream: Upstream, output: Output) {
            self.upstream = upstream
            self.output = output
        }

        public func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {

            let subscriber = ReplaceCompletionSubscriber(
                output: output,
                downstream: subscriber
            )
            upstream.subscribe(subscriber)
        }
    }
}

private extension Publishers.ReplaceCompletion {

    struct ReplaceCompletionSubscriber<S>: Subscriber where S: Subscriber, S.Input == Output, S.Failure == Failure {

        typealias Input = S.Input
        typealias Failure = S.Failure

        let output: Input
        let downstream: S

        let combineIdentifier = CombineIdentifier()

        func receive(subscription: Subscription) {
            downstream.receive(subscription: subscription)
        }

        func receive(_ input: S.Input) -> Subscribers.Demand {
            downstream.receive(input)
        }

        func receive(completion: Subscribers.Completion<S.Failure>) {
            _ = downstream.receive(output)
        }
    }
}

public extension Publisher {

    func replaceCompletion(with output: Output) -> AnyPublisher<Output, Never> {
        Publishers.ReplaceCompletion(upstream: self, output: output)
            .replaceError(with: output)
            .eraseToAnyPublisher()
    }
}
