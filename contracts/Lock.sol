// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract Lock {
    uint256 public unlockTime;
    address public owner;

    struct Deposit {
        uint256 unlockTime;
        uint256 amount;
        bool withdrawn;
    }

    mapping(address => Deposit[]) deposits;

    address _paymentToken;

    event Withdrawal(uint256 amount, uint256 when);

    constructor(address tokenAddress) payable {
        _paymentToken = tokenAddress;
    }

    function depositToken(
        uint256 _unlockTime,
        address recipient,
        uint256 amount
    ) public {
        require(
            block.timestamp < _unlockTime,
            "Unlock time should be in the future"
        );

        unlockTime = _unlockTime;
        owner = recipient;

        ERC20(_paymentToken).transferFrom(msg.sender, address(this), amount);

        deposits[recipient].push(Deposit(unlockTime, amount, false));
    }

    function withdraw() public {
        
        uint256 withdrawAmount;

        Deposit[] memory _deposits = deposits[msg.sender];

        for (uint256 i = 0; i < _deposits.length; i++) {
            if (block.timestamp >= _deposits[i].unlockTime) {
                if (!_deposits[i].withdrawn) {
                    _deposits[i].withdrawn = true;

                    withdrawAmount += _deposits[i].amount;

                    // TODO - remove deposit from array (swap n' pop?)
                }
            }
        }

        emit Withdrawal(withdrawAmount, block.timestamp);

        ERC20(_paymentToken).transfer(msg.sender, withdrawAmount);
    }
}
