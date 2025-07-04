// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155SupplyUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract ChaoticProImplementation is 
    Initializable, 
    ERC1155SupplyUpgradeable, 
    OwnableUpgradeable, 
    ReentrancyGuardUpgradeable,
    UUPSUpgradeable 
{
    using SafeERC20 for IERC20;
    
    string public name;
    string public symbol;
    uint256[128] __gap;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(
        string memory _name,
        string memory _symbol,
        string memory _uri,
        address initialOwner
    ) public initializer {
        __ERC1155_init(_uri);
        __ERC1155Supply_init();
        __Ownable_init(initialOwner);
        __ReentrancyGuard_init();
        __UUPSUpgradeable_init();
        
        name = _name;
        symbol = _symbol;
    }

    function mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public onlyOwner nonReentrant {
        _mintBatch(to, ids, amounts, data);
    }

    function mint(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public onlyOwner nonReentrant {
        _mint(to, id, amount, data);
    }

    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

    function withdraw() public onlyOwner nonReentrant {
        uint256 balance = address(this).balance;
        require(balance > 0, "No ETH to withdraw");
        
        (bool success, ) = payable(owner()).call{value: balance}("");
        require(success, "Withdrawal failed");
    }

    function withdrawERC20(address tokenAddress) public onlyOwner nonReentrant {
        IERC20 token = IERC20(tokenAddress);
        uint256 balance = token.balanceOf(address(this));
        require(balance > 0, "No tokens to withdraw");
        
        token.safeTransfer(owner(), balance);
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
}
