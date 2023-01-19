// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/JBOwnable.sol";

import {JBOperatorStore, JBOperatorData} from "@jbx-protocol/juice-contracts-v3/contracts/JBOperatorStore.sol";
import {JBProjects, JBProjectMetadata} from "@jbx-protocol/juice-contracts-v3/contracts/JBProjects.sol";

contract OwnableTest is Test {
    IJBProjects projects;
    IJBOperatorStore operatorStore;

    modifier isNotContract(address _a) {
        uint size;
        assembly {
            size := extcodesize(_a)
        }
        vm.assume(size == 0);
        _;
    }

    function setUp() public {
        // Deploy the operatorStore
        operatorStore = new JBOperatorStore();
        // Deploy the JBProjects
        projects = new JBProjects(operatorStore);
    }

    function testDeployerBecomesOwner(
        address _projectOwner,
        address _owner
    ) public isNotContract(_projectOwner) isNotContract(_owner) {
        // CreateFor won't work if the address is a contract (that doesn't support ERC721Receiver)
        vm.assume(_projectOwner != address(0));

        vm.prank(_owner);
        MockOwnable ownable = new MockOwnable(
            projects,
            operatorStore
        );

        assertEq(_owner, ownable.owner(), "Deployer is not the owner");
    }

    function testJBOwnableFollowsTheProjectOwner(
        address _projectOwner,
        address _newProjectOwner
    ) public isNotContract(_projectOwner) isNotContract(_newProjectOwner) {
        // CreateFor won't work if the address is a contract (that doesn't support ERC721Receiver)
        vm.assume(_projectOwner != address(0));
        // Can't transfer project ownership to 0 address
        vm.assume(_newProjectOwner != address(0));

        // Create a project for the owner
        uint256 _projectId = projects.createFor(
            _projectOwner,
            JBProjectMetadata("", 0)
        );

        // Create the Ownable contract
        MockOwnable ownable = new MockOwnable(
            projects,
            operatorStore
        );

        // Transfer ownership to the project owner
        ownable.transferOwnershipToProject(_projectId);

        // Make sure the deployer owns it
        assertEq(_projectOwner, ownable.owner(), "Deployer is not the owner");

        // Transfer the project ownership
        vm.prank(_projectOwner);
        projects.transferFrom(_projectOwner, _newProjectOwner, _projectId);

        // Make sure the Ownable now also transferred to the new project owner
        assertEq(
            _newProjectOwner,
            ownable.owner(),
            "Ownable did not follow the Project owner"
        );
    }

    function testBasicOwnable(
        address _projectOwner,
        address _newOwnableOwner
    ) public isNotContract(_projectOwner) isNotContract(_newOwnableOwner) {
        // Owner can't be transferred to the 0 address (has to be rennounced)
        vm.assume(_newOwnableOwner != address(0));
        // CreateFor won't work if the address is a contract (that doesn't support ERC721Receiver)
        vm.assume(_projectOwner != address(0));

        // Create a project for the owner
        uint256 _projectId = projects.createFor(
            _projectOwner,
            JBProjectMetadata("", 0)
        );

        // Create the Ownable contract
        MockOwnable ownable = new MockOwnable(
            projects,
            operatorStore
        );

        // Transfer ownership to the project owner
        ownable.transferOwnershipToProject(_projectId);
        // Make sure the project owner owns it
        assertEq(_projectOwner, ownable.owner(), "Deployer is not the owner");

        // We now stop using it as a JBOwnable and start using it like a basic Ownable
        vm.prank(_projectOwner);
        ownable.transferOwnership(_newOwnableOwner);
        // Make sure it transferred to the new owner
        assertEq(
            _newOwnableOwner,
            ownable.owner()
        );
        // Sanity check to make sure it was only the Ownable that changed and not the project as well
        assertEq(projects.ownerOf(_projectId), _projectOwner);
    }

    function testOwnableDoesNotFollowProject(
        address _deployer,
        address _projectOwner,
        address _newProjectOwner
    )
        public
        isNotContract(_deployer)
        isNotContract(_projectOwner)
        isNotContract(_newProjectOwner)
    {
        vm.assume(_deployer != _projectOwner && _deployer != _newProjectOwner);
        // CreateFor won't work if the address is a contract (that doesn't support ERC721Receiver)
        vm.assume(_projectOwner != address(0));
        vm.assume(_newProjectOwner != address(0));

        // Create a project for the owner
        uint256 _projectId = projects.createFor(
            _projectOwner,
            JBProjectMetadata("", 0)
        );

        // Create the Ownable contract
        vm.prank(_deployer);
        MockOwnable ownable = new MockOwnable(
            projects,
            operatorStore
        );

        // Make sure the deployer owns it
        assertEq(_deployer, ownable.owner(), "Deployer is not the owner");
        
         // Transfer ownership to the project owner
        vm.prank(_deployer);
        ownable.transferOwnershipToProject(_projectId);

        // Make sure the deployer owns it
        assertEq(projects.ownerOf(_projectId), ownable.owner(), "Project owner is not the owner");

        // Transfer the project ownership
        vm.prank(_projectOwner);
        projects.transferFrom(_projectOwner, _newProjectOwner, _projectId);
        assertEq(projects.ownerOf(_projectId), _newProjectOwner);

        // Make sure the Ownable now also transferred to the new project owner
        assertEq(
            _newProjectOwner,
            ownable.owner(),
            "Ownable followed the projectOwner but its overriden"
        );
    }

    function testOwnableOwnerCanRennounce(address _owner) public {
        vm.assume(
            _owner != address(0)
        );

        // Create the Ownable contract
        MockOwnable ownable = new MockOwnable(
            projects,
            operatorStore
        );

        // Transfer ownership to the project owner
        ownable.transferOwnership(_owner);
        assertEq(_owner, ownable.owner(), "Deployer is not the owner");

        // Rennounce the ownership
        vm.prank(_owner);
        ownable.renounceOwnership();
        assertEq(address(0), ownable.owner(), "Owner was not rennounced");
    }

    function testJBOwnableOwnerCanRennounce(address _projectOwner) public isNotContract(_projectOwner) {
        // CreateFor won't work if the address is a contract (that doesn't support ERC721Receiver)
        vm.assume(
            _projectOwner != address(0)
        );

        // Create a project for the owner
        uint256 _projectId = projects.createFor(
            _projectOwner,
            JBProjectMetadata("", 0)
        );

        // Create the Ownable contract
        MockOwnable ownable = new MockOwnable(
            projects,
            operatorStore
        );

        // Transfer ownership to the project owner
        ownable.transferOwnershipToProject(_projectId);
        assertEq(_projectOwner, ownable.owner(), "Deployer is not the owner");

        // Rennounce the ownership
        vm.prank(_projectOwner);
        ownable.renounceOwnership();
        assertEq(address(0), ownable.owner(), "Owner was not rennounced");
    }

    function testJBOwnablePermissions(
        address _projectOwner,
        address _callerAddress,
        uint8 _permissionIndexRequired,
        uint8[] memory _permissionsToGrant
    ) public isNotContract(_projectOwner) {
        // CreateFor won't work if the address is a contract (that doesn't support ERC721Receiver)
        vm.assume(
            _projectOwner != address(0)
        );

        vm.assume(
            _permissionsToGrant.length < 5
        );

        // Create a project for the owner
        uint256 _projectId = projects.createFor(
            _projectOwner,
            JBProjectMetadata("", 0)
        );

        // Create the Ownable contract
        MockOwnable ownable = new MockOwnable(
            projects,
            operatorStore
        );

        // Transfer ownership to the project owner
        ownable.transferOwnershipToProject(_projectId);
        assertEq(_projectOwner, ownable.owner(), "Project owner is not the owner");

        // Set the permission that is required
        vm.prank(_projectOwner);
        ownable.setPermissionIndex(_permissionIndexRequired);

        // Attempt to call the protected method without permission
        vm.expectRevert(
            abi.encodeWithSelector(JBOwnable.UNAUTHORIZED.selector)
        );
        vm.prank(_callerAddress);
        ownable.protectedMethod();

        // Give permission
        bool _shouldHavePermission;
        uint256[] memory _permissionIndexes = new uint256[](_permissionsToGrant.length);
        for(uint256 i; i < _permissionsToGrant.length; i++){
            // Check if the permission we need is in the set
            if(_permissionsToGrant[i] == _permissionIndexRequired) _shouldHavePermission = true;
            _permissionIndexes[i] = _permissionsToGrant[i];
        }

        // The owner gives permission to the caller
        vm.prank(_projectOwner);
        operatorStore.setOperator(
            JBOperatorData({
                operator: _callerAddress,
                domain: _projectId,
                permissionIndexes: _permissionIndexes
            })
        );

        if(!_shouldHavePermission)
         vm.expectRevert(
            abi.encodeWithSelector(JBOwnable.UNAUTHORIZED.selector)
         );

        vm.prank(_callerAddress);
        ownable.protectedMethod();
    }
}

contract MockOwnable is JBOwnable {
    event ProtectedMethodCalled();

    constructor(
        IJBProjects _projects,
        IJBOperatorStore _operatorStore
    ) JBOwnable(_projects, _operatorStore) {}


    function protectedMethod() external onlyOwner {
        emit ProtectedMethodCalled();
    }
}
