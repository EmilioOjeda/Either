@testable import Either
import XCTest

private let stringLength: (String) -> Int = { string in string.count }

private extension String {
    var isNotEmpty: Bool { !isEmpty }
}

private enum FakeError: Error, Equatable {
    case testError
}

private func toStringThrowing<A>(_ value: A) throws -> String {
    throw FakeError.testError
}

final class EitherTests: XCTestCase {
    func testLeftHandSide() throws {
        // given
        let leftHandSide: Either<String, String> = .left(name)
        // then
        XCTAssertTrue(leftHandSide.isLeft)
        XCTAssertNil(leftHandSide.right)
        XCTAssertEqual(name, leftHandSide.left)
    }

    func testRightHandSide() throws {
        // given
        let rightHandSide: Either<String, String> = .right(name)
        // then
        XCTAssertTrue(rightHandSide.isRight)
        XCTAssertNil(rightHandSide.left)
        XCTAssertEqual(name, rightHandSide.right)
    }

    func testFold() {
        // given
        let either = Either<Int, Double>.left(0)
        // then
        XCTAssertEqual(
            "0",
            either
                .fold(String.init(reflecting:), String.init(reflecting:))
        )
        // then
        XCTAssertEqual(
            "0.0",
            either
                .orElse(.right(0.0))
                .fold(String.init(reflecting:), String.init(reflecting:))
        )
        // then
        XCTAssertEqual(
            "0",
            either
                .fold(\Int.description, String.init(reflecting:))
        )
        // then
        XCTAssertEqual(
            "0.0",
            either
                .orElse(.right(0.0))
                .fold(\Int.description, String.init(reflecting:))
        )
        // then
        XCTAssertEqual(
            "0",
            either
                .fold(\Int.description, \Double.description)
        )
        // then
        XCTAssertEqual(
            "0.0",
            either
                .orElse(.right(0.0))
                .fold(\Int.description, \Double.description)
        )
        // then
        XCTAssertEqual(
            "0",
            either
                .fold(String.init(reflecting:), \Double.description)
        )
        // then
        XCTAssertEqual(
            "0.0",
            either
                .orElse(.right(0.0))
                .fold(String.init(reflecting:), \Double.description)
        )
    }

    func testEquatableForLeftHandSide() {
        // given
        let rightHandSideEither: Either<String, Int> = .right(0)
        let leftLeftHandSideEither: Either<String, Int> = .left(name)
        let rightLeftHandSideEither: Either<String, Int> = .left(name)
        // then
        XCTAssertTrue(rightHandSideEither != leftLeftHandSideEither)
        XCTAssertTrue(leftLeftHandSideEither == rightLeftHandSideEither)
    }

    func testEquatableForRightHandSide() {
        // given
        let leftHandSideEither: Either<Int, String> = .left(0)
        let leftRightHandSideEither: Either<Int, String> = .right(name)
        let rightRightHandSideEither: Either<Int, String> = .right(name)
        // then
        XCTAssertTrue(leftHandSideEither != leftRightHandSideEither)
        XCTAssertTrue(leftRightHandSideEither == rightRightHandSideEither)
    }

    func testContains() {
        // given
        let stringValue = "some string value"
        let anotherStringValue = "some other string value"
        // when
        let rightEither: Either<Int, String> = .right(stringValue)
        // then
        XCTAssertNotEqual(stringValue, anotherStringValue)
        XCTAssertTrue(rightEither.contains(stringValue))
        XCTAssertFalse(rightEither.contains(anotherStringValue))
        // when
        let leftEither: Either<String, String> = .left(stringValue)
        // then
        XCTAssertFalse(leftEither.contains(stringValue))
    }

    func testComparableForLeftHandSide() {
        // given
        let leftLeftHandSideEither: Either<Int, Int> = .left(0)
        let rightLeftHandSideEither: Either<Int, Int> = .left(1)
        // then
        XCTAssertLessThan(leftLeftHandSideEither, rightLeftHandSideEither)
        XCTAssertGreaterThan(rightLeftHandSideEither, leftLeftHandSideEither)
    }

