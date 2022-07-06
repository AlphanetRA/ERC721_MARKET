// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract Market {

    using SafeERC20 for IERC20;

    event TradeStatusChange(uint256 trade, string status);

    IERC20 public currencyToken;
    IERC721 public itemToken;
    uint256 public tradeCounter;

    struct Trade {
        address poster;
        uint256 item;
        uint256 price;
        bytes32 status; // Open, Executed, Cancelled
    }

    mapping(uint256 => Trade) public trades;

    constructor(address _currencyTokenAddress, address _itemTokenAddress) {
        currencyToken = IERC20(_currencyTokenAddress);
        itemToken = IERC721(_itemTokenAddress);
        tradeCounter = 0;
    }

    function openTrade(uint256 _item, uint256 _price) public {
        itemToken.transferFrom(msg.sender, address(this), _item);
        trades[tradeCounter] = Trade(msg.sender, _item, _price, "Open");
        tradeCounter++;
        
        emit TradeStatusChange(tradeCounter - 1, "Open");
    }

    function executeTrade(uint256 _tradeId) public {
        Trade memory trade = trades[_tradeId];
        require(trade.status == "Open", "Trade is not open.");
        currencyToken.safeTransferFrom(msg.sender, trade.poster, trade.price);
        itemToken.transfer(msg.sender, trade.item);
        trades[_tradeId].status = "Executed";

        emit TradeStatusChange(_tradeId, "Executed");
    }

    function cancelTrade(uint256 _tradeId) public {
        Trade memory trade = trades[_tradeId];
        require(msg.sender == trade.poster, "Trade can be cancelled only by poster.");
        require(trade.status == "Open", "Trade is not open.");
        itemToken.transfer(trade.poster, trade.item);
        trades[_tradeId].status = "Cancelled";

        emit TradeStatusChange(_tradeId, "Cancelled");
    }
}