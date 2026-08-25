import Foundation

/// A type-erased `Encodable` value that forwards encoding to the wrapped instance.
///
/// Used for heterogeneous GraphQL variable dictionaries.
struct AnyEncodable: Encodable {
    /// The type-erased encode closure of the wrapped value.
    private let _encode: (Encoder) throws -> Void

    /// Wraps any `Encodable` value.
    /// - Parameter wrapped: The value to type-erase.
    init(_ wrapped: Encodable) {
        _encode = { encoder in
            try wrapped.encode(to: encoder)
        }
    }

    /// Encodes the wrapped value using its own implementation.
    func encode(to encoder: Encoder) throws {
        try _encode(encoder)
    }
}
