// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title AccessControlExample
 * @dev An example smart contract demonstrating the usage of AccessControl from OpenZeppelin.
 */
contract AccessControlExample is AccessControl {
    // Define roles
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant MODERATOR_ROLE = keccak256("MODERATOR_ROLE");

    /**
     * @dev Constructor grants the deployer both admin and default admin roles.
     */
    constructor() {
        _setupRole(ADMIN_ROLE, msg.sender);
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    /**
     * @dev Modifier to restrict access to admin.
     */
    modifier onlyAdmin() {
        require(hasRole(ADMIN_ROLE, msg.sender), "Restricted to admin");
        _;
    }

    /**
     * @dev Modifier to restrict access to moderator.
     */
    modifier onlyModerator() {
        require(hasRole(MODERATOR_ROLE, msg.sender), "Restricted to moderator");
        _;
    }

    /**
     * @dev Function to perform an admin-only action.
     */
    function adminAction() public onlyAdmin {
        // Perform admin-specific action here
    }

    /**
     * @dev Function to perform a moderator-only action.
     */
    function moderatorAction() public onlyModerator {
        // Perform moderator-specific action here
    }

    /**
     * @dev Function to grant the moderator role to an address.
     * Note: This function is currently commented out, but you can uncomment it if needed.
     * @param account The address to be granted the moderator role.
     */
    // function grantModeratorRole(address account) public onlyAdmin {
    //     grantRole(MODERATOR_ROLE, account);
    // }
}
