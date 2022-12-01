// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "@jbx-protocol/juice-contracts-v3/contracts/abstract/JBOperatable.sol";
import "@jbx-protocol/juice-contracts-v3/contracts/interfaces/IJBProjects.sol";

import "@openzeppelin/contracts/utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions and can grant other users permission to those functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner or an approved address.
 *
 * Supports meta-transactions.
 */
abstract contract Ownable is Context {
    //*********************************************************************//
    // --------------------------- custom errors -------------------------- //
    //*********************************************************************//
    error UNAUTHORIZED();

    //*********************************************************************//
    // ---------------- public immutable stored properties --------------- //
    //*********************************************************************//

    /** 
        @notice 
        A contract storing operator assignments.
    */
    IJBOperatorStore public immutable operatorStore;

    /**
        @notice
        The IJBProjects to use to get the owner of a project
     */
    IJBProjects public immutable projects;

    /**
        @notice
        The domain we should check (projectId)
     */
    uint256 public immutable domain;

    /**
        @notice
        The permission that is required to act as the owner
     */
    uint256 public immutable permissionIndex;

    //*********************************************************************//
    // -------------------------- constructor ---------------------------- //
    //*********************************************************************//

    /**
      @param _projects the JBProjects to use to get the owner of the project
      @param _operatorStore the operatorStore to use for the permissions
      @param _projectId the projectId to use for the contract (also known as domain)
      @param _permissionIndex the permission to check for to see if the caller has access
     */
    constructor(
        IJBProjects _projects,
        IJBOperatorStore _operatorStore,
        uint256 _projectId,
        uint256 _permissionIndex
    ) {
        operatorStore = _operatorStore;
        projects = _projects;
        domain = _projectId;
        permissionIndex = _permissionIndex;
    }

    /**
     @dev Throws if called by any account other than the owner.
    */
    modifier onlyOwner() {
        _requirePermission(owner(), domain, permissionIndex);
        _;
    }

    /**
     @notice Returns the address of the current project owner.
    */
    function owner() public view virtual returns (address) {
        return projects.ownerOf(domain);
    }

    //*********************************************************************//
    // -------------------------- internal views ------------------------- //
    //*********************************************************************//

    /** 
    @notice
    Require the message sender is either the account or has the specified permission.

    @param _account The account to allow.
    @param _domain The domain namespace within which the permission index will be checked.
    @param _permissionIndex The permission index that an operator must have within the specified domain to be allowed.
  */
    function _requirePermission(
        address _account,
        uint256 _domain,
        uint256 _permissionIndex
    ) internal view virtual {
        address _sender = _msgSender();
        if (
            _sender != _account &&
            !operatorStore.hasPermission(
                _sender,
                _account,
                _domain,
                _permissionIndex
            ) &&
            !operatorStore.hasPermission(_sender, _account, 0, _permissionIndex)
        ) revert UNAUTHORIZED();
    }

    /** 
    @notice
    Require the message sender is either the account, has the specified permission, or the override condition is true.

    @param _account The account to allow.
    @param _domain The domain namespace within which the permission index will be checked.
    @param _domain The permission index that an operator must have within the specified domain to be allowed.
    @param _override The override condition to allow.
  */
    function _requirePermissionAllowingOverride(
        address _account,
        uint256 _domain,
        uint256 _permissionIndex,
        bool _override
    ) internal view virtual {
        // short-circuit if the override is true
        if (_override) return;
        // Perform regular check otherwise
        _requirePermission(_account, _domain, _permissionIndex);
    }
}
