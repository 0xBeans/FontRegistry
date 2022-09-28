# On-chain Font Registry

## Why a font registry?

Any project that has on-chain SVGs cannot embed custom fonts by querying a font provider (like Google Fonts). The font data has to live on-chain or the SVG does not properly render.

Teams have spent countless hours and thousands of dollars individually uploading custom fonts as it's not a trivial thing to do. As on-chain SVGs become more promiment, more and more teams will be uploading fonts.

This font registry provides a hub of all on-chain fonts that any team can use in a simplye way and prevent double uploading of fonts. 

**We're currently looking for public good grants to reward font uploaders as this registry will be 100% a public good for teams.**

## Overview

[FontRegistry.sol](/src/FontRegistry.sol) is the central registry where projects can query for desired fonts. It is just a mapping of font name to the contract address where the font is stored. Initiailly we will only be accepting public licensed fonts to the registry, I don't want to deal with IP and shit at this moment.

[IFont.sol](/src/interfaces/IFont.sol) is the interface that __MUST__ be implemented if the font contract wants to be included in the registry. All font contracts __MUST__ be immutable after the font is uploaded to the font contract to be included to the registry - this is necessary so font data doesn't get arbitrarily updated once projects start using it.

Please leave any feedback as an issue or DMing me.

<br />

## Font Registry Contract

`FontRegistry.sol` has 3 primary functions `addFontToRegistry()` , `deleteFontFromRegistry()` , and `getFont()`. Both `addFontToRegistry` and `deleteFontFromRegistry` are admin gated to prevent arbitrary contracts (potentially malicious) getting added to this registry. The admins can be the maintainers of the registry, a DAO, or another entity.

Admins must verify font contracts implement the `IFont.sol` interface and that the data is immutable before adding the font contract to the registry.

`getFont()` is the generic function that projects will use to query for any font that the registry contains.

<br />

## IFont interface and criteria for font contracts

It is open ended and up to the dev on how they want to actually upload the font data (either SSTORE2 or hardcoded string or etc) - we leave this flexible as devs have different preferences and one way might be better than the other for different font sizes.

However, all font contracts must implement `IFont.sol` so that the registry knows how to properly query your font data and that all fonts in the registry conform to a standard.

The __ONLY__ other criteria that a font contract needs is that the font data returned  __MUST__ be immutable. We must prevent font contracts from getting arbitrarily updated as it might break projects actually using the font or devs may try to return malicious bytes.

One way to make it immutable is having the functions that upload/change font data to be `Ownable`. Once you have uploaded your font and tested it works, simply `renounceOwnership` and now the contract can never change the font data.

Another way is to have a flag like `fontIsFinalized` that once is set to `true`, can never be set to `false` and prevents all data from being mutated in the contract.

Completely up to you.

<br />

## Example font + getting added to registry

Let's take a look at an [example](/src/examples/).

1. We first take the font was want to upload (in our case its a ttf font) and base64 encoded it. Fonts can be any format (ttf, woff, otf, etc).
   
2. We then prefix our base64 encoded font (saved as a txt file in our case) with the correct [data uri scheme](https://en.wikipedia.org/wiki/Data_URI_scheme). Since our font is `base64` encoded, a `ttf` font, and we want `utf-8`, our prefix looks like `data:font/ttf;charset=utf-8;base64,`. Take a look at [our example font](/src/examples/example-font.txt) and you can see the prefix we added.

3. We then create our font contract that we will upload our font to. We implement `IFont.sol` with the correct values.

4. We create a script to locally test font uploading and renouncing ownership (how we make our fonts immutable in this example) work properly.

5. Lastly, we deploy our font contract to mainnet and upload the font by running our same script. **Verify** your contract on etherscan.

6. Submit an issue on this repo with a link to your font address. Maintainers will review it and if it conforms to the standard, we will add it to the registry and the website where it will be searchable and queryable by anyone.

<br />

## Usage

A project using the registry simply needs to query a font like so:

```
contract ProjectA {
    address public fontRegistry = <FONT_REGISTRY_CONTRACT>

    function constructSVG() external returns (string memory) {
        return string(
            abi.encodePacked(
                "<svg xmlns='http://www.w3.org/2000/svg' width='256' height='256'>"
   				    ... more svg styling shit here ...
                   "<style type='text/css'>"
                   "@font-face {"
                   "font-family: 'TimesNewRoman';"
                   "font-style: normal;"
                   "src:url(",
                   FontRegistry.getFont('TimesNewRoman'), // easily embedding font
                   ");}"
                   ".title {"
                   "font-family: 'TimesNewRoman';"
                   "letter-spacing: 0.025em;"
                   "font-size: 23px;"
                   "fill: white;"
                   "}"
                   "</style>"
                "</svg>"
            )
        );
    }
}
```

<br />

## Design Choices (feel free to submit feedback)

`FontRegistry` is non-upgradeable as it adds gas overhead for each query. Since projects using fonts will most likely be rendering SVGs on-chain, gas usage will be incredibly high. It is quite possible these SVG rendering contracts will be close to the gas limit for a block and we don't want to add overhead to that.


We leave it up to the font uploader to upload the font as long as the implement `IFont` and make the data immutable. Uploading font is open ended as devs have different prefences and we want to leverage fonts that have already been uploaded on-chain (create a contract that just points to the existing contracts. We need the data to be immutable so there are no breaking changes or malicious bytes uploaded in the future as projects start using the font.