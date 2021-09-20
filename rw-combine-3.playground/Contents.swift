import Foundation
import Combine

print("Running...")
print("")

var subscriptions: Set<AnyCancellable> = []

runThis("collect") {
    [0, 1, 2, 3, 4, 5].publisher
        .collect(3)
        .sink { completion in
            print("Completed with \(completion)")
        } receiveValue: { number in
            print("Number: \(number)")
        }
        .store(in: &subscriptions)
}

runThis("map") {
    ["0", "1", "2"].publisher
        .map { numberString in
            return Int(numberString)
        }
        .sink { completion in
            print("Completed with \(completion)")
        } receiveValue: { number in
            print("Transformed number: \(String(describing: number))")
        }
        .store(in: &subscriptions)
}

runThis("map key paths") {
    let subject = PassthroughSubject<PlotPoint, Never>()

    subject
        .map(\.x, \.y)
        .sink { x, y in
            let graphSpot = graphsSpot(x: x, y: y)

            print("The plot (\(x), \(y)), is at: \(graphSpot)")
        }
        .store(in: &subscriptions)

    subject.send(PlotPoint(x: 99, y: 99))
    subject.send(PlotPoint(x: 5, y: -2))
    subject.send(PlotPoint(x: -3, y: 3))
    subject.send(PlotPoint(x: -4, y: -2))
}

runThis("tryMap") {
    Just("Humbug")
        .tryMap { string in
            let url = URL(string: string)!

            try Data(contentsOf: url)
        }
        .sink { completion in
            print("Completed with \(completion)")
        } receiveValue: { data in
            print("Data: \(data)")
        }
        .store(in: &subscriptions)

}

runThis("flatMap") {
    func decodeASCIICodes(_ codes: [Int]) -> AnyPublisher<String, Never> {
        Just(
            codes
                .compactMap { code in
                    guard (32...255).contains(code) else { return nil}

                    return String(UnicodeScalar(code) ?? " ")
                }
                .joined()
        )
        .eraseToAnyPublisher()
    }

    [66, 101, 32, 115, 117, 114, 101, 32, 116, 111, 32, 100, 114, 105,
     110, 107, 32, 121, 111, 117, 114, 32, 79, 118, 97, 108, 116, 105,
     110, 101]
        .publisher
        .collect()
        .flatMap(decodeASCIICodes)
        .sink { completion in
            print("Completed with \(completion)")
        } receiveValue: { decodedASCII in
            // It isn't "Be sure to drink your ovaltine

            print("Little orphan Annie says: \(decodedASCII)")
        }
        .store(in: &subscriptions)
}

runThis("replaceNil") {
    ["0", nil, "2"]
        .publisher
        .eraseToAnyPublisher()
        .replaceNil(with: "@#$%")
        .collect()
        .sink { completion in
            print("Completed with \(completion)")
        } receiveValue: { string in
            print("String: \(string)")
        }
        .store(in: &subscriptions)
}

runThis("replaceEmpty") {
    let empty = Empty<Int, Never>()

    empty
        .replaceEmpty(with: -99)
        .sink { completion in
            print("Completed with \(completion)")
        } receiveValue: { string in
            print("Empty: \(string)")
        }
        .store(in: &subscriptions)
}

runThis("scan") {
    (0..<10)
        .map { _ in
            return Int.random(in: -5...5)
        }
        .publisher
        .scan(50) { old, new in
            return max(0, old + new)
        }
        .sink { number in
            print("Here is your transformed bidness: \(number)")
        }
        .store(in: &subscriptions)
}

print("EL FIN")
print("")
