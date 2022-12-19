// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Ownable.sol";

import {JBOperatorStore} from "@jbx-protocol/juice-contracts-v3/contracts/JBOperatorStore.sol";
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

        // Create a project for the owner
        uint256 _projectId = projects.createFor(
            _projectOwner,
            JBProjectMetadata("", 0)
        );

        vm.prank(_owner);
        MockOwnable ownable = new MockOwnable(
            projects,
            operatorStore,
            _projectId,
            0
        );

        assertEq(_owner, ownable.owner(), "Deployer is not the owner");
    }

    function testOwnableFollowsTheProjectOwner(
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
        vm.prank(_projectOwner);
        MockOwnable ownable = new MockOwnable(
            projects,
            operatorStore,
            _projectId,
            0
        );

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

    function testOwnableCanBeOverrriden(
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
        vm.prank(_projectOwner);
        MockOwnable ownable = new MockOwnable(
            projects,
            operatorStore,
            _projectId,
            0
        );

        // Make sure the deployer owns it
        assertEq(_projectOwner, ownable.owner(), "Deployer is not the owner");

        // Transfer the project ownership
        vm.prank(_projectOwner);
        ownable.transferOwnership(_newOwnableOwner);

        // Make sure the Ownable now also transferred to the new project owner
        assertEq(
            _newOwnableOwner,
            ownable.owner(),
            "Ownable did not follow the Project owner"
        );
        assertEq(projects.ownerOf(_projectId), _projectOwner);
    }

    function testOwnableOverrridenDoesNotFollowProject(
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
            operatorStore,
            _projectId,
            0
        );

        // Make sure the deployer owns it
        assertEq(_deployer, ownable.owner(), "Deployer is not the owner");

        // Transfer the project ownership
        vm.prank(_projectOwner);
        projects.transferFrom(_projectOwner, _newProjectOwner, _projectId);
        assertEq(projects.ownerOf(_projectId), _newProjectOwner);

        // Make sure the Ownable now also transferred to the new project owner
        assertEq(
            _deployer,
            ownable.owner(),
            "Ownable followed the projectOwner but its overriden"
        );
    }

    function testOwnerCanRennounce(address _projectOwner) public isNotContract(_projectOwner) {
        // CreateFor won't work if the address is a contract (that doesn't support ERC721Receiver)
        vm.assume(
            _projectOwner != address(0)
        );

        // Create a project for the owner
        uint256 _projectId = projects.createFor(
            _projectOwner,
            JBProjectMetadata("", 0)
        );

        vm.prank(_projectOwner);
        MockOwnable ownable = new MockOwnable(
            projects,
            operatorStore,
            _projectId,
            0
        );

        assertEq(_projectOwner, ownable.owner(), "Deployer is not the owner");

        // Rennounce the ownership
        vm.prank(_projectOwner);
        ownable.renounceOwnership();

        assertEq(address(0), ownable.owner(), "Owner was not rennounced");
    }
}

contract MockOwnable is Ownable {
    constructor(
        IJBProjects _projects,
        IJBOperatorStore _operatorStore,
        uint256 _projectId,
        uint256 _permissionIndex
    ) Ownable(_projects, _operatorStore, _projectId, _permissionIndex) {}
}
