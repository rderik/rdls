import XCTest

import rdlsTests

var tests = [XCTestCaseEntry]()
tests += rdlsTests.allTests()
XCTMain(tests)
