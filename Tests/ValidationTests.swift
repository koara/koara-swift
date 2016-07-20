//
//  ValidationTests.swift
//
//  Copyright (c) 2014-2016 Koara Software Foundation (http://Koara.org/)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

@testable import Koara
import Foundation
import XCTest

class StatusCodeValidationTestCase: BaseTestCase {
    func testThatValidationForRequestWithAcceptableStatusCodeResponseSucceeds() {
        // Given
        let URLString = "https://httpbin.org/status/200"
        let expectation = expectationWithDescription("request should return 200 status code")

        var error: NSError?

        // When
        Koara.request(.GET, URLString)
            .validate(statusCode: 200..<300)
            .response { _, _, _, responseError in
                error = responseError
                expectation.fulfill()
            }

        waitForExpectationsWithTimeout(timeout, handler: nil)

        // Then
        XCTAssertNil(error)
    }

    func testThatValidationForRequestWithUnacceptableStatusCodeResponseFails() {
        // Given
        let URLString = "https://httpbin.org/status/404"
        let expectation = expectationWithDescription("request should return 404 status code")

        var error: NSError?

        // When
        Koara.request(.GET, URLString)
            .validate(statusCode: [200])
            .response { _, _, _, responseError in
                error = responseError
                expectation.fulfill()
            }

        waitForExpectationsWithTimeout(timeout, handler: nil)

        // Then
        XCTAssertNotNil(error)

        if let error = error {
            XCTAssertEqual(error.domain, Error.Domain)
            XCTAssertEqual(error.code, Error.Code.StatusCodeValidationFailed.rawValue)
            XCTAssertEqual(error.userInfo[Error.UserInfoKeys.StatusCode] as? Int, 404)
        } else {
            XCTFail("error should not be nil")
        }
    }

    func testThatValidationForRequestWithNoAcceptableStatusCodesFails() {
        // Given
        let URLString = "https://httpbin.org/status/201"
        let expectation = expectationWithDescription("request should return 201 status code")

        var error: NSError?

        // When
        Koara.request(.GET, URLString)
            .validate(statusCode: [])
            .response { _, _, _, responseError in
                error = responseError
                expectation.fulfill()
            }

        waitForExpectationsWithTimeout(timeout, handler: nil)

        // Then
        XCTAssertNotNil(error)

        if let error = error {
            XCTAssertEqual(error.domain, Error.Domain)
            XCTAssertEqual(error.code, Error.Code.StatusCodeValidationFailed.rawValue)
            XCTAssertEqual(error.userInfo[Error.UserInfoKeys.StatusCode] as? Int, 201)
        } else {
            XCTFail("error should not be nil")
        }
    }
}

// MARK: -

class ContentTypeValidationTestCase: BaseTestCase {
    func testThatValidationForRequestWithAcceptableContentTypeResponseSucceeds() {
        // Given
        let URLString = "https://httpbin.org/ip"
        let expectation = expectationWithDescription("request should succeed and return ip")

        var error: NSError?

        // When
        Koara.request(.GET, URLString)
            .validate(contentType: ["application/json"])
            .validate(contentType: ["application/json;charset=utf8"])
            .validate(contentType: ["application/json;q=0.8;charset=utf8"])
            .response { _, _, _, responseError in
                error = responseError
                expectation.fulfill()
            }

        waitForExpectationsWithTimeout(timeout, handler: nil)

        // Then
        XCTAssertNil(error)
    }

    func testThatValidationForRequestWithAcceptableWildcardContentTypeResponseSucceeds() {
        // Given
        let URLString = "https://httpbin.org/ip"
        let expectation = expectationWithDescription("request should succeed and return ip")

        var error: NSError?

        // When
        Koara.request(.GET, URLString)
            .validate(contentType: ["*/*"])
            .validate(contentType: ["application/*"])
            .validate(contentType: ["*/json"])
            .response { _, _, _, responseError in
                error = responseError
                expectation.fulfill()
            }

        waitForExpectationsWithTimeout(timeout, handler: nil)

        // Then
        XCTAssertNil(error)
    }

