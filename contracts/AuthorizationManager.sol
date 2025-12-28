// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract AuthorizationManager {
    address public vault;
    address public signer;

    // Stores authorization identifiers
    mapping(bytes32 => bool) private consumed;

    modifier onlyVault() {
        require(msg.sender == vault, "Only vault allowed");
        _;
    }

    constructor(address _signer) {
        signer = _signer;
    }

    function setVault(address _vault) external {
        require(vault == address(0), "Vault already set");
        vault = _vault;
    }

    // Confirms whether a withdrawal is permitted
    // Parameters encode:
    // - vault address
    // - recipient
    // - amount
    // - unique authorization identifier (nonce)
    // - signature data
    function verifyAuthorization(
        address vaultAddress,
        address recipient,
        uint256 amount,
        uint256 nonce,
        uint256 expiry,
        bytes calldata signature
    ) external onlyVault returns (bool) {
        require(block.timestamp <= expiry, "Authorization expired");

        bytes32 authHash = keccak256(
            abi.encode(
                vaultAddress,
                block.chainid,
                recipient,
                amount,
                nonce,
                expiry
            )
        );

        require(!consumed[authHash], "Authorization already used");

        bytes32 ethMessage = keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", authHash)
        );

        require(_recover(ethMessage, signature) == signer, "Invalid signature");

        // Mark authorization as consumed
        consumed[authHash] = true;

        return true;
    }

    function _recover(bytes32 hash, bytes memory sig) internal pure returns (address) {
        require(sig.length == 65, "Invalid signature");

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }

        return ecrecover(hash, v, r, s);
    }
}
