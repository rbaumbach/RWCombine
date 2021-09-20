import Foundation
import Combine

print("Running...")
print("")

var subscriptions: Set<AnyCancellable> = []

runThis("Notification Center") {
    let notification = Notification.Name("Hello Subscriber Notification Name")

    let publisher = NotificationCenter.default.publisher(for: notification)

    let subscription = publisher.sink { _ in
        print("Got notification!")
    }

    let notificationCenter = NotificationCenter.default

    notificationCenter.post(name: notification, object: nil)
    notificationCenter.post(name: notification, object: nil)

    subscription.cancel()
}

runThis("just?") {
    let justATaco = Just("Taco")

    _ = justATaco.sink { completion in
        print("Completed with \(completion)")
    } receiveValue: { value in
        print("Value \(value)")
    }

    _ = justATaco.sink { completion in
        print("Completed with \(completion)")
    } receiveValue: { value in
        print("Value \(value)")
    }

    let justAInt = Just(5)

    _ = justAInt.sink { completion in
        print("Completed with \(completion)")
    } receiveValue: { value in
        print("Value \(value)")
    }
}

runThis("assign (KVO)") {
    class Thingy {
        var number: Int = 99 {
            didSet {
                print("Updated Value to \(number)")
            }
        }
    }

    let thing = Thingy()

    print("Initial value of thing: \(thing.number)")

    _ = [1, 3, 5, 7].publisher.assign(to: \.number,
                                      on: thing)

    print("Final value of thing: \(thing.number)")
}

runThis("assign (KVO) - Take 2") {
    class Thingy {
        @Published var number = 0
    }

    let thing = Thingy()

    print("Initial value of thing: \(thing.number)")

    thing.$number.sink { number in
        print("Publishing \(number)")
    }

    (0..<5).publisher.assign(to: &thing.$number)

    print("Final value of thing: \(thing.number)")
}

runThis("Brand spanking new Subscriber") {
    let publisher = (0...5).publisher
//    let publisher = ["zero", "one", "two", "three", "four", "five"]

    class NumberSubscriber: Subscriber {
        typealias Input = Int

        typealias Failure = Never

        func receive(subscription: Subscription) {
            subscription.request(.max(3))
        }

        func receive(_ input: Int) -> Subscribers.Demand {
            print("Got: \(input)")

            // .none means only the .max(3) will be published

            return .none
//            return .unlimited
//            return .max(1)
        }

        func receive(completion: Subscribers.Completion<Never>) {
            print("Completed with \(completion)")
        }
    }

    let subscriber = NumberSubscriber()

    publisher.subscribe(subscriber)
}

runThis("El Future") {
    func increment(int: Int, after delay: TimeInterval) -> Future<Int, Never> {
        Future<Int, Never> { promise in
            print("Dispatching... after \(delay)")

            DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
                promise(.success(int + 1))
            }
        }
    }

//    let delay = 5.0
//
//    let future = increment(int: 99, after: delay)
//
//    future.sink { completion in
//        print("Completed with \(completion)")
//    } receiveValue: { number in
//        print("We got \(number) after \(delay)")
//    }
//    .store(in: &subscriptions)
//
//    future.sink { completion in
//        print("Completed (again) with \(completion)")
//    } receiveValue: { number in
//        print("We got (again) \(number) after \(delay)")
//    }
//    .store(in: &subscriptions)
}

runThis("PassthroughSubject (imperative code -> Combine)") {
    enum JunkError: Error {
        case yourAFailure
    }

    class IntSubscriber: Subscriber {
        typealias Input = Int
        typealias Failure = JunkError

        func receive(subscription: Subscription) {
            subscription.request(.max(2))
        }

        func receive(_ input: Int) -> Subscribers.Demand {
            print("Got: \(input)")

            return input == 1 ? .max(1) : .none
        }

        func receive(completion: Subscribers.Completion<JunkError>) {
            print("Completed with \(completion)")
        }
    }

    let subscriber = IntSubscriber()

    let subject = PassthroughSubject<Int, JunkError>()

    subject.subscribe(subscriber)

    let subscription = subject.sink { completion in
        print("Completed with \(completion) (subject sink)")
    } receiveValue: { number in
        print("Got: \(number) (subject sink)")
    }

    subject.send(0)
    subject.send(1)

    subscription.cancel()

    subject.send(99)

    subject.send(completion: .failure(.yourAFailure))
    subject.send(completion: .finished)
    subject.send(999)
}

runThis("CurrentValueSubject (Combine -> imperative code") {
    var moreSubscriptions: Set<AnyCancellable> = []

    let subject = CurrentValueSubject<Int, Never>(0)

    subject
        .print()
        .sink { number in
            print("Published \(number)")
        }
        .store(in: &moreSubscriptions)

    subject.send(1)
    subject.send(2)

    print("The subs value: \(subject.value)")

    subject.value = 3

    print("Moar value: \(subject.value)")

    subject
        .print()
        .sink { number in
            print("Published (Part Deux) \(number)")
        }
        .store(in: &moreSubscriptions)

    subject.send(completion: .finished)
}

runThis("Dynamic Demand") {
    class IntSubscriber: Subscriber {
        typealias Input = Int
        typealias Failure = Never

        func receive(subscription: Subscription) {
            subscription.request(.max(2))
        }

        func receive(_ input: Int) -> Subscribers.Demand {
            print("Received Int: \(input)")

            switch input {
            case 1:
                return .max(2)
            case 3:
                return .max(1)
            default:
                return .none
            }
        }

        func receive(completion: Subscribers.Completion<Never>) {
            print("Completed with \(completion)")
        }
    }

    let subscriber = IntSubscriber()

    let subject = PassthroughSubject<Int, Never>()

    subject.subscribe(subscriber)

    subject.send(1)
    subject.send(2)
    subject.send(3)
    subject.send(4)
    subject.send(5)
    subject.send(6)

}

runThis("Type Erasure - Sigh...") {
    let subject = PassthroughSubject<Int, Never>()

    let publisher = subject.eraseToAnyPublisher()

    publisher
        .sink { number in
            print("Number: \(number)")
        }
        .store(in: &subscriptions)

    subject.send(0)
}

print("EL FIN")
print("")