    func testThatValidationForRequestWithUnacceptableContentTypeResponseFails() {
        // Given
        let URLString = "https://httpbin.org/xml"
        let expectation = expectationWithDescription("request should succeed and return xml")

        var error: NSError?

        // When
        Koara.request(.GET, URLString)
            .validate(contentType: ["application/octet-stream"])
            .response { _, _, _, responseError in
                error = responseError
                expectation.fulfill()
            }

        waitForExpectationsWithTimeout(timeout, handler: nil)

        // Then
        XCTAssertNotNil(error)

        if let error = error {
            XCTAssertEqual(error.domain, Error.Domain)
            XCTAssertEqual(error.code, Error.Code.ContentTypeValidationFailed.rawValue)
            XCTAssertEqual(error.userInfo[Error.UserInfoKeys.ContentType] as? String, "application/xml")
        } else {
            XCTFail("error should not be nil")
        }
    }

    func testThatValidationForRequestWithNoAcceptableContentTypeResponseFails() {
        // Given
        let URLString = "https://httpbin.org/xml"
        let expectation = expectationWithDescription("request should succeed and return xml")

        var error: NSError?

        // When
        Koara.request(.GET, URLString)
            .validate(contentType: [])
            .response { _, _, _, responseError in
                error = responseError
                expectation.fulfill()
            }

        waitForExpectationsWithTimeout(timeout, handler: nil)

        // Then
        XCTAssertNotNil(error, "error should not be nil")

        if let error = error {
            XCTAssertEqual(error.domain, Error.Domain)
            XCTAssertEqual(error.code, Error.Code.ContentTypeValidationFailed.rawValue)
            XCTAssertEqual(error.userInfo[Error.UserInfoKeys.ContentType] as? String, "application/xml")
        } else {
            XCTFail("error should not be nil")
        }
    }

    func testThatValidationForRequestWithNoAcceptableContentTypeResponseSucceedsWhenNoDataIsReturned() {
        // Given
        let URLString = "https://httpbin.org/status/204"
        let expectation = expectationWithDescription("request should succeed and return no data")

        var error: NSError?

        // When
        Koara.request(.GET, URLString)
            .validate(contentType: [])
            .response { _, response, data, responseError in
                error = responseError
                expectation.fulfill()
            }

        waitForExpectationsWithTimeout(timeout, handler: nil)

        // Then
        XCTAssertNil(error)
    }

    func testThatValidationForRequestWithAcceptableWildcardContentTypeResponseSucceedsWhenResponseIsNil() {
        // Given
        class MockManager: Manager {
            override func request(URLRequest: URLRequestConvertible) -> Request {
                var dataTask: NSURLSessionDataTask!

                dispatch_sync(queue) {
                    dataTask = self.session.dataTaskWithRequest(URLRequest.URLRequest)
                }

                let request = MockRequest(session: session, task: dataTask)
                delegate[request.delegate.task] = request.delegate

                if startRequestsImmediately {
                    request.resume()
                }

                return request
            }
        }

        class MockRequest: Request {
            override var response: NSHTTPURLResponse? {
                return MockHTTPURLResponse(
                    URL: NSURL(string: request!.URLString)!,
                    statusCode: 204,
                    HTTPVersion: "HTTP/1.1",
                    headerFields: nil
                )
            }
        }

        class MockHTTPURLResponse: NSHTTPURLResponse {
            override var MIMEType: String? { return nil }
        }

        let manager: Manager = {
            let configuration: NSURLSessionConfiguration = {
                let configuration = NSURLSessionConfiguration.ephemeralSessionConfiguration()
                configuration.HTTPAdditionalHeaders = Koara.Manager.defaultHTTPHeaders

                return configuration
            }()

            return MockManager(configuration: configuration)
        }()

        let URLString = "https://httpbin.org/delete"
        let expectation = expectationWithDescription("request should be stubbed and return 204 status code")

        var response: NSHTTPURLResponse?
        var data: NSData?
        var error: NSError?

        // When
        manager.request(.DELETE, URLString)
            .validate(contentType: ["*/*"])
            .response { _, responseResponse, responseData, responseError in
                response = responseResponse
                data = responseData
                error = responseError

                expectation.fulfill()
        }

        waitForExpectationsWithTimeout(timeout, handler: nil)

        // Then
        XCTAssertNotNil(response)
        XCTAssertNotNil(data)
        XCTAssertNil(error)

        if let response = response {
            XCTAssertEqual(response.statusCode, 204)
            XCTAssertNil(response.MIMEType)
        }
    }
}

