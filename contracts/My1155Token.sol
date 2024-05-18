// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

// import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract My1155Token is ERC1155Supply, Ownable {

    uint256 public constant Soul = 1;
    uint256 public constant Life = 2;
    uint256 public constant Problem = 3;
    uint256 public constant Woman = 4;
    uint256 public constant Venus = 5;
    uint256 public constant Blood = 6;
    uint256 public constant Brisingr = 7;
    uint256 public constant Smile = 8;
    uint256 public constant Shadows = 9;
    uint256 public constant Far = 10;


    mapping (uint256 => string) private _uris;

    constructor() ERC1155("https://peach-managing-marmot-708.mypinata.cloud/ipfs/QmUUS9a8V4g4rkX5Xo8AoEPuUP4posYKcrsbkGYU7UDLvM/{id}.json") {
        mint(msg.sender, Soul, 10, "");
        mint(msg.sender, Life, 20, "");
        mint(msg.sender, Problem, 30, "");
        mint(msg.sender, Woman, 5, "");
        mint(msg.sender, Venus, 50, "");
        mint(msg.sender, Blood, 50, "");
        mint(msg.sender, Brisingr, 50, "");
        mint(msg.sender, Smile, 50, "");
        mint(msg.sender, Shadows, 50, "");
        mint(msg.sender, Far, 50, "");
    }

    function mint(address account, uint256 id, uint256 amount, bytes memory data) public onlyOwner {
        _mint(account, id, amount, data);
    }
    
    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) public onlyOwner {
    _mintBatch(to, ids, amounts, data);
    }

    function uri(uint256 tokenId) override public view returns (string memory) {
    return (_uris[tokenId]);
    }

    function setTokenUri(uint256 tokenId, string memory tokenUri) public onlyOwner {
        require(bytes(tokenUri).length > 0, "Cannot set uri twice");
        _uris[tokenId] = tokenUri;
    }
}