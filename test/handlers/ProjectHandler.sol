// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {JBBaseHandler} from "../helpers/JBBaseHandler.sol";

import {MockOwnable, JBOwnableOverrides} from "../mocks/MockOwnable.sol";
import {
    IJBOperatorStore,
    JBOperatorStore,
    JBOperatorData
} from "@jbx-protocol/juice-contracts-v3/contracts/JBOperatorStore.sol";
import {IJBProjects, JBProjects, JBProjectMetadata} from "@jbx-protocol/juice-contracts-v3/contracts/JBProjects.sol";

contract ProjectHandler is JBBaseHandler {
    constructor(JBProjects _projects) JBBaseHandler("ProjectHandler", _projects) {
        addToFunctionSet("createNewProject", this.createNewProject.selector);
        addToFunctionSet("transferProjectTo", this.transferProjectTo.selector);
    }

    function createNewProject() public registerCall createActor {
        vm.prank(currentActor);
        projects.createFor(currentActor, JBProjectMetadata({content: "", domain: 1}));
    }

    function transferProjectTo(
        uint256 projectIndexSeed,
        uint256 toActorIndexSeed
    ) public registerCall useActor(toActorIndexSeed) useProject(projectIndexSeed) {
        address _to = currentActor;
        address _owner = projects.ownerOf(currentProjectId);

        vm.prank(_owner);
        projects.safeTransferFrom(_owner, _to, currentProjectId);
    }
    
}
