// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Storage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract MyNFT is ERC721Enumerable, ERC721Storage, ERC721Pausable, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    address public factoryAddress;

    constructor(
        string memory collName,
        string memory collSymbol
    ) ERC721(collName, collSymbol) {
        factoryAddress = msg.sender;
    }

    modifier onlyFactory() {
        require(
            msg.sender == factoryAddress,
            "MyNFT: Only factory can call this function"
        );
        _;
    }

    function _baseURI() internal pure override returns (string memory) {
        return "https://my-nft-api.com/token/";
        //check uri
    }

    function mint(address to) external onlyFactory returns (uint256) {
        _tokenIdCounter.increment();
        uint256 newTokenId = _tokenIdCounter.current();
        _safeMint(to, newTokenId);
        string memory tokenURI = string.concat(
            Strings.toString(newTokenId),
            ".json"
        );
    }

    function beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize) internal override(ERC721, ERC721Enumerable, ERC721Pausable) {
        super.beforeTokenTransfer(from, to, tokenId, batchSize);
}

function burn(unit256 tokenID) internal override(ERC721, ERC721Storage) {
    super.burn(tokenID);
}

function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
    return super.tokenURI(tokenId);
}

function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable, ERC721URIStorage ) returns (bool) {
    return super.supportsInterface(interfaceId);
}

function pause() external onlyFactory {
    _pause();
}

function unpause() external onlyFactory {
    _unpause();
}

};