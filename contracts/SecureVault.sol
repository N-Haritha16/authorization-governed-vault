// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./AuthorizationManager.sol";

contract SecureVault {
    AuthorizationManager public authorizationManager;

    event Deposit(address indexed from, uint256 amount);
    event Withdrawal(address indexed to, uint256 amount);

    constructor(address authManager) {
        authorizationManager = AuthorizationManager(authManager);
    }

    receive() external payable {
        // Accept deposits
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(
        address recipient,
        uint256 amount,
        uint256 nonce,
        uint256 expiry,
        bytes calldata signature
    ) external {
        require(address(this).balance >= amount, "Insufficient vault balance");

        // Request authorization validation
        bool allowed = authorizationManager.verifyAuthorization(
            address(this),
            recipient,
            amount,
            nonce,
            expiry,
            signature
        );

        require(allowed, "Authorization failed");

        // Transfer funds
        payable(recipient).transfer(amount);

        emit Withdrawal(recipient, amount);
    }
}
