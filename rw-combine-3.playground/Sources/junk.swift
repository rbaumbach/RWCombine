import Foundation

public func runThis(_ notes: String,
             completionHandler: () -> Void) {
    print("Running - \(notes)")
    print("---------------------------------")

    completionHandler()

    print("")
}

public struct PlotPoint {
    public var x: Int
    public var y: Int

    public init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
}

public func graphsSpot(x: Int, y: Int) -> Int {
    if x < 0 {
        if y < 0 {
            return 3
        } else {
            return 2
        }
    } else {
        if y < 0 {
            return 4
        } else {
            return 1
        }
    }
}
