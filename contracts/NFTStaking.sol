//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";

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
    uint256 stakedTotal;

    address nft;
    address rewardsToken;

    mapping(address => Staker) public stakers;
    mapping(uint256 => address) public tokenOwner;
    bool public tokensClaimable;
    bool initialized;

    event Staked(address indexed owner, uint256 amount);
    event Unstaked(address indexed owner, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);
    event ClaimableStatusUpdated(bool status);

    constructor(address _nft, address _rewardToken) {
        require(_nft != address(0x00) && _rewardToken != address(0x00), "InValid Address");
        nft = _nft;
        rewardsToken = _rewardToken;
    }

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

    function statke(uint256 tokenId) external {
        _stake(msg.sender, tokenId);
    }

    function _stake(address _user, uint256 _tokenId) internal {
        require(initialized, "Staking System: the staking has not started");
        require(IERC721(nft).ownerOf(_tokenId) == _user, "user must be the owner of the token");
        
        Staker storage staker = stakers[_user];

        staker.tokenIds.push(_tokenId);
        staker.tokenStakingCoolDown[_tokenId] = block.timestamp;
        tokenOwner[_tokenId] = _user;
        IERC721(nft).approve(address(this), _tokenId);
        IERC721(nft).safeTransferFrom(_user, address(this), _tokenId);

        emit Staked(_user, _tokenId);
        stakedTotal.add(1);
    }

    function _unstake(address _user, uint256 _tokenId) internal {
        require(tokenOwner[_tokenId] == _user, "NFT Staking System: user must be the owner of the staked nft");
        Staker storage staker = stakers[_user];

        uint256 lastIndex = staker.tokenIds.length - 1;
        uint256 lastIndexKey = staker.tokenIds[lastIndex];
        if (staker.tokenIds.length > 0) {
            staker.tokenIds.pop();
        }
        staker.tokenStakingCoolDown[_tokenId] = 0;
        if (staker.balance == 0) {
            delete stakers[_user];
        }
        delete tokenOwner[_tokenId];

        IERC721(nft).safeTransferFrom(address(this), _user, _tokenId);
        emit Unstaked(_user, _tokenId);
        stakedTotal.sub(1);
    }

    function claimReward(address _user) external {
        require(tokensClaimable == true, "Tokens cannot be claimed yet");
        require(stakers[_user].balance > 0, "0 rewards yet");

        stakers[_user].rewardsReleased = stakers[_user].balance.add(stakers[_user].rewardsReleased);
        stakers[_user].balance = 0;
        IRewardToken(rewardsToken).mint(_user, stakers[_user].balance);

        emit RewardPaid(_user, stakers[_user].balance);
    }

}
