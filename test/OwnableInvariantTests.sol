// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {BaseInvariant} from "foundry-invariant-helpers/src/BaseInvariant.sol";

import {OwnableHandler} from "./handlers/OwnableHandler.sol";
import {ProjectHandler} from "./handlers/ProjectHandler.sol";

import {MockOwnable, JBOwnableOverrides} from "./mocks/MockOwnable.sol";
import {
    IJBOperatorStore,
    JBOperatorStore,
    JBOperatorData
} from "@jbx-protocol/juice-contracts-v3/contracts/JBOperatorStore.sol";
import {IJBProjects, JBProjects, JBProjectMetadata} from "@jbx-protocol/juice-contracts-v3/contracts/JBProjects.sol";


contract OwnableInvariantTests is BaseInvariant {
    OwnableHandler ownableHandler;
    ProjectHandler projectHandler;

    JBProjects projects;

    function setUp() targetSpecificSelectors public {
        // Deploy the OperatorStore
        JBOperatorStore _operatorStore = new JBOperatorStore();
        // Deploy the JBProjects
        projects = new JBProjects(_operatorStore);
        // Deploy the handler for projects
        projectHandler = new ProjectHandler(projects);
        // Deploy the handler and the ownable contract
        ownableHandler = new OwnableHandler(
            _operatorStore,
            projects
        );

        // Create a JBProject
        projects.createFor(msg.sender, JBProjectMetadata({content: "", domain: 1}));

        // Target the contracts
        targetContract(address(projectHandler));
        targetContract(address(ownableHandler));
    }

    function invariant_cantBelongToUserAndProject() public {
        (address owner, uint88 projectId,) = ownableHandler.ownable().jbOwner();
        assertTrue(
            !(
                owner != address(0) &&
                projectId != uint256(0)
            )
        );
    }

    function invariant_followsProjectOwner() public {
        (, uint88 _projectId,) = ownableHandler.ownable().jbOwner();
        if (_projectId == 0) return;

        assertEq(projects.ownerOf(_projectId), ownableHandler.ownable().owner());
    }
}
