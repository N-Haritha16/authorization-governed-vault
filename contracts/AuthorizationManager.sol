// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract AuthorizationManager {
    address public vault;
    address public signer;
    mapping(bytes32 => bool) public used;

    constructor(address _vault, address _signer) {
        vault = _vault;
        signer = _signer;
    }

    function verifyAuthorization(
        address _vault,
        address recipient,
        uint256 amount,
        bytes32 authId,
        bytes calldata signature
    ) external returns (bool) {
        require(!used[authId], "Authorization already used");
        used[authId] = true;
        return true;
    }
}
