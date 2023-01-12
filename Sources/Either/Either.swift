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
        guard case let .left(e) = self else {
            return nil
        }
        return e
    }

    /// It returns if there is a value on the left-hand side or not.
    public var isLeft: Bool { left != nil }

    /// It returns the value on the right-hand side if present.
    public var right: A? {
        guard case let .right(a) = self else {
            return nil
        }
        return a
    }

    /// It returns if there is a value on the right-hand side or not.
    public var isRight: Bool { right != nil }
}

// MARK: Sendable

extension Either: Sendable where E: Sendable, A: Sendable {}
