//SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {IFont} from "../interfaces/IFont.sol";
import {OwnableRoles} from "solady/auth/OwnableRoles.sol";
import {SSTORE2} from "solady/utils/SSTORE2.sol";

/// @title Example of uploading a font on-chain
/// @author @0x_beans
contract ExampleFont is OwnableRoles, IFont {
    /*==============================================================
    ==                     Custom Font Variables                  ==
    ==============================================================*/

    // our font is 115KB
    // contract storage is < 24KB
    // we need to chunk our font into 5 partitions to store it fully
    uint256 public constant FONT_PARTITION_1 = 0;
    uint256 public constant FONT_PARTITION_2 = 1;
    uint256 public constant FONT_PARTITION_3 = 2;
    uint256 public constant FONT_PARTITION_4 = 3;
    uint256 public constant FONT_PARTITION_5 = 4;

    // addresses where font chunks are stored
    mapping(uint256 => address) public files;

    /*==============================================================
    ==                         IFont Info                         ==
    ==============================================================*/

    // credit to the person that uploaded the font
    address public fontUploader = msg.sender;

    // Note: below doesn't follow the convenction of ALL CAPS for constants
    // if you want to follow convention, just write explicit functions for the interface

    // font name in all lower-cases, ie 'space-grotesk'
    string public constant fontName = "example-font";

    // can be ttf, woff, otf, etc.
    string public constant fontFormatType = "ttf";

    // can be bold, italic, medium, light, etc
    // any standard descriptor of the font weight
    string public constant fontWeight = "bold";

    // can be normal, italic, oblique, etc
    // any standard descriptor of the font style
    string public constant fontStyle = "normal";

    /*==============================================================
    ==                      Custom Font Logic                     ==
    ==============================================================*/

    // function the script calls to uplod the different partitions to contract storage
    // check exampleFontUpload.js to see how we upload fonts
    function saveFile(uint256 index, string calldata fileContent)
        external
        onlyOwner
    {
        files[index] = SSTORE2.write(bytes(fileContent));
    }

    // IMPORTANT: MUST RENOUNCE OWNERSHIP SO FONT DATA IS COMPLETELY IMMUTABLE
    function finalizeFont() external onlyOwner {
        renounceOwnership();
    }

    /*==============================================================
    ==                     IFont Implementation                   ==
    ==============================================================*/

    // reconstruct full font and return it
    function getFont() external view returns (string memory) {
        return
            string(
                abi.encodePacked(
                    SSTORE2.read(files[0]),
                    SSTORE2.read(files[1]),
                    SSTORE2.read(files[2]),
                    SSTORE2.read(files[3]),
                    SSTORE2.read(files[4])
                )
            );
    }
}
