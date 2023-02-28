// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Test } from "forge-std/Test.sol";
import { OwnableHandler } from "./handlers/OwnableHandler.sol";
import { ProjectHandler } from "./handlers/ProjectHandler.sol";

import { MockOwnable, JBOwnableOverrides } from "./mocks/MockOwnable.sol";
import { IJBOperatorStore, JBOperatorStore, JBOperatorData } from "@jbx-protocol/juice-contracts-v3/contracts/JBOperatorStore.sol";
import {IJBProjects, JBProjects, JBProjectMetadata} from "@jbx-protocol/juice-contracts-v3/contracts/JBProjects.sol";

contract OwnableInvariantTests is Test {
    OwnableHandler handler;

    JBProjects projects;

    function setUp() public {
        // Deploy the OperatorStore
        JBOperatorStore _operatorStore = new JBOperatorStore();
        // Deploy the JBProjects
        projects = new JBProjects(_operatorStore);
        // Deploy the handler for projects and target it
        ProjectHandler _projectHandler = new ProjectHandler(projects);
        targetContract(address(_projectHandler));
        // Deploy the handler and the ownable contract
        handler = new OwnableHandler(
            _operatorStore,
            projects
        );
        targetContract(address(handler));
    }

    function invariant_cantBelongToUserAndProject() public {
        (address owner, uint88 projectId,) = handler.ownable().jbOwner();
        assertTrue(
            ///owner == address(0) ||
            projectId == uint256(0)
        );
    }

    function invariant_followsProjectOwner() public {
        (,uint88 _projectId,) = handler.ownable().jbOwner();
        if(_projectId == 0) return;

        assertEq(
            handler.projects().ownerOf(_projectId),
            handler.ownable().owner()
        );
    }
}