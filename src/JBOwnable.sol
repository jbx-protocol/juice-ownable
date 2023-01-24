// SPDX-License-Identifier: MIT
// Juicebox variation on OpenZeppelin Ownable
pragma solidity ^0.8.0;

import { JBOwnableOverrides, IJBProjects, IJBOperatorStore } from "./JBOwnableOverrides.sol";

contract JBOwnable is JBOwnableOverrides {
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
      @param _projects the JBProjects to use to get the owner of the project
      @param _operatorStore the operatorStore to use for the permissions
     */
    constructor(
        IJBProjects _projects,
        IJBOperatorStore _operatorStore
    ) JBOwnableOverrides(_projects, _operatorStore) {}

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() virtual {
        _checkOwner();
        _;
    }

    function _emitTransferEvent(address previousOwner, address newOwner)
        internal
        virtual
        override
    {
        emit OwnershipTransferred(previousOwner, newOwner);
    }
}