    func testComparableForRightHandSide() {
        // given
        let leftRightHandSideEither: Either<Int, Int> = .right(0)
        let rightRightHandSideEither: Either<Int, Int> = .right(1)
        // then
        XCTAssertLessThan(leftRightHandSideEither, rightRightHandSideEither)
        XCTAssertGreaterThan(rightRightHandSideEither, leftRightHandSideEither)
    }

    func testComparableForLeftAgainstRight() {
        // given
        let leftEither: Either<Int, Int> = .left(0)
        let rightEither: Either<Int, Int> = .right(0)
        // then
        XCTAssertTrue(leftEither < rightEither)
        XCTAssertFalse(rightEither < leftEither)
    }

    func testMap() {
        // given
        let either = Either<String, String>.right(name)
        // when
        let eitherAfterMap = either.map(stringLength)
        // then
        XCTAssertEqual(name.count, eitherAfterMap.right)
    }

    func testMapByKeyPath() {
        // given
        let either = Either<String, String>.right(name)
        // when
        let eitherAfterMap = either.map(\String.count)
        // then
        XCTAssertEqual(name.count, eitherAfterMap.right)
    }

    func testBimapForLeftAndRightHandSidesFunctions() {
        // given
        let either = Either<Int, Int>.left(0)

        // when
        let either1 = either.bimap(String.init(reflecting:), String.init(reflecting:))
        // then
        XCTAssertTrue((either1 as Any) is Either<String, String>)

        // when
        let either2 = either.orElse(.right(0)).bimap(String.init(reflecting:), String.init(reflecting:))
        // then
        XCTAssertTrue((either2 as Any) is Either<String, String>)
    }

    func testBimapForLeftAndRightHandSidesKeyPaths() {
        // given
        let either = Either<Int, Int>.left(0)

        // when
        let either1 = either.bimap(\Int.description, \Int.description)
        // then
        XCTAssertTrue((either1 as Any) is Either<String, String>)

        // when
        let either2 = either.orElse(.right(0)).bimap(\Int.description, \Int.description)
        // then
        XCTAssertTrue((either2 as Any) is Either<String, String>)
    }

    func testBimapForLeftHandSideFunctionAndRightHandSideKeyPath() {
        // given
        let either = Either<Int, Int>.left(0)

        // when
        let either1 = either.bimap(String.init(reflecting:), \Int.description)
        // then
        XCTAssertTrue((either1 as Any) is Either<String, String>)

        // then
        XCTAssertThrowsError(try either.bimap(toStringThrowing(_:), \Int.description))

        // when
        let either2 = either.orElse(.right(0)).bimap(String.init(reflecting:), \Int.description)
        // then
        XCTAssertTrue((either2 as Any) is Either<String, String>)
    }

    func testBimapForLeftHandSideKeyPathAndRightHandSideFunction() {
        // given
        let either = Either<Int, Int>.left(0)

        // when
        let either1 = either.bimap(\Int.description, String.init(reflecting:))
        // then
        XCTAssertTrue((either1 as Any) is Either<String, String>)

        // when
        let either2 = either.orElse(.right(0)).bimap(\Int.description, String.init(reflecting:))
        // then
        XCTAssertTrue((either2 as Any) is Either<String, String>)

        // then
        XCTAssertThrowsError(try either.orElse(.right(0)).bimap(\Int.description, toStringThrowing(_:)))
    }

    func testFlatMap() {
        let getStringLength: (String) -> Either<String, Int?> = { string in .right(string.count) }
        // given
        let either: Either<String, String> = .right(name)
        // when
        let eitherAfterMap = either.flatMap(getStringLength)
        // then
        XCTAssertEqual(name.count, eitherAfterMap.right)
    }

    func testIsSwappable() {
        // given
        let eitherRight: Either<Int, String> = .right(name)
        // then
        XCTAssertTrue(eitherRight.isRight)
        // when
        let eitherAfterSwap = eitherRight.swap()
        // then
        XCTAssertTrue(eitherAfterSwap.isLeft)
        // when
        let eitherAfterSecondSwap = eitherAfterSwap.swap()
        // then
        XCTAssertTrue(eitherAfterSecondSwap.isRight)
        XCTAssertEqual(eitherRight, eitherAfterSecondSwap)
    }

