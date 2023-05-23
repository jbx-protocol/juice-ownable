// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {JBOwnable, IJBProjects, IJBOperatorStore, JBOwnableOverrides} from "../../src/JBOwnable.sol";

contract MockOwnable is JBOwnable {
    event ProtectedMethodCalled();

    uint256 permission;

    function setPermission(uint256 _permission) external {
        permission = _permission;
    }

    constructor(
        IJBProjects _projects,
        IJBOperatorStore _operatorStore
    ) JBOwnable(_projects, _operatorStore) {}


    function protectedMethod() external onlyOwner {
        emit ProtectedMethodCalled();
    }

    function protectedMethodWithRequirePermission() external requirePermissionFromProject(permission) {
        emit ProtectedMethodCalled();
    }
}