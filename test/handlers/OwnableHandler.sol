// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// import { Test } from "forge-std/Test.sol";
import {CommonBase} from "forge-std/Base.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import {StdUtils} from "forge-std/StdUtils.sol";
import {console} from "forge-std/console.sol";

import { MockOwnable, JBOwnableOverrides } from "../mocks/MockOwnable.sol";
import { IJBOperatorStore, JBOperatorStore, JBOperatorData } from "@jbx-protocol/juice-contracts-v3/contracts/JBOperatorStore.sol";
import { IJBProjects, JBProjects, JBProjectMetadata } from "@jbx-protocol/juice-contracts-v3/contracts/JBProjects.sol";

contract OwnableHandler is CommonBase, StdCheats, StdUtils  {
    IJBProjects immutable public projects;
    IJBOperatorStore immutable public operatorStore;
    MockOwnable immutable public ownable;

    address[] public actors;
    address internal currentActor;

    modifier useActor(uint256 actorIndexSeed) {
        currentActor = actors[bound(actorIndexSeed, 0, actors.length - 1)];
        vm.startPrank(currentActor);
        _;
        vm.stopPrank();
    }

    constructor() {
        address _initialOwner = vm.addr(1);
        // Deploy the operatorStore
        operatorStore = new JBOperatorStore();
        // Deploy the JBProjects
        projects = new JBProjects(operatorStore);
        // Deploy the JBOwnable
        vm.prank(_initialOwner);
        ownable = new MockOwnable(
            projects,
            operatorStore
        );

        actors.push(_initialOwner);
        actors.push(address(420));
    }

    function transferOwnershipToAddress(
        uint256 actorIndexSeed,
        address _newOwner
    ) public useActor(actorIndexSeed) {
        ownable.transferOwnership(_newOwner);
    }
}