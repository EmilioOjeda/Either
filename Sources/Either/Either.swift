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
        fold(id) { _ in nil }
    }

    /// It returns if there is a value on the left-hand side or not.
    public var isLeft: Bool { left != nil }

    /// It returns the value on the right-hand side if present.
    public var right: A? {
        fold({ _ in nil }, Optional.some)
    }

    /// It returns if there is a value on the right-hand side or not.
    public var isRight: Bool { right != nil }

    /// It returns an `Either` value based on the result of the evaluation of the `condition`.
    ///
    /// If the `condition` is satisfied, it returns the given `then` (`pass`) in the right-hand side, otherwise, it return the given `else` (`fail`) in left-hand side.
    ///
    /// This is Swift's version of Scala's `cond` function:
    ///
    ///     /**
    ///      * Scala
    ///      */
    ///     def cond[A, B](test: Boolean, right: => B, left: => A): Either[A, B]
    ///
    /// - Parameters:
    ///   - condition: The condition to evaluate.
    ///   - pass: The value to set in the right-hand side.
    ///   - fail: The value to set in the left-hand side.
    /// - Returns: An `Either` value.
    public static func `if`(
        _ condition: @autoclosure () -> Bool,
        then pass: @autoclosure () -> A,
        else fail: @autoclosure () -> E
    ) -> Either {
        guard condition() else {
            return .left(fail())
        }
        return .right(pass())
    }
}

public extension Either where E: Swift.Error {
    /// It adds a syntactic-sugar function for setting errors.
    /// - Parameter error: The error to set to the left-hand side.
    /// - Returns: An `Either` value.
    static func error(_ error: E) -> Either {
        .left(error)
    }
}

// MARK: Effects

