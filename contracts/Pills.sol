//SPDX-License-Identifier: MIT
// @title    Cheap Pills
// @version  1.2.0
// @author   lahey08
// @custom:code from Radek Sienkiewicz

pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract Pills is ERC721 {
    address owner;
    // Structs
    // Constants, public variables
    uint constant maxSupply = 50; // max number of tokens
    uint public totalSupply = 0; // number of tokens minted
    uint public mintPrice = 0.0005 ether;

    // Mapping to store SVG code for each token
    mapping(uint => string) private tokenIdToSvg;

    // Events

    constructor() ERC721("Onchain Pills", "OCP") {
        owner = msg.sender;
    }

    // Importing SafeMath library to safely perform arithmetic operations
    using SafeMath for uint256;

    // Array of predefined colors
    string[2][4] colorPairs = [
        ["#1AAACF", "#1B72CF"],
        ["#FF2135", "#FF4321"],
        ["#FFE400", "#FFA800"],
        ["#12E895", "#23E813"]
    ];
    string[4] backgroundColors = ["#995157", "#375F69", "#99903D", "#364F45"];

    function generateRandomNumbers(uint256 _tokenId) internal view returns (uint256[5] memory) {
        uint256[5] memory randomNumbers;
        uint256 randomNumber;
        for (uint256 i = 0; i < 5; i++) {
            randomNumber = uint256(
                keccak256(abi.encodePacked(block.timestamp, msg.sender, _tokenId, i))
            );
            randomNumbers[i] = i < 3 ? (randomNumber % 4) : (randomNumber % 2);
        }

        return randomNumbers;
    }

    // Function to get a predefined color based on the seed
    function getPredefinedColor(uint256 _tokenId) internal view returns (string[5] memory) {
        uint256[5] memory randomNumbers = generateRandomNumbers(_tokenId);
        uint256 index0 = randomNumbers[0];
        uint256 index1 = randomNumbers[1];
        uint256 index2 = randomNumbers[2];
        uint256 index3 = randomNumbers[3];
        uint256 index4 = randomNumbers[4];

        string[2] memory colorPair1 = colorPairs[index0];
        string[2] memory colorPair2 = colorPairs[index1];

        string memory color1 = (index3 == 1) ? colorPair1[1] : colorPair1[0];
        string memory color2 = (index3 == 1) ? colorPair1[0] : colorPair1[1];
        string memory color3 = (index4 == 1) ? colorPair2[1] : colorPair2[0];
        string memory color4 = (index4 == 1) ? colorPair2[0] : colorPair2[1];
        string memory color5 = backgroundColors[index2];

        return [color1, color2, color3, color4, color5];
    }

    // Function to generate the final SVG with random colors
    function generateFinalSvg(uint256 _tokenId) public view returns (string memory) {
        // Generate random colors
        string[5] memory colors = getPredefinedColor(_tokenId);

        string memory finalPill = string.concat(
            '<?xml version="1.0" encoding="UTF-8"?><svg width="720" height="720" version="1.1" viewBox="0 0 360 360" xmlns="http://www.w3.org/2000/svg"><g><rect width="100%" height="100%" fill="',
            colors[4],
            '"/><circle cx="172.5" cy="97.5" r="52.5" fill="',
            colors[0],
            '"/><circle cx="172.5" cy="262.5" r="52.5" fill="',
            colors[2],
            '"/><rect x="120" y="97.5" width="105" height="82.5" fill="',
            colors[0],
            '"/><rect x="120" y="180" width="105" height="82.5" fill="',
            colors[2],
            '"/><circle cx="168.75" cy="93.75" r="48.75" fill="',
            colors[1],
            '"/><circle cx="168.75" cy="266.25" r="48.75" fill="',
            colors[3],
            '"/><rect x="120" y="97.5" width="97.5" height="82.5" fill="',
            colors[1],
            '"/><rect x="120" y="180" width="97.5" height="82.5" fill="',
            colors[3],
            '"/></g></svg>'
        );

        return finalPill;
    }

    // Mint new Pills
    function mintPill() public payable {
        // Make sure the amount of ETH is equal or larger than the minimum mint price
        require(msg.value >= mintPrice, "Not enough ETH sent");

        // Increment tokenId
        uint tokenId = totalSupply + 1;
        require(tokenId > 0 && tokenId <= maxSupply, "Token ID invalid");

        tokenIdToSvg[tokenId] = generateFinalSvg(tokenId);

        // Mint token
        _mint(msg.sender, tokenId);

        // Increase minted tokens counter
        ++totalSupply;

    }
    function mintBatch(uint256 numberOfTokens) public payable {
        // Make sure the amount of ETH is equal or larger than the minimum mint price multiplied by the number of tokens
        require(msg.value >= mintPrice * numberOfTokens, "Not enough ETH sent");
        require(totalSupply + numberOfTokens <= maxSupply, "exceeding max total supply");

        // Loop to mint the requested number of tokens
        for (uint256 i = 0; i < numberOfTokens; i++) {
            // Increment tokenId
            uint256 tokenId = totalSupply + 1;

            // Generate and store the SVG for the token
            tokenIdToSvg[tokenId] = generateFinalSvg(tokenId);

            // Mint the token
            _mint(msg.sender, tokenId);

            // Increase minted tokens counter
            ++totalSupply;

        }
    }
    // Generate token URI with all the SVG code, to be stored on-chain
    function tokenURI(
        uint tokenId
    ) public view override returns (string memory) {
        require(_ownerOf(tokenId) != address(0));

        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name": "Pills #',
                                uint2str(tokenId),
                                '", "description": "Cheap Pills", "attributes": "", "image":"data:image/svg+xml;base64,',
                                Base64.encode(bytes(tokenIdToSvg[tokenId])),
                                '"}'
                            )
                        )
                    )
                )
            );
    }

    // Withdraw funds from the contract
    function withdraw() public {
        require(msg.sender == owner, "only owner");
        uint balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }

    // From: https://stackoverflow.com/a/65707309/11969592
    function uint2str(
        uint _i
    ) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len;
        while (_i != 0) {
            k = k - 1;
            uint8 temp = (48 + uint8(_i - (_i / 10) * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }
}

// SafeMath library to prevent overflow and underflow in arithmetic operations
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
}
