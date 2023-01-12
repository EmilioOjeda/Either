import XCTest
@testable import Either

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
}
