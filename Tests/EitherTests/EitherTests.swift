@testable import Either
import XCTest

private let stringLength: (String) -> Int = { string in string.count }

private extension String {
    var isNotEmpty: Bool { !isEmpty }
}

private enum FakeError: LocalizedError, Equatable {
    case testError
    case anotherError

    var errorDescription: String? {
        switch self {
        case .testError:
            return "testError"
        case .anotherError:
            return "anotherError"
        }
    }
}

private func toStringThrowing<A>(_ value: A) throws -> String {
    throw FakeError.testError
}

final class EitherTests: XCTestCase {
    func testLeftAndRight() {
        // given
        var either = Either<String, String>.left(name)
        // then
        XCTAssertTrue(either.isLeft)
        XCTAssertFalse(either.isRight)
        XCTAssertNil(either.right)
        XCTAssertEqual(name, either.left)
        // when
        either = either.orElse(.right(name))
        // then
        XCTAssertTrue(either.isRight)
        XCTAssertFalse(either.isLeft)
        XCTAssertNil(either.left)
        XCTAssertEqual(name, either.right)
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

    func testFmap() {
        // given
        let eitherString = Either<FakeError, String>.right(name)
        // when
        let eitherInt = fmap(stringLength, eitherString)
        // then
        XCTAssertTrue((eitherInt as Any) is Either<FakeError, Int>)
        XCTAssertEqual(name.count, eitherInt.right)
    }

    func testFmapByKeyPath() {
        // given
        let eitherString = Either<FakeError, String>.right(name)
        // when
        let eitherInt = fmap(\String.count, eitherString)
        // then
        XCTAssertTrue((eitherInt as Any) is Either<FakeError, Int>)
        XCTAssertEqual(name.count, eitherInt.right)
    }

    func testMapError() {
        // given
        let either: Either<FakeError, String> = .left(.testError)
        // when
        let either2 = either.mapError { _ in FakeError.anotherError }
        // then
        XCTAssertNotEqual(either, either2)
        XCTAssertEqual(FakeError.anotherError, either2.left)
    }

    func testMapErrorByKeyPath() {
        // given
        let either: Either<FakeError, String> = .left(.testError)
        // when
        let either2 = either.mapError(\.localizedDescription)
        // then
        XCTAssertEqual("testError", either2.left)
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

    func testApply() {
        // given
        let stringLenghtKeyPath = \String.count
        let stringLenght: (String) -> Int = { $0[keyPath: stringLenghtKeyPath] /* same as `$0.count` */ }
        let eitherString: Either<FakeError, String> = pure(name)
        let eitherStringError: Either<FakeError, String> = .error(.testError)
        // when
        let eitherStringLenght = apply(pure(stringLenght), eitherString)
        let eitherStringLenghtError = apply(pure(stringLenght), eitherStringError)
        let eitherStringLenghtKeyPath = apply(pure(stringLenghtKeyPath), eitherString)
        // then
        XCTAssertEqual(name.count, eitherStringLenght.right)
        XCTAssertEqual(name.count, eitherStringLenghtKeyPath.right)
        XCTAssertEqual(FakeError.testError, eitherStringLenghtError.left)
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

    func testFlatMapError() {
        // given
        let either: Either<FakeError, String> = .left(.testError)
        // when
        let either2 = either.flatMapError { _ in .left(FakeError.anotherError) }
        // then
        XCTAssertNotEqual(either, either2)
        XCTAssertEqual(FakeError.anotherError, either2.left)
    }

    func testFlatten() {
        // given
        let eitherLeft: Either<String, Either<String, Int>> = .left(name)
        let eitherRightLeft: Either<String, Either<String, Int>> = .right(.left(name))
        let eitherRightRight: Either<String, Either<String, Int>> = .right(.right(0))
        // when
        let flattenedEitherLeft = eitherLeft.flatten()
        let flattenedEitherRightLeft = eitherRightLeft.flatten()
        let flattenedEitherRightRight = eitherRightRight.flatten()
        // then
        XCTAssertEqual(flattenedEitherLeft, flattenedEitherRightLeft)
        XCTAssertNotEqual(flattenedEitherRightLeft, flattenedEitherRightRight)
        // then
        XCTAssertTrue((flattenedEitherLeft as Any) is Either<String, Int>)
        XCTAssertTrue((flattenedEitherRightLeft as Any) is Either<String, Int>)
        XCTAssertTrue((flattenedEitherRightRight as Any) is Either<String, Int>)
        // then
        XCTAssertEqual(name, flattenedEitherLeft.left)
        XCTAssertEqual(name, flattenedEitherRightLeft.left)
        XCTAssertEqual(0, flattenedEitherRightRight.right)
    }

    func testJoinRight() {
        // given
        let eitherLeft: Either<String, Either<String, Int>> = .left(name)
        let eitherRightLeft: Either<String, Either<String, Int>> = .right(.left(name))
        let eitherRightRight: Either<String, Either<String, Int>> = .right(.right(0))
        // when
        let rightJoinedEitherLeft = eitherLeft.joinRight()
        let rightJoinedEitherRightLeft = eitherRightLeft.joinRight()
        let rightJoinedEitherRightRight = eitherRightRight.joinRight()
        // then
        XCTAssertEqual(rightJoinedEitherLeft, rightJoinedEitherRightLeft)
        XCTAssertNotEqual(rightJoinedEitherRightLeft, rightJoinedEitherRightRight)
        // then
        XCTAssertTrue((rightJoinedEitherLeft as Any) is Either<String, Int>)
        XCTAssertTrue((rightJoinedEitherRightLeft as Any) is Either<String, Int>)
        XCTAssertTrue((rightJoinedEitherRightRight as Any) is Either<String, Int>)
        // then
        XCTAssertEqual(name, rightJoinedEitherLeft.left)
        XCTAssertEqual(name, rightJoinedEitherRightLeft.left)
        XCTAssertEqual(0, rightJoinedEitherRightRight.right)
    }

    func testJoinLeft() {
        // given
        let eitherRight: Either<Either<String, Int>, Int> = .right(0)
        let eitherLeftLeft: Either<Either<String, Int>, Int> = .left(.left(name))
        let eitherLeftRight: Either<Either<String, Int>, Int> = .left(.right(0))
        // when
        let leftJoinedEitherRight = eitherRight.joinLeft()
        let leftJoinedEitherLeftLeft = eitherLeftLeft.joinLeft()
        let leftJoinedEitherLeftRight = eitherLeftRight.joinLeft()
        // then
        XCTAssertEqual(leftJoinedEitherRight, leftJoinedEitherLeftRight)
        XCTAssertNotEqual(leftJoinedEitherLeftLeft, leftJoinedEitherLeftRight)
        // then
        XCTAssertTrue((leftJoinedEitherRight as Any) is Either<String, Int>)
        XCTAssertTrue((leftJoinedEitherLeftLeft as Any) is Either<String, Int>)
        XCTAssertTrue((leftJoinedEitherLeftRight as Any) is Either<String, Int>)
        // then
        XCTAssertEqual(0, leftJoinedEitherRight.right)
        XCTAssertEqual(name, leftJoinedEitherLeftLeft.left)
        XCTAssertEqual(0, leftJoinedEitherLeftRight.right)
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

    func testMerge() {
        // given
        let either = Either<String, String>.left(name)
        // then
        XCTAssertEqual(
            name,
            either.merge()
        )
        // then
        XCTAssertEqual(
            name,
            either
                .orElse(.right(name))
                .merge()
        )
    }

    func testIfThenElse() {
        // given
        let empty = ""
        // then
        XCTAssertEqual(
            Either<Int, String>.right(name),
            Either.if(empty.isEmpty, then: name, else: 1)
        )
        // then
        XCTAssertEqual(
            Either<Int, String>.left(1),
            Either.if(empty.isNotEmpty, then: name, else: 1)
        )
    }

    func testThen() {
        // given
        let either = Either<String, String>.left(name)
        let called = expectation(description: "called")
        let notCalled = expectation(description: "not called")
        // when
        notCalled.isInverted = true
        let either2 = either
            .then { _ in notCalled.fulfill() }
        // then
        wait(for: [notCalled], timeout: 0.1)
        XCTAssertEqual(either, either2)
        // when
        let either3 = either
            .orElse(.right(name))
            .then { _ in called.fulfill() }
        // then
        wait(for: [called], timeout: 0.1)
        XCTAssertNotEqual(either, either3)
    }

    func testError() {
        // given
        let either: Either<FakeError, String> = .error(.testError)
        let either2: Either<FakeError, String> = .left(.testError)
        // then
        XCTAssertEqual(either, either2)
    }

    func testPartitionMap() {
        // given
        let numbers = (1 ... 10).map(id)
        // when
        let partition = numbers
            .partitionMap { number in
                Either.if(number > 5, then: number, else: number)
            }
        // then
        XCTAssertEqual([1, 2, 3, 4, 5], partition.lefts)
        XCTAssertEqual([6, 7, 8, 9, 10], partition.rights)
    }

    func testPartition() {
        // given
        let numbers = (1 ... 10).map(id)
        // when
        let partition = numbers
            .partition { $0 > 5 }
        // then
        XCTAssertEqual([1, 2, 3, 4, 5], partition.failed)
        XCTAssertEqual([6, 7, 8, 9, 10], partition.passed)
    }

    func testPartitioned() {
        // given
        let eithers = (1 ... 10)
            .map { number in
                Either.if(number > 5, then: number, else: number)
            }
        // when
        let partition = eithers.partitioned()
        // then
        XCTAssertEqual([1, 2, 3, 4, 5], partition.lefts)
        XCTAssertEqual([6, 7, 8, 9, 10], partition.rights)
    }

    func testPartitionLeftsAndRights() {
        // given
        let eithers = (1 ... 10)
            .map { number in
                Either.if(number > 5, then: number, else: number)
            }
        // when
        let lefts = eithers.lefts()
        let rights = eithers.rights()
        // then
        XCTAssertEqual([1, 2, 3, 4, 5], lefts)
        XCTAssertEqual([6, 7, 8, 9, 10], rights)
    }

    func testHashable() {
        // given
        let lefts = (1 ... 5)
            .map { _ in Either.if(false, then: name, else: 0) }
        let rights = (1 ... 5)
            .map { _ in Either.if(true, then: name, else: 0) }
        // when
        let set = Set([lefts, rights].flatMap(id))
        // then
        XCTAssertEqual(2, set.count)
        XCTAssertTrue(set.contains(.left(0)))
        XCTAssertTrue(set.contains(.right(name)))
    }
}
