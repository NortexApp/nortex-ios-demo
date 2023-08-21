// File created from SimpleUserProfileExample
// $ createScreen.sh Spaces/SpaceCreation/SpaceCreationEmailInvites SpaceCreationEmailInvites
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

class SpaceCreationEmailInvitesViewModelTests: XCTestCase {
    var creationParameters = SpaceCreationParameters()
    var service: MockSpaceCreationEmailInvitesService!
    var viewModel: SpaceCreationEmailInvitesViewModelProtocol!
    var context: SpaceCreationEmailInvitesViewModelType.Context!
    
    override func setUpWithError() throws {
        service = MockSpaceCreationEmailInvitesService(defaultValidation: true, isLoading: false)
        viewModel = SpaceCreationEmailInvitesViewModel(creationParameters: creationParameters, service: service)
        context = viewModel.context
    }

    func testInitialState() {
        XCTAssertEqual(context.viewState.title, creationParameters.isPublic ? VectorL10n.spacesCreationPublicSpaceTitle : VectorL10n.spacesCreationPrivateSpaceTitle)
        XCTAssertEqual(context.emailInvites, creationParameters.emailInvites)
    }
}