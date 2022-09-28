// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/// @title The interface on-chain font contracts must implement to be added to the registry.
///
/// Uploading fonts to chain is open ended and up to the dev (SSTORE2 or hardcoded string or etc).
///
/// As long as the font contract implements this interface and has immutable font data, it can be added
/// to the registry.
///
/// @author @0x_beans
interface IFont {
    // address that uploaded font for credits
    function fontUploader() external returns (address);

    // lowercase ttf, woff, otf, etc.
    // this info is necessary so projects know how to properly render the fonts
    function fontFormatType() external returns (string memory);

    // lowercase font name, ie 'space-grotesk'
    function fontName() external returns (string memory);

    // lowercase bold, medium, light, etc
    // necessary to differentiate uploaded fonts that are the same but different weights
    function fontWeight() external returns (string memory);

    // lowercase normal, italic, oblique, etc
    // necessary to differentiate uploaded fonts that are the same but different style
    function fontStyle() external returns (string memory);

    // return the full base64 encoded font with data uri scheme prefix (`data:font/ttf;charset=utf-8;base64,`)
    function getFont() external view returns (string memory);
}
