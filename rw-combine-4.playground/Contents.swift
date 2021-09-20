import Foundation
import Combine

print("Running...")
print("")

var subscriptions: Set<AnyCancellable> = []

runThis("filter") {
    let publisher = (1...10).publisher

    publisher
        .filter { number in
            return number.isMultiple(of: 3)
        }
        .sink { number in
            print("\(number) is a multiple of 3")
        }
        .store(in: &subscriptions)
}

runThis("removeDuplicates") {
    let words = "Junk junk junk dupy dupe thingy dupe"

    words
        .components(separatedBy: " ")
        .publisher
        .removeDuplicates()
        .sink { word in
            print("The word is: \(word)")
        }
        .store(in: &subscriptions)
}

runThis("compactMap") {
    let words = "1 2 3 four five 6 seven"

    words
        .components(separatedBy: " ")
        .publisher
        .compactMap { word in
            return Int(word)
        }
        .sink { number in
            print("We got a number: \(number)")
        }
        .store(in: &subscriptions)
}

runThis("ignoreOutput") {
    (1...1_000)
        .publisher
        .ignoreOutput()
        .sink { completion in
            print("Completed with \(completion)")
        } receiveValue: { number in
            print("Got number: \(number)")
        }
        .store(in: &subscriptions)
}

runThis("first(where)") {
    (1...9)
        .publisher
        .print()
        .first { number in
            return number % 2 == 0
        }
        .sink { number in
            print("\(number) is first even number!")
        }
        .store(in: &subscriptions)
}

runThis("last(where)") {
    let subject = PassthroughSubject<Int, Never>()

    subject
//        .print()
        .last { number in
            return number % 2 == 0
        }
        .sink { completion in
            print("Completed with \(completion)")
        } receiveValue: { number in
            print("\(number) is the last even number!")
        }
        .store(in: &subscriptions)

    subject.send(1)
    subject.send(2)
    subject.send(3)
    subject.send(4)
    subject.send(5)

    subject.send(completion: .finished)
}

runThis("dropFirst") {
    (1...10)
        .publisher
        .dropFirst(4)
        .sink { number in
            print("Number: \(number)")
        }
        .store(in: &subscriptions)
}

runThis("drop(while)") {
    (1...10)
        .publisher
        .drop { number in
            return number % 3 != 0
        }
        .sink { number in
            print("Number: \(number)")
        }
        .store(in: &subscriptions)
}

runThis("drop(untilOutputFrom)") {
    let isReadySubject = PassthroughSubject<Void, Never>()

    let tapsSubject = PassthroughSubject<Int, Never>()

    tapsSubject
        .drop(untilOutputFrom: isReadySubject)
        .sink { tap in
            print("Tap: \(tap)")
        }
        .store(in: &subscriptions)


    (1...5).forEach { number in
        tapsSubject.send(number)

        if number == 3 {
            isReadySubject.send()
        }
    }
}

runThis("prefix") {
    (1...10)
        .publisher
        .prefix(2)
        .sink { completion in
            print("Completed with completion")
        } receiveValue: { number in
            print("Got: \(number)")
        }
        .store(in: &subscriptions)
}

runThis("prefix(while)") {
    (1...10)
        .publisher
        .prefix { number in
            return number < 4
        }
        .sink { completion in
            print("Completed with \(completion)")
        } receiveValue: { number in
            print("Got: \(number)")
        }
        .store(in: &subscriptions)
}

runThis("prefix(untilOutputFrom)") {
    let isReadySubject = PassthroughSubject<Void, Never>()

    let tapsSubject = PassthroughSubject<Int, Never>()

    tapsSubject
        .prefix(untilOutputFrom: isReadySubject)
        .sink { tap in
            print("Tap: \(tap)")
        }
        .store(in: &subscriptions)

    (1...5).forEach { number in
        tapsSubject.send(number)

        if number == 5 {
            isReadySubject.send()
        }
    }
}

print("EL FIN")
print("")
