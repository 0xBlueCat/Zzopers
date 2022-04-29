// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./librarys/Ownable.sol";
import "./librarys/Counters.sol";
import "./librarys/ERC721.sol";
import "./librarys/MerkleProof.sol";

abstract contract ZzoopersInterface {
    function mintTransfer(address to) public virtual returns (uint256);
}

/**
 * @title Zoobox contract
 */
contract Zoobox is ERC721, Ownable {
    using MerkleProof for *;

    bytes32 private _WhiteListMerkleRoot;
    ZzoopersInterface private _Zzoopers;

    bool private _SalesStarted = false;
    bool private _PublicSalesStarted = false;
    bool private _RedeemStarted = false;

    uint256 private _WhiteListSalesPrice = 0.1 ether;
    uint256 private _PublicSalesPrice = 0.15 ether;
    uint256 private _LimitAmount = 5555;
    uint256 private _PublicSalesCount = 0;

    uint256 private _TokenId = 1;

    string private _BaseURI = "";
    string private _ContractURI = "";

    event SetSalesPrice(
        uint256 newWhitelistSalesPrice,
        uint256 newPublicSalesPrice
    );

    event Redeem(uint256 tokenId, uint256 mintedTokenId);

    constructor(bytes32 whiteListMerkleRoot, address zzoopersAddress)
        ERC721("Zoobox", "Zoobox")
        Ownable()
    {
        _WhiteListMerkleRoot = whiteListMerkleRoot;
        _Zzoopers = ZzoopersInterface(zzoopersAddress);
    }

    function toggleSalesStarted() public onlyOwner {
        _SalesStarted = !_SalesStarted;
    }

    function togglePublicSalesStarted() public onlyOwner {
        _PublicSalesStarted = !_PublicSalesStarted;
    }

    function toggleRedeemStarted() public onlyOwner {
        _RedeemStarted = !_SalesStarted;
    }

    function setSalesPrice(
        uint256 whitelistSalesPrice,
        uint256 publicSalesPrice
    ) public onlyOwner {
        _WhiteListSalesPrice = whitelistSalesPrice;
        _PublicSalesPrice = publicSalesPrice;
        emit SetSalesPrice(whitelistSalesPrice, publicSalesPrice);
    }

    function getWhiteListSalesPrice() public view returns (uint256) {
        return _WhiteListSalesPrice;
    }

    function getPublicSalesPrice() public view returns (uint256) {
        return _PublicSalesPrice;
    }

    function getPublicSalesCount() public view returns (uint256) {
        return _PublicSalesCount;
    }

    function setZzoopers(address newZzoopersAddress) public onlyOwner {
        _Zzoopers = ZzoopersInterface(newZzoopersAddress);
    }

    function whiteListMint(bytes32[] calldata merkleProof) public payable {
        require(_SalesStarted, "Zoobox: Sales has not started");
        require(!isContract(msg.sender), "Zoobox: Cannot mint via contract");
        require(
            MerkleProof.verify(
                merkleProof,
                _WhiteListMerkleRoot,
                keccak256(abi.encodePacked(msg.sender))
            ),
            "Zoobox: Not in whitelist"
        );
        require(
            balanceOf(msg.sender) <= 2,
            "Zoobox: Can only mint 2 nfts per whitelist address"
        );
        require(msg.value >= _WhiteListSalesPrice, "Zoobox: Not enough money");

        require(_TokenId < _LimitAmount, "Zoobox: Limit reached");
        _mint(msg.sender, _TokenId);
        _TokenId++;
    }

    function publicMint() public payable {
        require(
            _SalesStarted && _PublicSalesStarted,
            "Zoobox: Public sales has not started"
        );
        require(!isContract(msg.sender), "Zoobox: Cannot mint via contract");
        require(msg.value >= _PublicSalesPrice, "Zoobox: Not enough money");
        require(
            balanceOf(msg.sender) <= 5,
            "Zoobox: Can only mint 5 nfts per address"
        );

        require(_TokenId < _LimitAmount, "Zoobox: Limit reached");
        _PublicSalesCount++;
        _mint(msg.sender, _TokenId);
        _TokenId++;
    }

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function redeem(uint256 tokenId) public returns (uint256) {
        require(
            msg.sender == ownerOf(tokenId),
            "Zoobox: Only NFT owner can redeem"
        );
        _burn(tokenId);
        uint256 mintedId = _Zzoopers.mintTransfer(msg.sender);
        emit Redeem(tokenId, mintedId);
        return mintedId;
    }

    function _burn(uint256 tokenId) internal override(ERC721) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        return _BaseURI;
    }

    function setBaseURI(string calldata baseURI) public onlyOwner {
        _BaseURI = baseURI;
    }

    function setContractURI(string calldata contractUri) public onlyOwner {
        _ContractURI = contractUri;
    }

    function contractURI() public view returns (string memory) {
        return _ContractURI;
    }

    function withdrawFunds() public onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }
}
