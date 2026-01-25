import Foundation
import SwiftUI

// ##################################################################
// Configuration
// Manages user preferences with persistence via UserDefaults
final class Configuration: ObservableObject {
    private static let thresholdKey = "memoryThresholdGB"
    private static let defaultThresholdGB = 50

    @Published var thresholdGB: Int {
        didSet {
            UserDefaults.standard.set(thresholdGB, forKey: Self.thresholdKey)
        }
    }

    var thresholdBytes: UInt64 {
        UInt64(thresholdGB) * 1024 * 1024 * 1024
    }

    // ##################################################################
    // init
    // Load saved threshold or use default
    init() {
        let saved = UserDefaults.standard.integer(forKey: Self.thresholdKey)
        self.thresholdGB = saved > 0 ? saved : Self.defaultThresholdGB
    }
}
