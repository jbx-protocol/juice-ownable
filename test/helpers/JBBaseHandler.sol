// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {BaseHandler} from "foundry-invariant-helpers/src/BaseHandler.sol";
import {IJBProjects, JBProjects, JBProjectMetadata} from "@jbx-protocol/juice-contracts-v3/contracts/JBProjects.sol";

contract JBBaseHandler is BaseHandler {
    IJBProjects immutable projects;

    uint256 currentProjectId;

    modifier useProject(uint256 projectIndexSeed) {
        uint256 _projectId = projectIndexSeed % projects.count();
        // '0' in this case is not a valid value, so we take the last item instead
        currentProjectId = _projectId != 0 ? _projectId : projects.count();
        _;
    } 

    constructor(
        string memory _contractLabel,
        IJBProjects _projects
    ) BaseHandler(_contractLabel) {
        projects = _projects;
    }
}