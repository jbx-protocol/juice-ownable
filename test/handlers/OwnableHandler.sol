// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// import { Test } from "forge-std/Test.sol";
import {CommonBase} from "forge-std/Base.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import {StdUtils} from "forge-std/StdUtils.sol";
import {console} from "forge-std/console.sol";
import {StdAssertions} from "forge-std/StdAssertions.sol";

import { MockOwnable, JBOwnableOverrides } from "../mocks/MockOwnable.sol";
import { IJBOperatorStore, JBOperatorStore, JBOperatorData } from "@jbx-protocol/juice-contracts-v3/contracts/JBOperatorStore.sol";
import { IJBProjects, JBProjects, JBProjectMetadata } from "@jbx-protocol/juice-contracts-v3/contracts/JBProjects.sol";

contract OwnableHandler is CommonBase, StdCheats, StdUtils, StdAssertions  {
    IJBProjects immutable public projects;
    IJBOperatorStore immutable public operatorStore;
    MockOwnable immutable public ownable;

    uint256[] public projectIds;

    address[] public actors;
    address internal currentActor;

    modifier useActor(uint256 actorIndexSeed) {
        currentActor = actors[bound(actorIndexSeed, 0, actors.length - 1)];
        vm.startPrank(currentActor);
        _;
        vm.stopPrank();
    }


    constructor(
        JBOperatorStore _operatorStore,
        JBProjects _projects
    ) {
        address _initialOwner = vm.addr(1);
        // Deploy the operatorStore
        operatorStore = _operatorStore; //new JBOperatorStore();
        // Deploy the JBProjects
        projects = _projects; //new JBProjects(operatorStore);
        // Deploy the JBOwnable
        vm.prank(_initialOwner);
        ownable = new MockOwnable(
            projects,
            operatorStore
        );

        actors.push(_initialOwner);
        actors.push(address(420));
    }

    // function transferOwnershipToAddress(
    //     uint256 actorIndexSeed,
    //     address newOwner
    // ) public useActor(actorIndexSeed) {
    //     // Transfer to new Owner
    //     vm.prank(currentActor);
    //     ownable.transferOwnership(newOwner);

    //     // Register the newOwner as an actor
    //     actors.push(newOwner);

    //     assertEq(
    //         ownable.owner(),
    //         newOwner
    //     );
    // }

    //  function transferOwnershipToProject(
    //     uint256 projectIdSeed
    // ) public {
    //     revert();
    //     uint256 _projectId = bound(projectIdSeed, 0, projects.count() + 1);
    //     //uint256 _projectId = projectIds[bound(projectIdSeed, 0, projectIds.length - 1)];

    //     vm.prank(ownable.owner());
    //     ownable.transferOwnershipToProject(_projectId);
    // }
}