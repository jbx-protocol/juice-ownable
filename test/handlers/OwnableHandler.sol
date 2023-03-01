// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// import { Test } from "forge-std/Test.sol";
import {JBBaseHandler} from "../helpers/JBBaseHandler.sol";

import {MockOwnable, JBOwnableOverrides} from "../mocks/MockOwnable.sol";
import {
    IJBOperatorStore,
    JBOperatorStore,
    JBOperatorData
} from "@jbx-protocol/juice-contracts-v3/contracts/JBOperatorStore.sol";
import {IJBProjects, JBProjects, JBProjectMetadata} from "@jbx-protocol/juice-contracts-v3/contracts/JBProjects.sol";

contract OwnableHandler is JBBaseHandler {
    IJBOperatorStore public immutable operatorStore;
    MockOwnable public immutable ownable;

    constructor(JBOperatorStore _operatorStore, JBProjects _projects) JBBaseHandler("OwnableHandler", _projects) {
        address _initialOwner = vm.addr(1);
        operatorStore = _operatorStore;
        // Deploy the JBOwnable
        vm.prank(_initialOwner);
        ownable = new MockOwnable(
            _projects,
            operatorStore
        );

        addToFunctionSet("transferOwnershipToAddress", this.transferOwnershipToAddress.selector);
        addToFunctionSet("transferOwnershipToProject", this.transferOwnershipToProject.selector);
        addToFunctionSet("renounceOwnership", this.renounceOwnership.selector);
    }

    function transferOwnershipToAddress(
        uint256 actorIndexSeed,
        address newOwner
    ) public registerCall useActor(actorIndexSeed) {
        // Can't transfer to a 0 address
        if (newOwner == address(0))
            return renounceOwnership();
        
        // The new owner should be an actor
        addActor(newOwner);

        // Transfer to new Owner
        vm.prank(ownable.owner());
        ownable.transferOwnership(newOwner);

        assertEq(
            ownable.owner(),
            newOwner
        );
    }

     function transferOwnershipToProject(
        uint256 projectIdSeed
    ) public registerCall useProject(projectIdSeed) {
        vm.prank(ownable.owner());
        ownable.transferOwnershipToProject(currentProjectId);
    }

    function renounceOwnership() public registerCall {
        // Check if already renounced
        if(ownable.owner() == address(0))
            return;

        vm.prank(ownable.owner());
        ownable.renounceOwnership();
    }
}
