// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

/// @notice Imporing these packages directly due to naming conflicts between "Account" and "Chain" structs.
import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {Vm} from "forge-std/Vm.sol";
import "../src/DoubleTokenLexscrowRegistry.sol";
import "../src/RicardianTriplerDoubleTokenLexscrow.sol";

contract RicardianTriplerDoubleTokenLexscrowTest is Test {
    DoubleTokenLexscrowRegistry registry;
    AgreementV1Factory factory;
    AgreementDetailsV1 details;

    uint256 internal constant FACTORY_VERSION = 1;
    uint256 internal constant AGREEMENT_VERSION = 1;

    uint256 mockKey = 100;
    uint256 firstPartyNonce;
    address firstParty = address(1);
    address secondParty = address(2);

    function setUp() public {
        address fakeAdmin = address(0xaa);

        registry = new DoubleTokenLexscrowRegistry(fakeAdmin);
        factory = new AgreementV1Factory(address(registry));
        details = getMockAgreementDetails();

        vm.prank(fakeAdmin);
        registry.enableFactory(address(factory));
    }

    function testVersion() public {
        assertEq(FACTORY_VERSION, factory.version(), "factory version != 1");

        RicardianTriplerDoubleTokenLexscrow newAgreement = new RicardianTriplerDoubleTokenLexscrow(details);
        assertEq(AGREEMENT_VERSION, newAgreement.version(), "agreement version != 1");
    }

    function testDetails() public {
        RicardianTriplerDoubleTokenLexscrow newAgreement = new RicardianTriplerDoubleTokenLexscrow(details);
        _assertEq(getMockAgreementDetails(), newAgreement.getDetails());
    }

    function _assertEq(AgreementDetailsV1 memory expected, AgreementDetailsV1 memory actual) public {
        bytes memory expectedBytes = abi.encode(expected);
        bytes memory actualBytes = abi.encode(actual);

        assertEq0(expectedBytes, actualBytes);
    }

    function testProposeAndConfirmDoubleTokenLexscrowAgreement() public {
        ++firstPartyNonce;
        vm.prank(firstParty);
        address _newAgreement = factory.proposeDoubleTokenLexscrowAgreement(details);
        assertEq(factory.pendingAgreement(firstParty, _newAgreement), secondParty, "secondParty should be pending");

        vm.prank(secondParty);
        factory.confirmAndAdoptDoubleTokenLexscrowAgreement(_newAgreement, firstParty);

        assertEq(registry.agreements(firstParty, firstPartyNonce), _newAgreement, "agreement address does not match");

        // if successful, this mapping should be deleted
        assertEq(
            address(0),
            factory.pendingAgreement(firstParty, _newAgreement),
            "pending Agreement mapping not reset"
        );
    }

    function testProposeAndConfirmDoubleTokenLexscrowAgreement_invalid(address _randomAddr) public {
        ++firstPartyNonce;
        vm.prank(firstParty);
        address _newAgreement = factory.proposeDoubleTokenLexscrowAgreement(details);
        assertEq(factory.pendingAgreement(firstParty, _newAgreement), secondParty, "secondParty should be pending");

        vm.prank(_randomAddr);
        if (_randomAddr != secondParty) {
            vm.expectRevert();
            factory.confirmAndAdoptDoubleTokenLexscrowAgreement(_newAgreement, firstParty);

            // 'secondParty' should still be pending
            assertEq(secondParty, factory.pendingAgreement(firstParty, _newAgreement), "second party not pending");
        }
    }

    function testValidateAccount() public {
        Account memory account = Account({accountAddress: vm.addr(mockKey), signature: new bytes(0)});
        bytes32 hash = keccak256(abi.encode(details));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(mockKey, hash);
        bytes memory signature = abi.encodePacked(r, s, v);

        account.signature = signature;

        bool isValid = factory.validateAccount(details, account);
        assertTrue(isValid);
    }

    function testValidateAccount_invalid() public {
        Account memory account = Account({accountAddress: vm.addr(mockKey), signature: new bytes(0)});
        uint256 fakeKey = 200;

        bytes32 hash = keccak256(abi.encode(details));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(fakeKey, hash);
        bytes memory signature = abi.encodePacked(r, s, v);

        account.signature = signature;

        bool isValid = factory.validateAccount(details, account);
        assertTrue(!isValid);
    }

    function getMockAgreementDetails() internal pure returns (AgreementDetailsV1 memory mockDetails) {
        Party memory _partyA = Party({
            partyBlockchainAddy: address(1),
            partyName: "Party A",
            contactDetails: "partyA@email.com"
        });
        Party memory _partyB = Party({
            partyBlockchainAddy: address(2),
            partyName: "Party B",
            contactDetails: "partyB@email.com"
        });
        LockedAsset memory _lockedAssetPartyA = LockedAsset({tokenContract: address(3), totalAmount: 999999999999});
        LockedAsset memory _lockedAssetPartyB = LockedAsset({tokenContract: address(4), totalAmount: 8888888888888});

        mockDetails = AgreementDetailsV1({
            partyA: _partyA,
            partyB: _partyB,
            lockedAssetPartyA: _lockedAssetPartyA,
            lockedAssetPartyB: _lockedAssetPartyB,
            legalAgreementURI: "ipfs://testHash",
            governingLaw: "MetaLaW",
            disputeResolutionMethod: "coin flip"
        });

        return mockDetails;
    }
}
