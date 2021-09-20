import Foundation
import UIKit
import Combine

print("Running...")
print("")

var subscriptions: Set<AnyCancellable> = []

runThis("prepend(Output)") {
    [3, 4]
        .publisher
        .prepend(1, 2)
        .prepend(-1, 0)
        .sink { number in
            print("Number: \(number)")
        }
        .store(in: &subscriptions)
}

runThis("prepend(Sequence)") {
    [5, 6, 7]
        .publisher
        .prepend([2, 3, 4])
        .prepend(Set(0...1))
        .prepend(stride(from: 6, to: 11, by: 2))
        .sink { number in
            print("Number: \(number)")
        }
        .store(in: &subscriptions)
}

runThis("prepend(Publisher)") {
    let pub1 = [3, 4].publisher
    let pub2 = [1, 2].publisher

    pub1
        .prepend(pub2)
        .sink { number in
            print("Number: \(number)")
        }
        .store(in: &subscriptions)
}

runThis("prepend(Publisher) - Part Dos") {
    let pub1 = [3, 4].publisher

    let pub2 = PassthroughSubject<Int, Never>()

    pub1
        .prepend(pub2)
        .sink { number in
            print("Number: \(number)")
        }
        .store(in: &subscriptions)

    pub2.send(1)
    pub2.send(2)
    pub2.send(completion: .finished)
}

runThis("append(Output)") {
    [-1, 0, 1]
        .publisher
        .append(2, 3)
        .append(4)
        .sink { number in
            print("Number: \(number)")
        }
        .store(in: &subscriptions)
}

runThis("append(Output) - Part Dos") {
    let subject = PassthroughSubject<Int, Never>()

    subject
        .append(3, 4)
        .append(5)
        .sink { number in
            print("Number: \(number)")
        }
        .store(in: &subscriptions)

    subject.send(1)
    subject.send(2)
    subject.send(completion: .finished)
}

runThis("append(Sequence)") {
    [1, 2, 3]
        .publisher
        .append([4, 5])
        .append(Set([6, 7]))
        .append(stride(from: 8, to: 11, by: 2))
        .sink { number in
            print("Number: \(number)")
        }
        .store(in: &subscriptions)
}

runThis("append(Publisher)") {
    let pub1 = [1, 2].publisher
    let pub2 = [3, 4].publisher

    pub1
        .append(pub2)
        .sink { number in
            print("Number: \(number)")
        }
        .store(in: &subscriptions)
}

runThis("switchToLatest") {
    let pub1 = PassthroughSubject<Int, Never>()
    let pub2 = PassthroughSubject<Int, Never>()
    let pub3 = PassthroughSubject<Int, Never>()

    let publishers = PassthroughSubject<PassthroughSubject<Int, Never>, Never>()

    publishers
        .switchToLatest()
        .sink { completion in
            print("Completed with \(completion)")
        } receiveValue: { number in
            print("Number: \(number)")
        }


    publishers.send(pub1)
    pub1.send(1)
    pub1.send(2)

    publishers.send(pub2)
    pub1.send(3)
    pub2.send(4)
    pub2.send(5)

    publishers.send(pub3)
    pub2.send(6)
    pub3.send(7)
    pub3.send(8)

    pub3.send(completion: .finished)
    publishers.send(completion: .finished)
}

runThis("switchToLatest - Dog API") {
    let randomURL = URL(string: "https://source.unsplash.com/random")!

    enum RandomError: Error {
        case booBoo
    }

    func getRandomImage() -> AnyPublisher<Result<UIImage, Error>, Never> {
        URLSession.shared
            .dataTaskPublisher(for: randomURL)
            .map { data, response in
                let image = UIImage(data: data)!

                return Result.success(image)
            }
            .print("image")
            .replaceError(with: Result.failure(RandomError.booBoo))
            .eraseToAnyPublisher()
    }

//    let taps = PassthroughSubject<Void, Never>()
//
//    taps
//        .map { _ in
//            return getRandomImage()
//        }
//        .switchToLatest()
//        .sink { completion in
//            print("Completed with \(completion)")
//        } receiveValue: { image in
//            print("Image: \(String(describing: image))")
//        }
//        .store(in: &subscriptions)
//
//
//    taps.send()
//
//    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//        taps.send()
//    }
//
//    DispatchQueue.main.asyncAfter(deadline: .now() + 3.1) {
//        taps.send()
//    }
}

runThis("merge(with)") {
    let pub1 = PassthroughSubject<Int, Never>()
    let pub2 = PassthroughSubject<Int, Never>()

    pub1
        .merge(with: pub2)
        .sink { completion in
            print("Completed with \(completion)")
        } receiveValue: { number in
            print("Number: \(number)")
        }
        .store(in: &subscriptions)

    pub1.send(1)
    pub1.send(2)

    pub2.send(3)

    pub1.send(4)
    pub1.send(6)

    pub1.send(completion: .finished)
    pub2.send(completion: .finished)
}

runThis("combineLatest") {
    let pub1 = PassthroughSubject<Int, Never>()
    let pub2 = PassthroughSubject<String, Never>()

    pub1
        .combineLatest(pub2)
        .sink { completion in
            print("Completed with \(completion)")
        } receiveValue: { latestTuple in
            print("Latest Tuple: \(latestTuple)")
        }

    pub1.send(-1)
    pub1.send(0)

    pub2.send("zero")
    pub2.send("one")

    pub1.send(1)

    pub1.send(completion: .finished)
    pub2.send(completion: .finished)
}

runThis("zip") {
    let pub1 = PassthroughSubject<Int, Never>()
    let pub2 = PassthroughSubject<String, Never>()

    pub1
        .zip(pub2)
        .sink { completion in
            print("Completed with \(completion)")
        } receiveValue: { latestTuple in
            print("Latest Tuple: \(latestTuple)")
        }

    pub1.send(-1)
    pub1.send(0)

    pub2.send("zero")
    pub2.send("one")

    pub1.send(1)
    pub2.send("2 weeks")

    pub1.send(completion: .finished)
    pub2.send(completion: .finished)
}

print("EL FIN")
print("")
