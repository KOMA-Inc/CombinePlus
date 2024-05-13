import Combine
import FirebaseFirestore

public extension Query {

    struct Publisher: Combine.Publisher {

        public typealias Output = QuerySnapshot
        public typealias Failure = Error

        private let query: Query
        private let includeMetadataChanges: Bool

        init(_ query: Query, includeMetadataChanges: Bool) {
            self.query = query
            self.includeMetadataChanges = includeMetadataChanges
        }

        public func receive<S>(subscriber: S) where
        S: Subscriber,
        Publisher.Failure == S.Failure,
        Publisher.Output == S.Input {

            let subscription = QuerySnapshot.Subscription(
                subscriber: subscriber,
                query: query,
                includeMetadataChanges: includeMetadataChanges
            )
            subscriber.receive(subscription: subscription)
        }
    }

    func publisher(includeMetadataChanges: Bool = true) -> AnyPublisher<QuerySnapshot, Error> {
        Publisher(self, includeMetadataChanges: includeMetadataChanges)
            .eraseToAnyPublisher()
    }

    func getDocuments(source: FirestoreSource = .default) -> AnyPublisher<QuerySnapshot, Error> {
        Future<QuerySnapshot, Error> { [weak self] promise in
            self?.getDocuments(source: source, completion: { snapshot, error in
                if let error = error {
                    promise(.failure(error))
                } else if let snapshot = snapshot {
                    promise(.success(snapshot))
                } else {
                    promise(.failure(FirestoreError.nilResultError))
                }
            })
        }.eraseToAnyPublisher()
    }
}

extension QuerySnapshot {
    fileprivate final class Subscription<SubscriberType: Subscriber>: Combine.Subscription where
    SubscriberType.Input == QuerySnapshot,
    SubscriberType.Failure == Error {
        private var registration: ListenerRegistration?

        init(subscriber: SubscriberType, query: Query, includeMetadataChanges: Bool) {
            registration = query.addSnapshotListener(
                includeMetadataChanges: includeMetadataChanges
            ) { querySnapshot, error in
                if let error = error {
                    subscriber.receive(completion: .failure(error))
                } else if let querySnapshot = querySnapshot {
                    _ = subscriber.receive(querySnapshot)
                } else {
                    subscriber.receive(completion: .failure(FirestoreError.nilResultError))
                }
            }
        }

        func cancel() {
            registration?.remove()
            registration = nil
        }

        func request(_ demand: Subscribers.Demand) {
        }
    }
}
