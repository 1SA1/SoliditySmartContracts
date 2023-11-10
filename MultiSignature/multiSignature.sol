// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

/**
 * @title MultiSig
 * @dev A simple multi-signature wallet contract.
 * This contract allows multiple owners to submit and confirm transactions.
 */
contract MultiSig {
    // Address of owners
    address[] public owners;

    // Number of confirmations required for transactions
    uint public numConfirmationsRequired;

    // Represents a transaction
    struct Transaction {
        address to;
        uint value;
        bool executed;
    }

    // Tracks which owner has confirmed a transaction
    mapping(uint => mapping(address => bool)) public isConfirmed;

    // Records of transactions
    Transaction[] public transactions;

    // Event emitted when a transaction is submitted
    event TransactionSubmitted(uint transactionId, address sender, address receiver, uint amount);

    // Event emitted when a transaction is confirmed by an owner
    event TransactionConfirmed(uint transactionId);

    // Event emitted when a transaction is executed
    event TransactionExecuted(uint transactionId);

    /**
     * @dev Modifier to ensure that only an owner can call a function.
     */
    modifier onlyOwner() {
        bool onlyOwnerFlag = false;

        for (uint i = 0; i < owners.length; i++) {
            if (msg.sender == owners[i]) {
                onlyOwnerFlag = true;
                break;
            }
        }

        require(onlyOwnerFlag, "Sender must be one of the owners");
        _;
    }

    /**
     * @dev Constructor initializes the contract with owners and the required number of confirmations.
     * @param _owners The addresses of the owners.
     * @param _numConfirmationsRequired The number of confirmations required for transactions.
     */
    constructor(address[] memory _owners, uint _numConfirmationsRequired) {
        require(_owners.length > 1, "More than one owner required");
        require(_numConfirmationsRequired > 0 && _numConfirmationsRequired <= _owners.length, "Invalid number of confirmations");

        for (uint i = 0; i < _owners.length; i++) {
            require(_owners[i] != address(0), "Invalid owner address");
            owners.push(_owners[i]);
        }

        numConfirmationsRequired = _numConfirmationsRequired;
    }

    /**
     * @dev Submits a transaction for approval.
     * @param _to The recipient's address.
     */
    function submitTransaction(address _to) public payable {
        require(_to != address(0), "Invalid receiver address");
        require(msg.value > 0, "Transfer amount must be greater than zero");

        uint transactionId = transactions.length;
        Transaction memory temp = Transaction(_to, msg.value, false);
        transactions.push(temp);

        emit TransactionSubmitted(transactionId, msg.sender, _to, msg.value);
    }

    /**
     * @dev Confirms a transaction. If the required number of confirmations is reached, the transaction is executed.
     * @param _transactionId The ID of the transaction to confirm.
     */
    function confirmTransaction(uint _transactionId) public onlyOwner {
        require(_transactionId < transactions.length, "Invalid transaction ID");
        require(!isConfirmed[_transactionId][msg.sender], "Already confirmed");

        isConfirmed[_transactionId][msg.sender] = true;
        emit TransactionConfirmed(_transactionId);

        if (isTransactionConfirmed(_transactionId)) {
            executeTransaction(_transactionId);
        }
    }

    /**
     * @dev Executes a transaction.
     * @param _transactionId The ID of the transaction to execute.
     */
    function executeTransaction(uint _transactionId) private {
        require(_transactionId < transactions.length, "Invalid transaction ID");
        require(!transactions[_transactionId].executed, "Already executed");

        // Execute the transaction
        (bool success, ) = transactions[_transactionId].to.call{value: transactions[_transactionId].value}("");
        require(success, "Transaction execution failed");

        // Mark as executed
        transactions[_transactionId].executed = true;

        emit TransactionExecuted(_transactionId);
    }

    /**
     * @dev Checks if a transaction has the required number of confirmations.
     * @param _transactionId The ID of the transaction to check.
     * @return True if the transaction is confirmed, false otherwise.
     */
    function isTransactionConfirmed(uint _transactionId) internal view returns (bool) {
        require(_transactionId < transactions.length, "Invalid transaction ID");

        uint confirmationCount;

        for (uint i = 0; i < owners.length; i++) {
            if (isConfirmed[_transactionId][owners[i]]) {
                confirmationCount++;
            }
        }

        return confirmationCount >= numConfirmationsRequired;
    }

    /**
     * @dev Gets the number of transactions.
     * @return The number of transactions.
     */
    function getTransactionLength() public view returns (uint) {
        return transactions.length;
    }
}
