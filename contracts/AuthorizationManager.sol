import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract AuthorizationManager {
    address public immutable vault;
    address public immutable authSigner;

    ...

    function verifyAuthorization(
        address recipient,
        uint256 amount,
        bytes32 authId,
        bytes calldata signature
    ) external returns (bool) {
        if (msg.sender != vault) revert NotVault();
        if (usedAuthorizations[authId]) revert AuthorizationAlreadyUsed();

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

        bytes32 ethSigned = ECDSA.toEthSignedMessageHash(msgHash);
        address recovered = ECDSA.recover(ethSigned, signature);
        if (recovered != authSigner) revert InvalidSignature();

        usedAuthorizations[authId] = true;
        emit AuthorizationUsed(authId, recipient, amount);
        return true;
    }
}
