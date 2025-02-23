//
// Copyright 2023 New Vector Ltd
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import XCTest

@testable import ElementX

@MainActor
class UserDiscoveryServiceTest: XCTestCase {
    var service: UserDiscoveryService!
    var clientProxy: MockClientProxy!
    
    override func setUpWithError() throws {
        clientProxy = .init(userID: "")
        service = UserDiscoveryService(clientProxy: clientProxy)
    }
    
    func testQueryShowingResults() async throws {
        clientProxy.searchUsersResult = .success(.init(results: [UserProfileProxy.mockAlice], limited: true))
        
        let results = await (try? search(query: "AAA").get()) ?? []
        assertSearchResults(results, toBe: 1)
    }
    
    func testGetProfileIsNotCalled() async {
        clientProxy.searchUsersResult = .success(.init(results: searchResults, limited: true))
        clientProxy.getProfileResult = .success(.init(userID: "@alice:matrix.org"))
        
        let results = await (try? search(query: "AAA").get()) ?? []
        assertSearchResults(results, toBe: 3)
        XCTAssertFalse(clientProxy.getProfileCalled)
    }
    
    func testLocalResultShows() async {
        clientProxy.searchUsersResult = .success(.init(results: searchResults, limited: true))
        clientProxy.getProfileResult = .success(.init(userID: "@some:matrix.org"))
        
        let results = await (try? search(query: "@a:b.com").get()) ?? []
        
        assertSearchResults(results, toBe: 4)
        XCTAssertTrue(clientProxy.getProfileCalled)
    }
    
    func testLocalResultShowsOnSearchError() async {
        clientProxy.searchUsersResult = .failure(.failedSearchingUsers)
        clientProxy.getProfileResult = .success(.init(userID: "@some:matrix.org"))
        
        let results = await (try? search(query: "@a:b.com").get()) ?? []
        
        assertSearchResults(results, toBe: 1)
        XCTAssertTrue(clientProxy.getProfileCalled)
    }
    
    func testSearchErrorTriggers() async {
        clientProxy.searchUsersResult = .failure(.failedSearchingUsers)
        clientProxy.getProfileResult = .success(.init(userID: "@some:matrix.org"))
        
        switch await search(query: "some query") {
        case .success:
            XCTFail("Search users must fail")
        case .failure(let error):
            XCTAssertEqual(error, UserDiscoveryErrorType.failedSearchingUsers)
        }
        
        XCTAssertFalse(clientProxy.getProfileCalled)
    }
    
    func testLocalResultWithDuplicates() async {
        clientProxy.searchUsersResult = .success(.init(results: searchResults, limited: true))
        clientProxy.getProfileResult = .success(.init(userID: "@bob:matrix.org"))
        
        let results = await (try? search(query: "@a:b.com").get()) ?? []
        
        assertSearchResults(results, toBe: 3)
        let firstUserID = results.first?.userID
        XCTAssertEqual(firstUserID, "@bob:matrix.org")
        XCTAssertTrue(clientProxy.getProfileCalled)
    }
    
    func testSearchResultsShowWhenGetProfileFails() async {
        clientProxy.searchUsersResult = .success(.init(results: searchResults, limited: true))
        clientProxy.getProfileResult = .failure(.failedGettingUserProfile)
        
        let results = await (try? search(query: "@a:b.com").get()) ?? []
        
        let firstUserID = results.first?.userID
        XCTAssertEqual(firstUserID, "@a:b.com")
        XCTAssertTrue(clientProxy.getProfileCalled)
    }
    
    // MARK: - Private
    
    private func assertSearchResults(_ results: [UserProfileProxy], toBe count: Int) {
        XCTAssertTrue(count >= 0)
        XCTAssertEqual(results.count, count)
        XCTAssertEqual(results.isEmpty, count == 0)
    }
    
    private func search(query: String) async -> Result<[UserProfileProxy], UserDiscoveryErrorType> {
        await service.searchProfiles(with: query)
    }
    
    private var searchResults: [UserProfileProxy] {
        [
            .mockAlice,
            .mockBob,
            .mockCharlie
        ]
    }
}
