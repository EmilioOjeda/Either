/// `Either` represents a value of one of two possible types (a disjoint union). An instance of `Either` is an instance of either `left` or `right`.
///
/// A common use of `Either` is as an alternative to `Optional` for dealing with possibly missing values.
/// In this usage, `Optional.none` is replaced with a `Either.left`, which can contain useful information; and a `Either.right` takes the place of `Optional.some`.
///
/// Another common use of `Either` is as an alternative to `Result` without strictly constraining the conformance to the `Error` protocol.
/// In this usage, `Result.failure` is replaced with a `Either.left`; and a `Either.right` takes the place of `Result.success`.
///
/// > Convention dictates that `Either.left` is used for failure and `Either.right` is used for success - but this is not mandatory.
public enum Either<E, A> {
    /// The value that is on the left-hand side.
    ///
    /// It usually represents a **failure**, but it may not always be the case.
    case left(E)

    /// The value that is on the right-hand side.
    ///
    /// It usually represents a **success**, but it may not always be the case.
    case right(A)

    // MARK: Left-hand side AND Right-hand side

    /// It returns the value on the left-hand side if present.
    public var left: E? {
        fold(id, { _ in .none })
    }

    /// It returns if there is a value on the left-hand side or not.
    public var isLeft: Bool { left != nil }

    /// It returns the value on the right-hand side if present.
    public var right: A? {
        fold({ _ in .none }, id)
    }

    /// It returns if there is a value on the right-hand side or not.
    public var isRight: Bool { right != nil }
}

func id<A>(_ a: A) -> A { a }

// MARK: Sendable

extension Either: Sendable where E: Sendable, A: Sendable {}

// MARK: Foldable

public extension Either {
    /// Indistinctly the case for having a value on either left-hand or right-hand sides, it folds both projections into a single type.
    ///
    /// It applies the `onLeft` function if this is a `left`, or the `onRight` function if this is a `right`.
    ///
    /// - Parameters:
    ///   - onLeft: The transformation function for the left-hand side.
    ///   - onRight: The transformation function for the right-hand side.
    /// - Returns: The folded value after applying the transformation for either case.
    func fold<Value>(
        _ onLeft: (E) throws -> Value,
        _ onRight: (A) throws -> Value
    ) rethrows -> Value {
        switch self {
        case let .left(leftValue):
            return try onLeft(leftValue)
        case let .right(rightValue):
            return try onRight(rightValue)
        }
    }

    /// Indistinctly the case for having a value on either left-hand or right-hand sides, it folds both projections into a single type.
    ///
    /// It zooms-in and get the value of the `onLeftKeyPath` if this is a `left`, or of the `onRightKeyPath` if this is a `right`.
    ///
    /// - Parameters:
    ///   - onLeftKeyPath: The key-path for the left-hand side.
    ///   - onRightKeyPath: The key-path for the right-hand side.
    /// - Returns: The folded value after getting it from the ket-path for either case.
    func fold<Value>(
        _ onLeftKeyPath: KeyPath<E, Value>,
        _ onRightKeyPath: KeyPath<A, Value>
    ) -> Value {
        switch self {
        case let .left(leftValue):
            return leftValue[keyPath: onLeftKeyPath]
        case let .right(rightValue):
            return rightValue[keyPath: onRightKeyPath]
        }
    }
}

// MARK: Equatable

extension Either: Equatable where E: Equatable, A: Equatable {
    /// It checks if the value on the left-hand side is equal to that on the right-hand side.
    /// - Parameters:
    ///   - lhs: Left-hand side value.
    ///   - rhs: Right-hand side value.
    /// - Returns: A boolean value that tells if values on both sides are equal.
    public static func == (lhs: Either, rhs: Either) -> Bool {
        switch (lhs, rhs) {
        case let (.left(lhsEValue), .left(rhsEValue)):
            return lhsEValue == rhsEValue
        case let (.right(lhsAValue), .right(rhsAValue)):
            return lhsAValue == rhsAValue
        case (.left, .right), (.right, .left):
            return false
        }
    }
}

public extension Either where A: Equatable {
    /// It checks if the value is contained/held on the right-hand side.
    /// - Parameter a: Value to evaluate for existence.
    /// - Returns: Whether the value is contained on the right-hand side or not.
    func contains(_ a: A) -> Bool {
        fold({ _ in false }, { $0 == a })
    }
}
