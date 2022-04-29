// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./librarys/Ownable.sol";
import "./librarys/Counters.sol";
import "./librarys/ERC721.sol";

abstract contract ZzoopersRandomizer {
    function getTokenId(uint256 tokenId) public view virtual returns(uint);
}

/**
 * @title Zzoopers contract
 */
contract Zzoopers is ERC721, Ownable {
    uint256 private _TokenId = 1;

    address private _ZooboxAddress;
    ZzoopersRandomizer private _Randomizer;

    mapping(uint32=>string) private _BaseURIs;
    string private _ContractURI = "";

    constructor(address zooBoxAddress, address randomizerAddress) ERC721("Zzoopers", "Zzoopers") Ownable() {
        _ZooboxAddress = zooBoxAddress;
        _Randomizer = ZzoopersRandomizer(randomizerAddress);
    }

    function setZooboxAddress(address newZooboxAddress)public onlyOwner{
        _ZooboxAddress = newZooboxAddress;
    }

    function setRandomizer(address randomizer)public onlyOwner{
        _Randomizer = ZzoopersRandomizer(randomizer);
    }

    function mintTransfer(address to) public returns (uint256){
        require(msg.sender == _ZooboxAddress, "Zzoopers: Invalid caller");
        _mint(to, _TokenId);
        return _Randomizer(_TokenId);
    }

    function setContractURI(string calldata contractUri) public onlyOwner {
        _ContractURI = contractUri;
    }

    function contractURI() public view returns (string memory) {
        return _ContractURI;
    }
}
