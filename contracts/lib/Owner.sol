pragma solidity >=0.5.0 <0.8.0;

contract Owner {
    address public owner;

    modifier onlyOwner() {
        require(owner==msg.sender,'no permission');
        _;
    }

    function changeOwner(address _owner) public onlyOwner{
        owner = _owner;
    }
}