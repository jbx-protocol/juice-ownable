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

contract ProjectHandler is CommonBase, StdCheats, StdUtils, StdAssertions  {
    JBProjects immutable projects;

    address[] public actors;
    address internal currentActor;

    // modifier createActor() {
    //     currentActor = msg.sender;
    //     _actors.add(msg.sender);
    //     _;
    // }

    // modifier useActor(uint256 actorIndexSeed) {
    //     currentActor = actors[bound(actorIndexSeed, 0, actors.length - 1)];
    //     vm.startPrank(currentActor);
    //     _;
    //     vm.stopPrank();
    // }

    constructor(
        JBProjects _projects
    ) {
        projects = _projects; 
    }

    function createNewProject(
        uint256 actorIndexSeed
    ) public  useActor(actorIndexSeed) {
       projects.createFor(
        currentActor,
        JBProjectMetadata({
            content: "",
            domain: 1
        })
       );
    }

    // function transferProjectTo(
    //     uint256 projectSeed,
    //     uint256 toActorIndexSeed
    // ) public useActor(toActorIndexSeed) {
    //     uint256 _projectId = bound(projectSeed, 0, projects.count() + 1);
    //     address _to = currentActor;
    //     address _owner = projects.ownerOf(_projectId);

    //     vm.prank(_owner);
    //     projects.safeTransferFrom(_owner, _to, _projectId);
    // }
}