    func testOrElse() {
        // given
        let givenEither: Either<String, String> = .right("right")
        let fallbackEither: Either<String, String> = .left("fallback")
        // when
        let rightEither = Either<String, String>.right("right").orElse(fallbackEither)
        // then
        XCTAssertEqual(givenEither, rightEither)
        // when
        let leftEither = Either<String, String>.left(name).orElse(fallbackEither)
        XCTAssertEqual(fallbackEither, leftEither)
    }

    func testGetOrElse() {
        // given
        let fallback = "Fallback"
        let eitherLeft: Either<Int, String> = .left(0)
        let eitherRight: Either<Int, String> = .right(name)
        // then
        XCTAssertNotEqual(name, fallback)
        XCTAssertEqual(name, eitherRight.getOrElse(fallback))
        XCTAssertEqual(fallback, eitherLeft.getOrElse(fallback))
    }

    func testGetOrThrow() throws {
        // given
        let fakeError: FakeError = .testError
        let eitherLeft: Either<FakeError, String> = .left(.testError)
        let eitherRight: Either<FakeError, String> = .right(name)
        // when
        do {
            _ = try eitherLeft.getOrThrow()
        } catch let error as FakeError {
            // then
            XCTAssertEqual(fakeError, error)
        } catch {
            XCTFail("It should not throw this error")
        }
        // when
        let value = try eitherRight.getOrThrow()
        // then
        XCTAssertEqual(name, value)
    }

    func testGetOrThrowError() throws {
        // given
        let fakeError: FakeError = .testError
        let eitherLeft: Either<Int, String> = .left(0)
        let eitherRight: Either<Int, String> = .right(name)
        // when
        do {
            _ = try eitherLeft.getOrThrow(fakeError)
        } catch let error as FakeError {
            // then
            XCTAssertEqual(fakeError, error)
        } catch {
            XCTFail("It should not throw this error")
        }
        // when
        let value = try eitherRight.getOrThrow(fakeError)
        XCTAssertEqual(name, value)
    }

    func testFilter() {
        // given
        let ten = 10
        let eleven = 11
        let failure = "failure"
        // then
        XCTAssertEqual(
            eleven,
            Either<String, Int>
                .right(eleven)
                .filter(by: { eleven in eleven > ten }, or: failure)
                .right
        )
        XCTAssertEqual(
            failure,
            Either<String, Int>
                .right(ten)
                .filter(by: { ten in ten > eleven }, or: failure)
                .left
        )
        XCTAssertEqual(
            name,
            Either<String, Int>
                .left(name)
                .filter(by: { eleven in eleven > ten }, or: failure)
                .left
        )
    }

    func testFilterByKeyPath() {
        // given
        let fallback = 0
        let nonEmptyString = "non empty string"
        // then
        XCTAssertEqual(
            nonEmptyString,
            Either<Int, String>
                .right(nonEmptyString)
                .filter(by: \.isNotEmpty, or: fallback)
                .right
        )
        XCTAssertEqual(
            fallback,
            Either<Int, String>
                .right(nonEmptyString)
                .filter(by: \.isEmpty, or: fallback)
                .left
        )
        XCTAssertEqual(
            fallback,
            Either<Int, String>
                .left(fallback)
                .filter(by: \.isEmpty, or: fallback.advanced(by: 1))
                .left
        )
    }

    func testForEach() {
        // given
        let array = [0, 1]
        let called = expectation(description: "called")
        called.expectedFulfillmentCount = array.count
        let notCalled = expectation(description: "not called")
        notCalled.isInverted = true
        let leftEither: Either<String, [Int]> = .left("not called")
        let rightEither: Either<String, [Int]> = .right(array)
        // when
        leftEither
            .forEach { _ in
                notCalled.fulfill()
            }
        rightEither
            .forEach { _ in
                called.fulfill()
            }
        // then
        wait(for: [notCalled, called], timeout: 0.2)
    }

