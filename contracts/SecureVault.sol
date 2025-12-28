// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IAuthorizationManager {
    function verifyAuthorization(
        address recipient,
        uint256 amount,
        bytes32 authId,
        bytes calldata signature
    ) external returns (bool);
}

contract SecureVault {
    IAuthorizationManager public immutable authorizationManager;

    // Simple internal accounting (per user)
    mapping(address => uint256) public balances;

    event Deposited(address indexed from, uint256 amount);
    event Withdrawn(address indexed to, uint256 amount, bytes32 indexed authId);

    constructor(address _authorizationManager) {
        require(_authorizationManager != address(0), "auth mgr zero");
        authorizationManager = IAuthorizationManager(_authorizationManager);
    }

    // Accept deposits, track per-sender
    receive() external payable {
        balances[msg.sender] += msg.value;
        emit Deposited(msg.sender, msg.value);
    }

    /// @notice Withdraw funds after passing authorization validation.
    /// @param recipient Receiver address.
    /// @param amount Amount to withdraw.
    /// @param authId Unique authorization id.
    /// @param signature Off-chain authorization signature.
    function withdraw(
        address recipient,
        uint256 amount,
        bytes32 authId,
        bytes calldata signature
    ) external {
        // 1. Ask manager to validate (includes replay protection)
        bool ok = authorizationManager.verifyAuthorization(
            recipient,
            amount,
            authId,
            signature
        );
        require(ok, "authorization failed");

        // 2. Update internal accounting BEFORE transfer
        require(balances[recipient] >= amount, "insufficient balance");
        balances[recipient] -= amount;

        // 3. Transfer funds
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "transfer failed");

        emit Withdrawn(recipient, amount, authId);
    }
}
