// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Test } from "forge-std/Test.sol";
import { OwnableHandler } from "./handlers/OwnableHandler.sol";

import { MockOwnable, JBOwnableOverrides } from "./mocks/MockOwnable.sol";
import { IJBOperatorStore, JBOperatorStore, JBOperatorData } from "@jbx-protocol/juice-contracts-v3/contracts/JBOperatorStore.sol";
import {IJBProjects, JBProjects, JBProjectMetadata} from "@jbx-protocol/juice-contracts-v3/contracts/JBProjects.sol";

contract OwnableInvariantTests is Test {
    OwnableHandler handler;

    function setUp() public {
        handler = new OwnableHandler();
        targetContract(address(handler));
    }

    function invariant_cantBelongToUserAndProject() public {
        (address owner, uint88 projectId,) = handler.ownable().jbOwner();
        assertTrue(
            ///owner == address(0) ||
            projectId == uint256(0)
        );
    }

}