    func testForAll() {
        let greaterThan10: (Int) -> Bool = { $0 > 10 }
        // given
        let assertingTrueArray = [11, 12]
        let assertingFalseArray = [10, 11]
        // then
        XCTAssertTrue(assertingTrueArray.allSatisfy(greaterThan10))
        XCTAssertFalse(assertingFalseArray.allSatisfy(greaterThan10))
        XCTAssertTrue(
            Either<String, [Int]>
                .right(assertingTrueArray)
                .forAll(greaterThan10)
        )
        XCTAssertFalse(
            Either<String, [Int]>
                .right(assertingFalseArray)
                .forAll(greaterThan10)
        )
        XCTAssertFalse(
            Either<String, [Int]>
                .left(name)
                .forAll(greaterThan10)
        )
    }

    func testToOptional() {
        // given
        let leftEither: Either<String, String> = .left(name)
        let rightEither: Either<String, String> = .right(name)
        // then
        XCTAssertNil(leftEither.toOptional())
        XCTAssertEqual(Optional.some(name), rightEither.toOptional())
    }

    func testToResult() {
        // given
        let leftEither: Either<FakeError, String> = .left(.testError)
        let rightEither: Either<FakeError, String> = .right(name)
        // then
        XCTAssertEqual(
            Result<String, FakeError>.failure(.testError),
            leftEither.toResult()
        )
        XCTAssertEqual(
            Result<String, FakeError>.success(name),
            rightEither.toResult()
        )
    }

    func testToArray() {
        // given
        let leftEither: Either<String, String> = .left(name)
        let rightEither: Either<String, String> = .right(name)
        // then
        XCTAssertEqual([], leftEither.toArray())
        XCTAssertEqual([name], rightEither.toArray())
    }

    func testDescriptionAndDebugDescription() {
        var eitherString: Either<String, String> = .left("test string")
        XCTAssertEqual(#".left("test string")"#, eitherString.description)
        XCTAssertEqual(#"Either<String, String>.left("test string")"#, eitherString.debugDescription)
        eitherString = eitherString.orElse(.right("test string"))
        XCTAssertEqual(#".right("test string")"#, eitherString.description)
        XCTAssertEqual(#"Either<String, String>.right("test string")"#, eitherString.debugDescription)

        var eitherInt: Either<Int, Int> = .left(3)
        XCTAssertEqual(#".left(3)"#, eitherInt.description)
        XCTAssertEqual(#"Either<Int, Int>.left(3)"#, eitherInt.debugDescription)
        eitherInt = eitherInt.orElse(.right(3))
        XCTAssertEqual(#".right(3)"#, eitherInt.description)
        XCTAssertEqual(#"Either<Int, Int>.right(3)"#, eitherInt.debugDescription)

        var eitherDouble: Either<Double, Double> = .left(4.0)
        XCTAssertEqual(#".left(4.0)"#, eitherDouble.description)
        XCTAssertEqual(#"Either<Double, Double>.left(4.0)"#, eitherDouble.debugDescription)
        eitherDouble = eitherDouble.orElse(.right(4.0))
        XCTAssertEqual(#".right(4.0)"#, eitherDouble.description)
        XCTAssertEqual(#"Either<Double, Double>.right(4.0)"#, eitherDouble.debugDescription)

        var eitherBool: Either<Bool, Bool> = .left(false)
        XCTAssertEqual(#".left(false)"#, eitherBool.description)
        XCTAssertEqual(#"Either<Bool, Bool>.left(false)"#, eitherBool.debugDescription)
        eitherBool = eitherBool.orElse(.right(true))
        XCTAssertEqual(#".right(true)"#, eitherBool.description)
        XCTAssertEqual(#"Either<Bool, Bool>.right(true)"#, eitherBool.debugDescription)
    }

    func testDebugFunctionsDoNotMutateTheValue() {
        // given
        let firstEither = Either<String, String>.right(name)
        // when
        let secondEither = firstEither.debug()
        // then
        XCTAssertEqual(firstEither, secondEither)
        // when
        let thirdEither = secondEither.debug("test")
        // then
        XCTAssertEqual(secondEither, thirdEither)
    }
}
