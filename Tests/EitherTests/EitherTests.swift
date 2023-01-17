import XCTest
@testable import Either

private let stringLength: (String) -> Int = { string in string.count }

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

    func testFoldOnLeftHandSideByKeyPath() {
        // given
        let leftHandSideString = name
        let leftHandSideEither: Either<String, Int> = .left(leftHandSideString)
        let leftHandSideStringLength = leftHandSideString.count
        // when
        let stringLength = leftHandSideEither.fold(\.count, \.self)
        // then
        XCTAssertTrue(leftHandSideEither.isLeft)
        XCTAssertEqual(stringLength, leftHandSideStringLength)
    }

    func testFoldOnRightHandSideByKeyPath() {
        // given
        let rightHandSideString = name
        let rightHandSideEither: Either<Int, String> = .right(rightHandSideString)
        let rightHandSideStringLength = rightHandSideString.count
        // when
        let stringLength = rightHandSideEither.fold(\.self, \.count)
        // then
        XCTAssertTrue(rightHandSideEither.isRight)
        XCTAssertEqual(stringLength, rightHandSideStringLength)
    }

    func testFoldOnLeftHandSideByFunctionMapping() {
        // given
        let leftHandSideString = name
        let leftHandSideEither: Either<String, Int> = .left(leftHandSideString)
        let leftHandSideStringLength = leftHandSideString.count
        // when
        let stringLength = leftHandSideEither.fold(stringLength, id)
        // then
        XCTAssertTrue(leftHandSideEither.isLeft)
        XCTAssertEqual(stringLength, leftHandSideStringLength)
    }

    func testFoldOnRightHandSideByFunctionMapping() {
        // given
        let rightHandSideString = name
        let rightHandSideEither: Either<Int, String> = .right(rightHandSideString)
        let rightHandSideStringLength = rightHandSideString.count
        // when
        let stringLength = rightHandSideEither.fold(id, stringLength)
        // then
        XCTAssertTrue(rightHandSideEither.isRight)
        XCTAssertEqual(stringLength, rightHandSideStringLength)
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
}
