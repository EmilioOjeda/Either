# Either

----

> `Either` type implementation for Swift.

----

## Summary

> [Scala's Either](https://www.scala-lang.org/api/2.13.6/scala/util/Either.html) inspires the development of this Either type for Swift.

**Either** represents a value of one of two possible types (a disjoint union). An instance of `Either` is an instance of either `left` or `right`.

A common use of **Either** is as an alternative to **Optional** for dealing with possibly missing values. In this usage, `Optional.none` is replaced with a `Either.left`, which can contain useful information; and a `Either.right` takes the place of `Optional.some`.

Another common use of **Either** is as an alternative to **Result** without strictly constraining the conformance to the `Error` protocol. In this usage, `Result.failure` is replaced with a `Either.left`; and a `Either.right` takes the place of `Result.success`.

**_NOTE:_** Convention dictates that `Either.left` is used for failure and `Either.right` is used for success - but **this IS NOT mandatory**.

#### Basic Example

A pretty simple example of possible use for **Either** is a function that may fail or produce a result.

For example, let's say we are doing a **division** operation and have to get an error message when dividing by **0**.

```swift
typealias ErrorMessage = String

func divide<Number>(
    number dividend: Number,
    by divisor: Number
) -> Either<ErrorMessage, Number>
where Number: FloatingPoint {
    guard !divisor.isZero else {
        return .left("'\(dividend)' cannot be divided by '\(divisor)'")
    }
    return .right(dividend / divisor)
}

// ...

let eitherValue = divide(number: <some-number>, by: <divisor>)

switch eitherValue {
case let .left(errorMessage):
    presentErrorAlert(with: errorMessage) // '<some-number>' cannot be divided by '0.0'
case let .right(result):
    updateView(with: result)
}
```
