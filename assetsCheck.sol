pragma solidity ^0.7.6;


library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }


    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}


contract assetsCheck {
    using SafeMath for uint;
    uint public startTime;
    uint public preSaleActiveTime = 0;
    uint public postSaleLimit;
    event TransactionStatus(address _to,  bool status);
    mapping (address => uint) public preSaletokenLimit;
    mapping (address => uint) public postSaletokenLimit;
    mapping (address => bool) public isWhiteListed;
    mapping (address => uint) public valueReceived;
    uint public preSalePrice = 0.035 * 1 ether;
    uint public postSalePrice = 0.01 * 1 ether;
    address payable private receiver = payable(0x583031D1113aD414F02576BD6afaBfb302140225);
    address payable private secondOwner = payable(0xdD870fA1b7C4700F2BD7f44238821C26f7392148);
    address private owner;


    constructor (

    ) {
                 startTime = block.timestamp;
                 owner = msg.sender;
        }

    modifier onlyOwner {
        require (msg.sender == owner);
        _;
    }
//Sahil check please
  function tokenSale (address _to, uint tokenAmount) external onlyOwner {
        if (isPreSaleActive()==true) {
            require (tokenAmount <= 1);
            require(isWhiteListed[_to] == true,"User is not whitelisted");
            require (preSaletokenLimit[_to] <= 1, "Purchase Limit Fullfilled");
            require (valueReceived[msg.sender] >= preSalePrice.mul(tokenAmount),"Not received");
            valueReceived[msg.sender] = valueReceived[msg.sender].sub(preSalePrice.mul(tokenAmount));
            preSaletokenLimit[_to] = preSaletokenLimit[_to] + tokenAmount;
            emit TransactionStatus(_to, true);
        }
        else {
            require (postSaletokenLimit[_to]+tokenAmount <= postSaleLimit);
            require (postSaletokenLimit[_to] <= postSaleLimit, 'Limit Fulfilled');
            require (valueReceived[msg.sender] >= postSalePrice.mul(tokenAmount));
            valueReceived[msg.sender] = valueReceived[msg.sender].sub(postSalePrice.mul(tokenAmount));
            postSaletokenLimit[_to] = postSaletokenLimit[_to] + tokenAmount;
            emit TransactionStatus(_to, true);
        }
    }

    function isPreSaleActive() public view returns (bool) {
        if (block.timestamp < (startTime+(preSaleActiveTime * 1 days))) {
            return (true);
        }else {
            return (false);
        }
    }

    function whiteListAddress (address _sender) external onlyOwner {
        isWhiteListed[_sender] = true;
    }

    function setPostSalePrice (uint _amount) external onlyOwner {
        postSalePrice = _amount * 1 ether;
    }

    function setPreSaleTimeLimit (uint _day) external onlyOwner {
        preSaleActiveTime = _day;
    }

    function setPostSaleLimit (uint _tokenLimit) external onlyOwner {
        postSaleLimit = _tokenLimit;
    }


    fallback () external payable {
        receiver.transfer((address(this).balance).div(2));
        secondOwner.transfer(address(this).balance);
        valueReceived[msg.sender] = msg.value;
    }
}