// MARK: -

class MultipleValidationTestCase: BaseTestCase {
    func testThatValidationForRequestWithAcceptableStatusCodeAndContentTypeResponseSucceeds() {
        // Given
        let URLString = "https://httpbin.org/ip"
        let expectation = expectationWithDescription("request should succeed and return ip")

        var error: NSError?

        // When
        Koara.request(.GET, URLString)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .response { _, _, _, responseError in
                error = responseError
                expectation.fulfill()
            }

        waitForExpectationsWithTimeout(timeout, handler: nil)

        // Then
        XCTAssertNil(error)
    }

    func testThatValidationForRequestWithUnacceptableStatusCodeAndContentTypeResponseFailsWithStatusCodeError() {
        // Given
        let URLString = "https://httpbin.org/xml"
        let expectation = expectationWithDescription("request should succeed and return xml")

        var error: NSError?

        // When
        Koara.request(.GET, URLString)
            .validate(statusCode: 400..<600)
            .validate(contentType: ["application/octet-stream"])
            .response { _, _, _, responseError in
                error = responseError
                expectation.fulfill()
            }

        waitForExpectationsWithTimeout(timeout, handler: nil)

        // Then
        XCTAssertNotNil(error)

        if let error = error {
            XCTAssertEqual(error.domain, Error.Domain)
            XCTAssertEqual(error.code, Error.Code.StatusCodeValidationFailed.rawValue)
            XCTAssertEqual(error.userInfo[Error.UserInfoKeys.StatusCode] as? Int, 200)
        } else {
            XCTFail("error should not be nil")
        }
    }

    func testThatValidationForRequestWithUnacceptableStatusCodeAndContentTypeResponseFailsWithContentTypeError() {
        // Given
        let URLString = "https://httpbin.org/xml"
        let expectation = expectationWithDescription("request should succeed and return xml")

        var error: NSError?

        // When
        Koara.request(.GET, URLString)
            .validate(contentType: ["application/octet-stream"])
            .validate(statusCode: 400..<600)
            .response { _, _, _, responseError in
                error = responseError
                expectation.fulfill()
        }

        waitForExpectationsWithTimeout(timeout, handler: nil)

        // Then
        XCTAssertNotNil(error)

        if let error = error {
            XCTAssertEqual(error.domain, Error.Domain)
            XCTAssertEqual(error.code, Error.Code.ContentTypeValidationFailed.rawValue)
            XCTAssertEqual(error.userInfo[Error.UserInfoKeys.ContentType] as? String, "application/xml")
        } else {
            XCTFail("error should not be nil")
        }
    }
}

// MARK: -

class AutomaticValidationTestCase: BaseTestCase {
    func testThatValidationForRequestWithAcceptableStatusCodeAndContentTypeResponseSucceeds() {
        // Given
        let URL = NSURL(string: "https://httpbin.org/ip")!
        let mutableURLRequest = NSMutableURLRequest(URL: URL)
        mutableURLRequest.setValue("application/json", forHTTPHeaderField: "Accept")

        let expectation = expectationWithDescription("request should succeed and return ip")

        var error: NSError?

        // When
        Koara.request(mutableURLRequest)
            .validate()
            .response { _, _, _, responseError in
                error = responseError
                expectation.fulfill()
            }

        waitForExpectationsWithTimeout(timeout, handler: nil)

        // Then
        XCTAssertNil(error)
    }

