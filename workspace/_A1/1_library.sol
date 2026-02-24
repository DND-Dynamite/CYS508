// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BookMarketplace {
    struct Book {
        string title;
        uint price;
        bool isSold;
        address owner;
    }

    mapping(uint => Book) public books;
    uint public bookCount;

    // Add or set a book by its title and price [cite: 7]
    function addBook(string memory _title, uint _price) public {
        bookCount++;
        // Use a Boolean variable to check if sold and trace the owner address [cite: 8, 9]
        books[bookCount] = Book(_title, _price, false, msg.sender);
    }

    // Get book values from the blockchain network [cite: 11]
    function getBook(uint _id) public view returns (string memory, uint, bool, address) {
        Book storage b = books[_id];
        return (b.title, b.price, b.isSold, b.owner);
    }

    // Buy book: check balance, transfer ownership, and refund excess [cite: 12, 13, 14]
    function buyBook(uint _id) public payable {
        Book storage b = books[_id];
        require(!b.isSold, "Book already sold");
        require(msg.value >= b.price, "Insufficient balance"); // [cite: 12]

        address previousOwner = b.owner;
        b.owner = msg.sender; // Ownership transferred to buyer [cite: 13]
        b.isSold = true;

        // FIXED: Using .call instead of .transfer to avoid deprecation warning
        (bool success, ) = payable(previousOwner).call{value: b.price}("");
        require(success, "Transfer to seller failed");

        // Refund excess amount if buyer paid more than book price 
        if (msg.value > b.price) {
            uint refundAmount = msg.value - b.price;
            (bool refundSuccess, ) = payable(msg.sender).call{value: refundAmount}("");
            require(refundSuccess, "Refund failed");
        }
    }
}