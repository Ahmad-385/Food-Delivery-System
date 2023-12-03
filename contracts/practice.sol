// SPDX-License-Identifier: GPD-3.0
pragma solidity >0.4.0 <0.9.0;

contract FoodDelivery {
   
    // Struct to represent an order
    struct Order {
        address customer; // Customer's Ethereum address
        string restaurant; // Name of the restaurant
        uint256 timestamp; // Timestamp when the order was placed
        OrderStatus status; // Status of the order (Placed or Delivered)
    }

    // Owner's Ethereum address
    address payable public owner;

    // Constructor to set the contract owner as the deployer
    constructor() {
        owner = payable(msg.sender);
    }

    // Enum to represent the status of an order
    enum OrderStatus { Placed, Delivered }

    // Mapping to store orders using order ID
    mapping(uint256 => Order) public orders;

    // Counter for the number of orders placed
    uint256 public orderCount;

    // Event emitted when a new order is placed
    event OrderPlaced(uint256 orderId, address customer, string restaurant, uint256 timestamp);

    // Event emitted when an order is delivered
    event OrderDelivered(uint256 orderId, uint256 timestamp);

    // Function to allow customers to place an order
    function placeOrder(string memory _restaurant) external {
        orderCount++;
        Order storage newOrder = orders[orderCount];
        newOrder.customer = msg.sender;
        newOrder.restaurant = _restaurant;
        newOrder.timestamp = block.timestamp;
        newOrder.status = OrderStatus.Placed;

        emit OrderPlaced(orderCount, msg.sender, _restaurant, block.timestamp);
    }

    // Variable to store the total balance received by the contract
    uint public balanceReceived;

    // Function to receive money (ETH) to the contract
    function receivedMoney() public payable {
        balanceReceived += msg.value;
    }

    // Function to get the current balance of the contract
    function getBalance() public view returns(uint) {
        return address(this).balance;
    }

    // Function to allow the owner to withdraw funds from the contract
    function withdrawMoneyTo(address payable _to) public {
        require(msg.sender == owner, "Only owner can withdraw funds");
        _to.transfer(getBalance());
    }

    // Function to confirm the delivery of an order
    function deliverOrder(uint256 _orderId) external {
        require(_orderId > 0 && _orderId <= orderCount, "Invalid order ID");
        Order storage order = orders[_orderId];
        require(order.customer == msg.sender, "Unauthorized");
        require(order.status == OrderStatus.Placed, "Order is not placed");

        order.status = OrderStatus.Delivered;

        emit OrderDelivered(_orderId, block.timestamp);
    }
}
