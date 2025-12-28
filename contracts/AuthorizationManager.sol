// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract AuthorizationManager {
    using ECDSA for bytes32;

    address public immutable vault;
    address public immutable authSigner; // trusted off-chain signer

    // authId -> used?
    mapping(bytes32 => bool) public usedAuthorizations;

    event AuthorizationUsed(bytes32 indexed authId, address indexed recipient, uint256 amount);

    error InvalidSignature();
    error AuthorizationAlreadyUsed();
    error NotVault();

    constructor(address _vault, address _authSigner) {
        require(_vault != address(0), "vault zero");
        require(_authSigner != address(0), "signer zero");
        vault = _vault;
        authSigner = _authSigner;
    }

    /// @notice Called ONLY by the vault to validate a withdrawal authorization.
    /// @param recipient Receiver of funds.
    /// @param amount Amount to withdraw.
    /// @param authId Unique authorization identifier (nonce).
    /// @param signature Off-chain signature from `authSigner`.
    function verifyAuthorization(
        address recipient,
        uint256 amount,
        bytes32 authId,
        bytes calldata signature
    ) external returns (bool) {
        if (msg.sender != vault) revert NotVault();
        if (usedAuthorizations[authId]) revert AuthorizationAlreadyUsed();

        // Bind to: manager, vault, chainId, recipient, amount, authId
        bytes32 msgHash = keccak256(
            abi.encodePacked(
                address(this),
                vault,
                block.chainid,
                recipient,
                amount,
                authId
            )
        );
        bytes32 ethSigned = msgHash.toEthSignedMessageHash();
        address recovered = ethSigned.recover(signature);
        if (recovered != authSigner) revert InvalidSignature();

        usedAuthorizations[authId] = true;
        emit AuthorizationUsed(authId, recipient, amount);
        return true;
    }
}
