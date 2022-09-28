// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IFont {
    // address that uploaded font for credits
    function fontUploader() external returns (address);

    // ttf, woff, otf, etc.
    // this info is necessary so projects know how to properly render the fonts
    function fontFormatType() external returns (string memory);

    // font name, ie 'space-grotesk'
    function fontName() external returns (string memory);

    // bold, medium, light, etc
    // necessary to differentiate uploaded fonts that are the same but different weights
    function fontWeight() external returns (string memory);

    // normal, italic, oblique, etc
    // necessary to differentiate uploaded fonts that are the same but different style
    function fontStyle() external returns (string memory);

    // return the full base64 encoded font with `data:font/ttf;charset=utf-8;base64,` prefix
    function getFont() external view returns (string memory);
}
