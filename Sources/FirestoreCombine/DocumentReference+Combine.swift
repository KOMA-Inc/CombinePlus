import Combine
import FirebaseFirestore

enum FirestoreError: Error {
    case nilResultError
}

public extension DocumentReference {

    struct Publisher: Combine.Publisher {

        public typealias Output = DocumentSnapshot
        public typealias Failure = Error

        private let documentReference: DocumentReference
        private let includeMetadataChanges: Bool

        init(_ documentReference: DocumentReference, includeMetadataChanges: Bool) {
            self.documentReference = documentReference
            self.includeMetadataChanges = includeMetadataChanges
        }

        public func receive<S>(subscriber: S) where
        S: Subscriber,
        Publisher.Failure == S.Failure,
        Publisher.Output == S.Input {

            let subscription = DocumentSnapshot.Subscription(
                subscriber: subscriber,
                documentReference: documentReference,
                includeMetadataChanges: includeMetadataChanges
            )
            subscriber.receive(subscription: subscription)
        }
    }

    func publisher(includeMetadataChanges: Bool = true) -> AnyPublisher<DocumentSnapshot, Error> {
        Publisher(self, includeMetadataChanges: includeMetadataChanges)
            .eraseToAnyPublisher()
    }

    func getDocument(source: FirestoreSource = .default) -> AnyPublisher<DocumentSnapshot, Error> {
           Future<DocumentSnapshot, Error> { [weak self] promise in
               self?.getDocument(source: source, completion: { snapshot, error in
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

extension DocumentSnapshot {

    fileprivate final class Subscription<SubscriberType: Subscriber>: Combine.Subscription where
    SubscriberType.Input == DocumentSnapshot,
    SubscriberType.Failure == Error {

        private var registration: ListenerRegistration?

        init(
            subscriber: SubscriberType,
            documentReference: DocumentReference,
            includeMetadataChanges: Bool
        ) {

            registration = documentReference.addSnapshotListener(
                includeMetadataChanges: includeMetadataChanges
            ) { snapshot, error in
                if let error = error {
                    subscriber.receive(completion: .failure(error))
                } else if let snapshot = snapshot {
                    _ = subscriber.receive(snapshot)
                } else {
                    subscriber.receive(completion: .failure(FirestoreError.nilResultError))
                }
            }
        }

        func request(_ demand: Subscribers.Demand) {
            // We do nothing here as we only want to send events when they occur.
            // See, for more info: https://developer.apple.com/documentation/combine/subscribers/demand
        }

        func cancel() {
            registration?.remove()
            registration = nil
        }
    }

}
