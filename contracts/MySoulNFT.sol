// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract MySoulNFT is ERC721, ERC721Enumerable, ERC721URIStorage, ERC721Pausable, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    address public factoryAddress;

    uint256 public immutable hardCap;

    error notAnOwnerOrFactory();
    error maxSupplyReached();

    constructor(
        string memory collName,
        string memory collSymbol
    ) ERC721(collName, collSymbol) {
        factoryAddress = msg.sender;
        hardCap = 10;
    }

    modifier onlyFactory() {
        if(msg.sender != factoryAddress) {
            revert notAnOwnerOrFactory();
        }
        _;
    }

    function _baseURI() internal pure override returns (string memory) {
        return "https://my-nft-api.com/token/";
        //check uri
    }

    function mint(address to) public onlyOwner {
        _tokenIdCounter.increment();
        uint256 tokenId = _tokenIdCounter.current();
        if(tokenId > hardCap) {
            revert maxSupplyReached();
        }
        _safeMint(to, tokenId);
        string memory uri = string.concat(
            Strings.toString(tokenId),
            ".json"
        );
        _setTokenURI(tokenId, uri);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize) internal override(ERC721, ERC721Enumerable, ERC721Pausable)
    {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
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

}