    func testThatValidationForRequestWithUnacceptableStatusCodeResponseFails() {
        // Given
        let URLString = "https://httpbin.org/status/404"
        let expectation = expectationWithDescription("request should return 404 status code")

        var error: NSError?

        // When
        Koara.request(.GET, URLString)
            .validate()
            .response { _, _, _, responseError in
                error = responseError
                expectation.fulfill()
            }

        waitForExpectationsWithTimeout(timeout, handler: nil)

        // Then
        XCTAssertNotNil(error)

        if let error = error {
            XCTAssertEqual(error.domain, Error.Domain)
            XCTAssertEqual(error.code, Error.Code.StatusCodeValidationFailed.rawValue)
            XCTAssertEqual(error.userInfo[Error.UserInfoKeys.StatusCode] as? Int, 404)
        } else {
            XCTFail("error should not be nil")
        }
    }

    func testThatValidationForRequestWithAcceptableWildcardContentTypeResponseSucceeds() {
        // Given
        let URL = NSURL(string: "https://httpbin.org/ip")!
        let mutableURLRequest = NSMutableURLRequest(URL: URL)
        mutableURLRequest.setValue("application/*", forHTTPHeaderField: "Accept")

        let expectation = expectationWithDescription("request should succeed and return ip")

        var error: NSError?

        // When
        Koara.request(mutableURLRequest)
            .validate()
            .response { _, _, _, responseError in
                error = responseError
                expectation.fulfill()
            }

        waitForExpectationsWithTimeout(timeout, handler: nil)

        // Then
        XCTAssertNil(error)
    }

    func testThatValidationForRequestWithAcceptableComplexContentTypeResponseSucceeds() {
        // Given
        let URL = NSURL(string: "https://httpbin.org/xml")!
        let mutableURLRequest = NSMutableURLRequest(URL: URL)

        let headerValue = "text/xml, application/xml, application/xhtml+xml, text/html;q=0.9, text/plain;q=0.8,*/*;q=0.5"
        mutableURLRequest.setValue(headerValue, forHTTPHeaderField: "Accept")

        let expectation = expectationWithDescription("request should succeed and return xml")

        var error: NSError?

        // When
        Koara.request(mutableURLRequest)
            .validate()
            .response { _, _, _, responseError in
                error = responseError
                expectation.fulfill()
            }

        waitForExpectationsWithTimeout(timeout, handler: nil)

        // Then
        XCTAssertNil(error)
    }

    func testThatValidationForRequestWithUnacceptableContentTypeResponseFails() {
        // Given
        let URL = NSURL(string: "https://httpbin.org/xml")!
        let mutableURLRequest = NSMutableURLRequest(URL: URL)
        mutableURLRequest.setValue("application/json", forHTTPHeaderField: "Accept")

        let expectation = expectationWithDescription("request should succeed and return xml")

        var error: NSError?

        // When
        Koara.request(mutableURLRequest)
            .validate()
            .response { _, _, _, responseError in
                error = responseError
                expectation.fulfill()
            }

        waitForExpectationsWithTimeout(timeout, handler: nil)

        // Then
        XCTAssertNotNil(error)

        if let error = error {
            XCTAssertEqual(error.domain, Error.Domain)
            XCTAssertEqual(error.code, Error.Code.ContentTypeValidationFailed.rawValue)
            XCTAssertEqual(error.userInfo[Error.UserInfoKeys.ContentType] as? String, "application/xml")
        } else {
            XCTFail("error should not be nil")
        }
    }
}
