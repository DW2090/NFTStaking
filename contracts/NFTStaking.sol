//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contract/token/ERC20/IERC20.sol";
import "@openzeppelin/contract/token/ERC721/IERC721.sol";
import "@openzeppelin/contract/utils/math/SafeMath.sol";
import "@openzeppelin/contract/access/Ownable.sol";
import "@openzeppelin/contract/token/ERC721/utils/ERC721Holder.sol";

import "hardhat/console.sol";

interface IRewardToken is IERC20 {
    function mint(address to, uint256 amount) external;
}

contract NFTStaking is ERC721Holder, Ownable {
    using SafeMath for uint256;
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    struct Staker {
        uint256[] tokenIds;
        uint256 balance;
        uint256 rewardsReleased;
        mapping(uint256 => uint256) tokenStakingCoolDown;
    }

    uint256 stakingStartTime;

    mapping(address => Staker) public stakers;
    mapping(uint256 => address) public tokenOwner;
    bool public tokensClaimable;
    bool initialized;

    event Staked(address indexed owner, uint256 amount);
    event Unstaked(address indexed owner, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);
    event ClaimableStatusUpdated(bool status);

    function initStaking() external onlyOwner{
        require(!initialized, "Already initialized!");
        stakingStartTime = block.timestamp;
        initialized = true;
    }

    function setTokensClaimable(bool _enabled) external onlyOwner {
        tokensClaimable = _enabled;
        emit ClaimableStatusUpdated(_enabled);
    }

    function getStakedTokens(address _user) external view returns (uint256[] memory tokenIds) {
        return stakers[_user].tokenIds;
    }

}