public extension Either {
    /// It executes the effect passed as functions when a value is on the right-hand side.
    /// - Parameter effect: The effect to execute.
    /// - Returns: An unchanged `Either` value.
    @discardableResult
    func then(
        _ effect: (A) throws -> Void
    ) rethrows -> Either {
        _ = try right.map(effect)
        return self
    }
}

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
        fold(
            { e in e[keyPath: onLeftKeyPath] },
            { a in a[keyPath: onRightKeyPath] }
        )
    }

    /// Indistinctly the case for having a value on either left-hand or right-hand sides, it folds both projections into a single type.
    ///
    /// It applies the `onLeft` function if this is a `left`, or gets the projected value on the right-hand side key-path.
    ///
    /// - Parameters:
    ///   - onLeft: The transformation function for the left-hand side.
    ///   - onRightKeyPath: The key-path for the right-hand side.
    /// - Returns: The folded value.
    func fold<Value>(
        _ onLeft: (E) throws -> Value,
        _ onRightKeyPath: KeyPath<A, Value>
    ) rethrows -> Value {
        try fold(onLeft, { a in a[keyPath: onRightKeyPath] })
    }

    /// Indistinctly the case for having a value on either left-hand or right-hand sides, it folds both projections into a single type.
    ///
    /// It gets the projected value on the left-hand side key-path if this is a `left`, or applies the `onRight` function.
    ///
    /// - Parameters:
    ///   - onLeftKeyPath: The key-path for the left-hand side.
    ///   - onRight: The transformation function for the right-hand side.
    /// - Returns: The folded value.
    func fold<Value>(
        _ onLeftKeyPath: KeyPath<E, Value>,
        _ onRight: (A) throws -> Value
    ) rethrows -> Value {
        try fold({ e in e[keyPath: onLeftKeyPath] }, onRight)
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

// MARK: Comparable

extension Either: Comparable where E: Comparable, A: Comparable {
    /// It compares if the left-hand side value is less than the right-hand side one.
    /// - Parameters:
    ///   - lhs: The left-hand side value to compare.
    ///   - rhs: The right-hand side value to compare.
    /// - Returns: Whether the left-hand side value is less than the right-hand side one or not.
    public static func < (lhs: Either, rhs: Either) -> Bool {
        switch (lhs, rhs) {
        case let (.left(lhsEValue), .left(rhsEValue)):
            return lhsEValue < rhsEValue
        case let (.right(lhsAValue), .right(rhsAValue)):
            return lhsAValue < rhsAValue
        case (.left, .right):
            return true
        case (.right, .left):
            return false
        }
    }
}

// MARK: Swappable

public extension Either {
    /// It swaps its sides. If this is a `.left`, it returns the left value in the `.right` or vice versa.
    /// - Returns: The swapped type.
    func swap() -> Either<A, E> {
        fold(Either<A, E>.right, Either<A, E>.left)
    }
}

// MARK: Mergeable

public extension Either where E == A {
    /// It allows a `merge` operation when both sides are of the same type.
    ///
    /// The most close Swift's implementation based on Scala's `MergeableEither[A]` constructor, would be when left and right hand sides are of the same type.
    /// This means that `Either<E, A>` is implicitely equals than `Either<A, A>`.
    ///
    /// - Returns: The value result of the `merge` operation.
    func merge() -> A {
        fold(id, id)
    }
}

// MARK: Functor

public extension Either {
    /// It applies the transformation function if there is a value on the right-hand side.
    /// - Parameter transform: Transformation function to apply.
    /// - Returns: A new either functor result of the mapping function.
    func map<B>(
        _ transform: (A) throws -> B
    ) rethrows -> Either<E, B> {
        try flatMap { a in pure(try transform(a)) }
    }

    /// It gets the nested value in the key-path if there is a value on the right-hand side.
    /// - Parameter keyPath: The key-path to read.
    /// - Returns: A new either functor result of the reading on the right-hand side value.
    func map<B>(
        _ keyPath: KeyPath<A, B>
    ) -> Either<E, B> {
        flatMap { a in pure(a[keyPath: keyPath]) }
    }
}

public extension Either where E: Swift.Error {
    /// It maps the error on the left-hand side.
    /// - Parameter transform: Transformation function to apply.
    /// - Returns: A new either functor result of the mapping function.
    func mapError<F>(
        _ transform: (E) -> F
    ) -> Either<F, A> {
        flatMapError { e in .left(transform(e)) }
    }

    /// It gets the nested value in the key-path if there is a value on the left-hand side.
    /// - Parameter keyPath: The key-path to read.
    /// - Returns: A new either functor result of the reading on the left-hand side value.
    func mapError<F>(
        _ keyPath: KeyPath<E, F>
    ) -> Either<F, A> {
        flatMapError { e in .left(e[keyPath: keyPath]) }
    }
}

// MARK: Bi-Functor

public extension Either {
    /// It allows doing `map` over both sides of the `Either` type.
    /// - Parameters:
    ///   - onLeft: The transformation function to apply to the left-hand side value.
    ///   - onRight: The transformation function to apply to the right-hand side value.
    /// - Returns: A rewrapped functor, result of the `bimap` operation.
    func bimap<F, B>(
        _ onLeft: (E) throws -> F,
        _ onRight: (A) throws -> B
    ) rethrows -> Either<F, B> {
        try fold(
            { e in .left(try onLeft(e)) },
            { a in .right(try onRight(a)) }
        )
    }

    /// It returns a new `Etiher` type, the result of inspecting and reading the key-paths on the projections for both sides.
    /// - Parameters:
    ///   - onLeftKeyPath: The key-path for the left-hand side.
    ///   - onRightKeyPath: The key-path for the right-hand side.
    /// - Returns: A rewrapped functor, result of the `bimap` operation.
    func bimap<F, B>(
        _ onLeftKeyPath: KeyPath<E, F>,
        _ onRightKeyPath: KeyPath<A, B>
    ) -> Either<F, B> {
        fold(
            { e in .left(e[keyPath: onLeftKeyPath]) },
            { a in .right(a[keyPath: onRightKeyPath]) }
        )
    }

    /// It allows either doing `map` over the left-hand side, or getting the value in the key-path for the projection on the right-hand side.
    /// - Parameters:
    ///   - onLeft: The transformation function to apply to the left-hand side value.
    ///   - onRightKeyPath: The key-path for the right-hand side.
    /// - Returns: A rewrapped functor, result of the `bimap` operation.
    func bimap<F, B>(
        _ onLeft: (E) throws -> F,
        _ onRightKeyPath: KeyPath<A, B>
    ) rethrows -> Either<F, B> {
        try fold(
            { e in .left(try onLeft(e)) },
            { a in .right(a[keyPath: onRightKeyPath]) }
        )
    }

    /// It allows either getting the value in the key-path for the projection on the left-hand side, or doing `map` over the right-hand side.
    /// - Parameters:
    ///   - onLeftKeyPath: The key-path for the left-hand side.
    ///   - onRight: The transformation function to apply to the right-hand side value.
    /// - Returns: A rewrapped functor, result of the `bimap` operation.
    func bimap<F, B>(
        _ onLeftKeyPath: KeyPath<E, F>,
        _ onRight: (A) throws -> B
    ) rethrows -> Either<F, B> {
        try fold(
            { e in .left(e[keyPath: onLeftKeyPath]) },
            { a in .right(try onRight(a)) }
        )
    }
}

// MARK: Monad

public extension Either {
    /// It binds the given function across the value on the right-hand side.
    /// - Parameter transform: The binding transformation function.
    /// - Returns: A new either functor result of the binding operation on the right-hand side value.
    func flatMap<B>(
        _ transform: (A) throws -> Either<E, B>
    ) rethrows -> Either<E, B> {
        try fold(Either<E, B>.left, transform)
    }
}

public extension Either where E: Swift.Error {
    /// It binds the given function across the error on the left-hand side.
    /// - Parameter transform: The binding transformation function.
    /// - Returns: A new either functor result of the binding operation on the left-hand side value.
    func flatMapError<F>(
        _ transform: (E) -> Either<F, A>
    ) -> Either<F, A> {
        fold(transform, Either<F, A>.right)
    }
}

// MARK: Getting Values

public extension Either {
    /// It allows setting a fallback value when nothing is on the right-hand side.
    /// - Parameter either: The fallback to resolve.
    /// - Returns: Either the current or the fallback.
    func orElse(_ either: Either) -> Either {
        fold({ _ in either }, pure)
    }

    /// It tries to get the value on the right-hand side if any, or it gives the `fallback` back.
    /// - Parameter fallback: The fallback value.
    /// - Returns: Either the value on the right-hand side or the given fallback value.
    func getOrElse(
        _ fallback: @autoclosure () throws -> A
    ) rethrows -> A {
        try fold({ _ in try fallback() }, id)
    }

    /// It tries to get the value on the right-hand side - if any value - or throws the error set.
    /// - Parameter error: The error to throw when there is no value on the right-hand side.
    /// - Returns: The value on the right-hand side, if any.
    func getOrThrow(
        _ error: @autoclosure () -> some Swift.Error
    ) throws -> A {
        try fold({ _ in throw error() }, id)
    }
}

public extension Either where E: Swift.Error {
    /// It throws the error hold on the left-hand side if there is no value on the right-hand side.
    /// - Returns: The value on the right-hand side, if any.
    func getOrThrow() throws -> A {
        try fold({ error in throw error }, id)
    }
}

// MARK: Filtering

public extension Either {
    /// It produces the value set when the one on the right-hand side does not match the predicate.
    ///
    /// It returns `.right` with the existing value if this is a `.right` and the given predicate holds for the value on the right-hand side,
    /// or `.left` if this is a `.right` and the given predicate does not hold for the value on the right-hand side,
    /// or `.left` with the existing value on the left-hand side.
    ///
    /// - Parameters:
    ///   - predicate: The predicate that is used to evaluate the value on the right-hand side.
    ///   - produce: The value to produce when the predicate does not hold for the value on the right-hand side.
    /// - Returns: Either a left or a right based on the evaluation of the predicate.
    func filter(
        by predicate: (A) throws -> Bool,
        or produce: @autoclosure () throws -> E
    ) rethrows -> Either<E, A> {
        switch self {
        case .left:
            return self
        case let .right(a):
            return try predicate(a)
                ? .right(a)
                : .left(produce())
        }
    }

    /// It produces the value set when the one on the right-hand side key-path does returns false.
    ///
    /// It returns `.right` with the existing value if this is a `.right` and the given key-path returns `true`,
    /// or `.left` if this is a `.right` and the given key-path returns `false`,
    /// or `.left` with the existing value on the left-hand side.
    ///
    /// - Parameters:
    ///   - keyPath: The boolean key-path to filter by.
    ///   - produce: The value to produce when the key-path returns false.
    /// - Returns: Either a left or a right based on the boolean value returned by the key-path.
    func filter(
        by keyPath: KeyPath<A, Bool>,
        or produce: @autoclosure () -> E
    ) -> Either<E, A> {
        switch self {
        case .left:
            return self
        case let .right(a):
            return a[keyPath: keyPath]
                ? .right(a)
                : .left(produce())
        }
    }
}

// MARK: Traversing

public extension Either where A: Sequence {
    /// It executes the given side-effecting function if a sequence is on the right-hand side.
    /// - Parameter effect: The side-effecting function to execute.
    func forEach(
        _ effect: (A.Element) throws -> Void
    ) rethrows {
        try fold({ _ in }, { a in try a.forEach(effect) })
    }

    /// It returns a boolean value indicating whether every element of a sequence on the right-hand side satisfies a given predicate.
    /// - Parameter predicate: The predicate for evaluating every element in the sequence.
    /// - Returns: The boolean result of the evaluation of the sequence.
    func forAll(
        _ predicate: (A.Element) throws -> Bool
    ) rethrows -> Bool {
        try fold({ _ in false }, { a in try a.allSatisfy(predicate) })
    }
}

// MARK: To Optional

public extension Either {
    /// It gets turned into `Optional`.
    ///
    /// - When `.left`, returns `nil`.
    /// - When `.right`, returns the value on the right-hand side.
    ///
    /// - Returns: An `Optional` type value.
    func toOptional() -> A? { right }
}

// MARK: To Result

public extension Either where E: Swift.Error {
    /// It gets turned into `Result`.
    ///
    /// - When `.left`, returns a `.failure` containing the error.
    /// - When `.right`, returns a `.success` holding the value on the right-hand side.
    ///
    /// - Returns: A `Result` type value.
    func toResult() -> Result<A, E> {
        fold(Result.failure, Result.success)
    }
}

// MARK: To Array

public extension Either {
    /// It gets turned into `Array`.
    ///
    /// - When `.left`, returns an empty array.
    /// - When `.right`, returns an array holding the value on the right-hand side.
    ///
    /// - Returns: An `Array` type value.
    func toArray() -> [A] {
        fold({ _ in [] }, { a in [a] })
    }
}

// MARK: CustomStringConvertible

extension Either: CustomStringConvertible {
    /// String representation of the Etiher's value.
    public var description: String {
        fold(
            { ".left(\(String(reflecting: $0)))" },
            { ".right(\(String(reflecting: $0)))" }
        )
    }
}

// MARK: CustomDebugStringConvertible

extension Either: CustomDebugStringConvertible {
    /// String representation of the Etiher's value for debugging purposes.
    public var debugDescription: String {
        fold(
            { "\(Self.self).left(\(String(reflecting: $0)))" },
            { "\(Self.self).right(\(String(reflecting: $0)))" }
        )
    }
}

// MARK: Debuggable

public extension Either {
    /// It prints the current Either's value to the Console - for debugging purposes.
    /// - Returns: The Either's value without any change/mutation.
    @discardableResult
    func debug() -> Either {
        print(debugDescription)
        return self
    }

    /// It allows prefixing any items to the Etiher's value before printing out to the Console - for debugging purposes.
    /// - Parameters:
    ///   - items: The items to prefix.
    ///   - separator: The separator to use among the items - **blank-space** is set by default.
    ///   - terminator: The debug string terminator - **end-of-line** is set by default.
    /// - Returns: The Either's value without any change/mutation.
    @discardableResult
    func debug(_ items: Any..., separator: String = " ", terminator: String = "\n") -> Either {
        print(items + [debugDescription], separator: separator, terminator: terminator)
        return self
    }
}

// MARK: Global Functions

func id<A>(_ a: A) -> A { a }

func pure<E, A>(_ a: A) -> Either<E, A> { .right(a) }
