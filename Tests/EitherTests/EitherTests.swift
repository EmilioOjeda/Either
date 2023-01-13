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
}
