// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract VRFConsumerBaseV2 {
    error OnlyCoordinatorCanFulfill(address have, address want);

    address private immutable vrfCoordinator;

    constructor(address _vrfCoordinator) {
        vrfCoordinator = _vrfCoordinator;
    }

    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal virtual;

    function rawFulfillRandomWords(uint256 requestId, uint256[] memory randomWords) external {
        if (msg.sender != vrfCoordinator) {
            revert OnlyCoordinatorCanFulfill(msg.sender, vrfCoordinator);
        }
        fulfillRandomWords(requestId, randomWords);
    }
}

interface VRFCoordinatorV2Interface {
    function getRequestConfig() external view returns (uint16, uint32, bytes32[] memory);
    function requestRandomWords(
        bytes32 keyHash,
        uint64 subId,
        uint16 minimumRequestConfirmations,
        uint32 callbackGasLimit,
        uint32 numWords
    ) external returns (uint256 requestId);
    function createSubscription() external returns (uint64 subId);
    function getSubscription(uint64 subId)
        external
        view
        returns (uint96 balance, uint64 reqCount, address owner, address[] memory consumers);
    function requestSubscriptionOwnerTransfer(uint64 subId, address newOwner) external;
    function acceptSubscriptionOwnerTransfer(uint64 subId) external;
    function addConsumer(uint64 subId, address consumer) external;
    function removeConsumer(uint64 subId, address consumer) external;
    function cancelSubscription(uint64 subId, address to) external;
    function pendingRequestExists(uint64 subId) external view returns (bool);
}

contract VRFv2Consumer is VRFConsumerBaseV2 {
    VRFCoordinatorV2Interface COORDINATOR;
    uint64 s_subscriptionId;
    address vrfCoordinator = 0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625;
    bytes32 keyHash = 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c;
    uint32 callbackGasLimit = 200000;
    uint16 requestConfirmations = 3;
    uint32 public numWords = 1;
    uint256[] public s_randomWords;
    uint256 public s_requestId;
    address s_owner;

    constructor(uint64 subscriptionId) VRFConsumerBaseV2(vrfCoordinator) {
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        s_owner = msg.sender;
        s_subscriptionId = subscriptionId;
    }

    function requestRandomWords() external {
        s_requestId =
            COORDINATOR.requestRandomWords(keyHash, s_subscriptionId, requestConfirmations, callbackGasLimit, numWords);
    }

    function fulfillRandomWords(uint256, uint256[] memory randomWords) internal override {
        s_randomWords = randomWords;
    }

    modifier onlyOwner() {
        require(msg.sender == s_owner);
        _;
    }
}
