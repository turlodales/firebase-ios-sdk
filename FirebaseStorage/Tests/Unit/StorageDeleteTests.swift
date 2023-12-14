// Copyright 2022 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

@testable import FirebaseStorage
import Foundation
import GTMSessionFetcherCore
import XCTest

class StorageDeleteTests: StorageTestHelpers {
  var fetcherService: GTMSessionFetcherService?
  var dispatchQueue: DispatchQueue?

  override func setUp() {
    super.setUp()
    fetcherService = GTMSessionFetcherService()
    fetcherService?.authorizer = StorageTokenAuthorizer(
      googleAppID: "dummyAppID",
      fetcherService: fetcherService!,
      authProvider: nil,
      appCheck: nil
    )
    dispatchQueue = DispatchQueue(label: "Test dispatch queue")
  }

  override func tearDown() {
    fetcherService = nil
    super.tearDown()
  }

  func testFetcherConfiguration() {
    let expectation = self.expectation(description: #function)
    fetcherService!.testBlock = { (fetcher: GTMSessionFetcher!,
                                   response: GTMSessionFetcherTestResponse) in
        XCTAssertEqual(fetcher.request?.url, self.objectURL())
        XCTAssertEqual(fetcher.request?.httpMethod, "DELETE")
        let httpResponse = HTTPURLResponse(
          url: (fetcher.request?.url)!,
          statusCode: 200,
          httpVersion: "HTTP/1.1",
          headerFields: nil
        )
        response(httpResponse, nil, nil)
    }
    let path = objectPath()
    let ref = StorageReference(storage: storage(), path: path)
    let task = StorageDeleteTask(
      reference: ref,
      fetcherService: fetcherService!.self,
      queue: dispatchQueue!.self
    ) { error in
      expectation.fulfill()
    }
    task.enqueue()
    waitForExpectation(test: self)
  }

  func testSuccessfulFetch() {
    let expectation = self.expectation(description: #function)
    fetcherService!.testBlock = { (fetcher: GTMSessionFetcher!,
                                   response: GTMSessionFetcherTestResponse) in
        XCTAssertEqual(fetcher.request?.url, self.objectURL())
        XCTAssertEqual(fetcher.request?.httpMethod, "DELETE")
        let httpResponse = HTTPURLResponse(
          url: (fetcher.request?.url)!,
          statusCode: 200,
          httpVersion: "HTTP/1.1",
          headerFields: nil
        )
        response(httpResponse, nil, nil)
    }
    let path = objectPath()
    let ref = StorageReference(storage: storage(), path: path)
    let task = StorageDeleteTask(
      reference: ref,
      fetcherService: fetcherService!.self,
      queue: dispatchQueue!.self
    ) { error in
      expectation.fulfill()
    }
    task.enqueue()
    waitForExpectation(test: self)
  }

  func testSuccessfulFetchWithEmulator() {
    let expectation = self.expectation(description: #function)
    let storage = self.storage()
    storage.useEmulator(withHost: "localhost", port: 8080)
    fetcherService?.allowLocalhostRequest = true

    fetcherService!
      .testBlock = successBlock(
        withURL: URL(string: "http://localhost:8080/v0/b/bucket/o/object")!
      )

    let path = objectPath()
    let ref = StorageReference(storage: storage, path: path)
    let task = StorageDeleteTask(
      reference: ref,
      fetcherService: fetcherService!.self,
      queue: dispatchQueue!.self
    ) { error in
      expectation.fulfill()
    }
    task.enqueue()
    waitForExpectation(test: self)
  }

  func testUnsuccessfulFetchUnauthenticated() {
    let expectation = self.expectation(description: #function)

    fetcherService!.testBlock = unauthenticatedBlock()
    let path = objectPath()
    let ref = StorageReference(storage: storage(), path: path)
    let task = StorageDeleteTask(
      reference: ref,
      fetcherService: fetcherService!.self,
      queue: dispatchQueue!.self
    ) { error in
      XCTAssertEqual((error as? NSError)!.code, StorageErrorCode.unauthenticated.rawValue)
      expectation.fulfill()
    }
    task.enqueue()
    waitForExpectation(test: self)
  }

  func testUnsuccessfulFetchUnauthorized() {
    let expectation = self.expectation(description: #function)

    fetcherService!.testBlock = unauthorizedBlock()
    let path = objectPath()
    let ref = StorageReference(storage: storage(), path: path)
    let task = StorageDeleteTask(
      reference: ref,
      fetcherService: fetcherService!.self,
      queue: dispatchQueue!.self
    ) { error in
      XCTAssertEqual((error as? NSError)!.code, StorageErrorCode.unauthorized.rawValue)
      expectation.fulfill()
    }
    task.enqueue()
    waitForExpectation(test: self)
  }

  func testUnsuccessfulFetchObjectDoesntExist() {
    let expectation = self.expectation(description: #function)

    fetcherService!.testBlock = notFoundBlock()
    let path = objectPath()
    let ref = StorageReference(storage: storage(), path: path)
    let task = StorageDeleteTask(
      reference: ref,
      fetcherService: fetcherService!.self,
      queue: dispatchQueue!.self
    ) { error in
      XCTAssertEqual((error as? NSError)!.code, StorageErrorCode.objectNotFound.rawValue)
      expectation.fulfill()
    }
    task.enqueue()
    waitForExpectation(test: self)
  }
}
