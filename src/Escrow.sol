// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/security/ReentrancyGuard.sol";
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";



contract Escrow is ReentrancyGuard {
    address public companyAddress = 0x7fB674ABDe76C777B56cD362b8Fd16389254a342;
    address public feeAddress = 0x35064FAcBD34C7cf71C7726E7c9F23e4650eCA10;
    uint256 public feePercentage = 10;
    // uint256 public totalAmount;
    uint256 public companyAccrued;

    enum PaymentState {
        Pending,
        Confirmed,
        Refunded
    }

    PaymentState constant defaultState = PaymentState.Pending;

    struct PaymentDetails{
        PaymentState state;
        uint256 Amount;
        uint256 fee;
        address token;
    }

    modifier onlyOwner() {
        require(msg.sender == companyAddress, "Unauthorized entity");
        _;
    }

    mapping(address => PaymentDetails) public individualPayments;
    PaymentDetails[] public Orders;


    function Deposit(address _token, uint256 _amount) public {
        require(msg.sender != address(0), "Must be an Address");
        uint256 fee = (_amount * feePercentage) / 100;
        uint256 totalAmount = _amount + fee;
        uint256 companyAmount = totalAmount - _amount;

        require(IERC20(_token).balanceOf(msg.sender) >= totalAmount, "Insufficient Amount");

        IERC20(_token).transferFrom(msg.sender, companyAddress, companyAmount);
        IERC20(_token).transferFrom(msg.sender, feeAddress, fee);

        PaymentDetails storage payment = individualPayments[msg.sender];

        payment.Amount = _amount;
        payment.fee = fee;
        payment.token = _token;
        payment.state = PaymentState.Confirmed;
        
        Orders.push(payment);
        

    }

    function refundCustomer(address _customer,  address _token) public onlyOwner() {
        require(_customer != address(0), "custemer can't be address(0)");
        require(_token != address(0), "invalid token");

        PaymentDetails storage paymt = individualPayments[_customer];
        uint256 amountToRefund = paymt.Amount;
        IERC20(_token).transferFrom(companyAddress, _customer, amountToRefund);
    }





}