import Foundation

/// Extension to validate URL strings.
extension URL {
    /// Returns true if the URL has a valid scheme and host.
    var isValid: Bool {
        return scheme != nil && host != nil
    }
}