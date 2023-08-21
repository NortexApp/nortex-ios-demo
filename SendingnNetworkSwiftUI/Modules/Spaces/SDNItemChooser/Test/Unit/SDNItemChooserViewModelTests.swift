//
// Copyright 2021 New Vector Ltd
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
import XCTest

@testable import SendingnNetworkSwiftUI

class SDNItemChooserViewModelTests: XCTestCase {
    var creationParameters = SpaceCreationParameters()
    var service: MockSDNItemChooserService!
    var viewModel: SDNItemChooserViewModelProtocol!
    var context: SDNItemChooserViewModel.Context!
    
    override func setUpWithError() throws {
        service = MockSDNItemChooserService(type: .room)
        viewModel = SDNItemChooserViewModel.makeSDNItemChooserViewModel(sdnItemChooserService: service, title: VectorL10n.spacesCreationAddRoomsTitle, detail: VectorL10n.spacesCreationAddRoomsMessage, selectionHeader: nil)
        context = viewModel.context
    }
    
    func testInitialState() {
        XCTAssertEqual(context.viewState.emptyListMessage, VectorL10n.spacesNoResultFoundTitle)
        XCTAssertEqual(context.viewState.title, VectorL10n.spacesCreationAddRoomsTitle)
        XCTAssertEqual(context.viewState.message, VectorL10n.spacesCreationAddRoomsMessage)
        XCTAssertEqual(context.viewState.sections, MockSDNItemChooserService.mockSections)
        XCTAssertEqual(context.viewState.selectedItemIds.count, 0)
    }

    func testItemSelection() throws {
        XCTAssertEqual(context.viewState.selectedItemIds.count, 0)
        service.simulateSelectionForItem(at: IndexPath(row: 0, section: 0))
        XCTAssertEqual(context.viewState.selectedItemIds.count, 1)
        XCTAssertEqual(context.viewState.selectedItemIds.first, MockSDNItemChooserService.mockSections[0].items[0].id)
    }
}
