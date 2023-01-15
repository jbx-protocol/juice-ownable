// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Should fit into a single slot
struct JBOwner {
    address owner;
    uint88 projectId;
    uint8 permissionIndex;
}