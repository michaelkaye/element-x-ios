//
// Copyright 2022 New Vector Ltd
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

import Combine
import Foundation
import MatrixRustSDK

enum RoomSummaryProviderState {
    case notLoaded
    case preloaded
    case partiallyLoaded
    case fullyLoaded
}

enum RoomSummary: CustomStringConvertible {
    case empty
    case filled(details: RoomSummaryDetails)
    case invalidated(details: RoomSummaryDetails)
    
    var id: String? {
        switch self {
        case .empty:
            return nil
        case .invalidated(let details), .filled(let details):
            return details.id
        }
    }
    
    var name: String? {
        switch self {
        case .empty:
            return nil
        case .invalidated(let details), .filled(let details):
            return details.name
        }
    }
    
    var description: String {
        switch self {
        case .empty:
            return "\(String(describing: Self.self)): Empty"
        case .invalidated(let details):
            return "\(String(describing: Self.self)): Invalidated(\(details.id))"
        case .filled(let details):
            return "\(String(describing: Self.self)): Filled(\(details.id))"
        }
    }
}

protocol RoomSummaryProviderProtocol {
    typealias EntriesFunction = (RoomListEntriesListener) async throws -> RoomListEntriesResult
    typealias LoadingStateFunction = (SlidingSyncListStateObserver) async throws -> RoomListEntriesLoadingStateResult
    
    /// Publishes the currently available room summaries
    var roomListPublisher: CurrentValuePublisher<[RoomSummary], Never> { get }
    
    /// Publishes the current state the summary provider is finding itself in
    var statePublisher: CurrentValuePublisher<RoomSummaryProviderState, Never> { get }
    
    /// A separate subscription method is needed instead of running this in the constructor because the invites list is added later on the Rust side.
    /// Wanted to be able to build the InvitesSummaryProvider directly instead of having to inform the HomeScreenViewModel about it later
    func subscribeIfNecessary(entriesFunction: EntriesFunction,
                              entriesLoadingStateFunction: LoadingStateFunction?) async
    
    func updateVisibleRange(_ range: Range<Int>)
}
