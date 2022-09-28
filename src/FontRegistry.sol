// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {IFont} from "./interfaces/IFont.sol";
import {OwnableRoles} from "solady/auth/OwnableRoles.sol";

/// @title A registry of fonts that are uploaded on-chain and can be easily embedded in projects.
///
/// This registry is quite basic. It simply routes a request for a font to the correct contract
/// address where the font is living and returns the base64 encoded font string.
/// ie getFont('TimesNewRoman') will return a base64 encoded font as a string if it exists in this registry.
///
/// We allow anyone to upload fonts to chain however this wish (as people may have different preferences)
/// but they MUST implement the IFont interface and cohere to this standard if they wish to be added to this
/// registry.
///
/// We can't prevent anyone from uploading anything on-chain which is why we leave the actual logic open ended
/// to the person uploading. The reason you want to implement the IFont interface and be added to the registry
/// is to be easily searched by others as it will show up on the Font Registry website. Additionally, this
/// font registry will ideally be the hub of all on-chain fonts so that all projects are on the same standard.
///
/// After uploading a font on-chain that implements IFont, please submit a request to add it to the registry
/// where the maintainers of this registry will verify the font is proper and non malicious before adding it
/// to the registry. All credits will be given to the font uploaders.
///
/// @author @0x_beans
contract FontRegistry is OwnableRoles {
    // keccak256(fontName) => address of base64 encoded font
    mapping(bytes32 => address) public fonts;

    constructor() {
        _initializeOwner(msg.sender);
    }

    /// @dev only owners (maintainers) of the registry can add fonts after properly verifying the font
    /// @param fontAddress address of the IFont contract
    function addFontToRegistry(address fontAddress) external onlyOwner {
        fonts[
            keccak256(abi.encodePacked(IFont(fontAddress).fontName()))
        ] = fontAddress;
    }

    /// @dev only owners (maintainers) of the registry can delete fonts from the registry
    /// @param fontAddress address of the IFont contract
    function deleteFontFromRegistry(address fontAddress) external onlyOwner {
        delete fonts[
            keccak256(abi.encodePacked(IFont(fontAddress).fontName()))
        ];
    }

    /// @dev query existing fonts in the registry (searchable on the website)
    /// @param fontName font name as found on the website
    /// @dev returns base64 encoded string of the font
    function getFont(string calldata fontName)
        external
        view
        returns (string memory)
    {
        return IFont(fonts[keccak256(abi.encodePacked(fontName))]).getFont();
    }
}
