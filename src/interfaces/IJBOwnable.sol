// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IJBOwnable {
  function transferOwnershipToProject(uint256 _projectId) external;
  function setPermissionIndex(uint8 _permissionIndex) external;
}