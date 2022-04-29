// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./librarys/Ownable.sol";

/**
 * @title Zzoopers contract
 */
contract ZzoopersRandomizer is Ownable {
    constructor() Ownable() {
    }

    function getTokenId(uint256 tokenId) public virtual returns(uint){

    }
}
