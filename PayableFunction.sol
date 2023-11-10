// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

/**
 * @title Pay
 * @dev A simple smart contract for handling payments.
 */
contract Pay {
    address public owner;
    mapping(address => uint) public balances;

    event Withdraw(address indexed to, uint amount, string message);
    event Deposit(address indexed to, uint amount, string message);

    /**
     * @dev Constructor sets the owner to the address that deploys the contract.
     */
    constructor() {
        owner = msg.sender;
    }

    /**
     * @dev Modifier that allows only the owner to execute a function.
     */
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    /**
     * @dev Deposits funds into the contract. Only the owner can deposit.
     */
    function depositToContract() external payable onlyOwner {
        require(msg.value > 1 ether, "Amount should not be zero");
        balances[msg.sender] += msg.value;
        emit Deposit(msg.sender, etherToWei(msg.value), "Amount Deposited to Contract");
    }

    /**
     * @dev Deposits funds into the owner's account in the contract.
     * @param _amount The amount to deposit.
     */
    function depositToOwner(uint _amount) private {
        balances[owner] += _amount;
    }

    /**
     * @dev Transfers funds from the contract to a specified receiver.
     * @param _amount The amount to transfer.
     */
    function depositToReceiver(uint _amount) external payable {
        require(_amount > 0, "Transfer amount should be greater than zero");
        require(address(this).balance >= _amount, "Insufficient balance");

        balances[msg.sender] -= _amount;

        // Transfer funds to receiver's account from the contract's account.
        (bool sent, bytes memory data) = payable(msg.sender).call{gas: 10000, value: etherToWei(_amount)}("");
        require(sent, string(data));

        emit Withdraw(msg.sender, _amount, "Amount Deducted");
    }

    /**
     * @dev Checks the balance of a given address in the contract.
     * @param _adr The address to check.
     * @return The balance in ether.
     */
    function checkBalance(address _adr) external view returns (uint) {
        return weiToEther(balances[_adr]);
    }

    /**
     * @dev Converts ether to wei.
     * @param valueEther The value in ether.
     * @return The value in wei.
     */
    function etherToWei(uint valueEther) public pure returns (uint) {
        return valueEther * 1 ether;
    }

    /**
     * @dev Converts wei to ether.
     * @param valueWei The value in wei.
     * @return The value in ether.
     */
    function weiToEther(uint valueWei) public pure returns (uint) {
        return valueWei / 1 ether;
    }
}
