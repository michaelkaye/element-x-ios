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

import Foundation

/// Properties of a matrix event that are common between all timeline items.
struct RoomTimelineItemProperties: Hashable {
    /// Whether the item has been edited.
    var isEdited = false
    /// The aggregated reactions that have been sent for this item.
    var reactions: [AggregatedReaction] = []
    /// The delivery status for this item. If a sent message is echoed the value is nil.
    var deliveryStatus: TimelineItemDeliveryStatus?
    /// The read receipts of the item, ordered from newest to oldest
    var orderedReadReceipts: [ReadReceipt] = []
    /// The original transaction id transmitted by the client
    var transactionID: String?
}
