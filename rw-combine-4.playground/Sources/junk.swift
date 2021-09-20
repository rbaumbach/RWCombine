import Foundation

public func runThis(_ notes: String,
             completionHandler: () -> Void) {
    print("Running - \(notes)")
    print("---------------------------------")

    completionHandler()

    print("")
}
