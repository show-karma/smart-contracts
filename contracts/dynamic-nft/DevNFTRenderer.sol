//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "base64-sol/base64.sol";
import "./DevSchemaResolver.sol";
import "./GithubLinkResolver.sol";
import "./NFTRenderer.sol";
import "@openzeppelin/contracts/utils/Strings.sol";


contract DevNFTRenderer is NFTRenderer {
  uint256 public nftCounter;
  DevSchemaResolver public schemaResolver;
  GithubLinkResolver public githubResolver;
  address public _owner;

  constructor (address payable _schemaResolver, address payable _githubResolver) {
    nftCounter = 0;
    schemaResolver = DevSchemaResolver(_schemaResolver);
    githubResolver = GithubLinkResolver(_githubResolver);
    _owner = msg.sender;
  }
  
  function formatTokenURI(address tokenOwner, string memory repository) public view returns (string memory) {
     (,  DevSchemaResolver.AttestationData[] memory attestations) = getAttestationCountAndData(tokenOwner, repository);
      string memory svgImageURI = imageURI(tokenOwner, repository);
      string memory attributesJson = getAttributes(attestations); 

      string memory json = string(
        abi.encodePacked(
          '{"name":"SVG NFT", "description":"Karma Reputation NFT!", "attributes":', attributesJson ,' , "image":"',
          svgImageURI,
          '"}'
        )
      );

      string memory base64EncodedJson = Base64.encode(bytes(json));
      return string(abi.encodePacked("data:application/json;base64,", base64EncodedJson));
  }

  function getAttributes(DevSchemaResolver.AttestationData[] memory attestations) private pure returns (string memory) {
    string memory attributesJson = '['; 
      for (uint256 i = 0; i < attestations.length; i++) {
        string memory uidString = string(abi.encodePacked(attestations[i].uid));

        string memory attestationJson = string(
          abi.encodePacked(
              '{"attestation_uid":"', uidString, '","pr_link":"', attestations[i].prUrl, '" }'
          )
        );

        if (i < attestations.length - 1) {
          attestationJson = string(abi.encodePacked(attestationJson, ','));
        }

        attributesJson = string(abi.encodePacked(attributesJson, attestationJson));
      }

    attributesJson = string(abi.encodePacked(attributesJson, ']'));
    return attributesJson;
  }

  function getWalletInformation(address receiver) private view returns (string memory){
    return githubResolver.getUsernameOfAddress(receiver);
  }

  function getAttestationCountAndData(address tokenOwner, string memory repository) private view returns (uint256, DevSchemaResolver.AttestationData[] memory) {
    string memory githubUsername = getWalletInformation(tokenOwner);
    DevSchemaResolver.AttestationData[] memory attestations = schemaResolver.getUserAttestation(repository, githubUsername);
    return (attestations.length, attestations);
  }

  function imageURI(address tokenOwner, string memory repository) public view returns(string memory) {
    string memory username = getWalletInformation(tokenOwner);
    (uint256 prCount,) = getAttestationCountAndData(tokenOwner, repository);
    
    string memory background = generateBackground(prCount);
    string memory avatar = generateAvatar(prCount);
    string memory avatarChain = generateAvatarChain(prCount);
    string memory card = generateCard(username, prCount, repository);

    string memory completeSVG = string(abi.encodePacked(
      'data:image/svg+xml;utf8, <svg width="1000" height="1000" viewBox="0 0 1000 1000" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">',
      background,
      card,
      avatarChain,
      avatar,
      '</svg>'
    ));
    return completeSVG;
  }

  function getColor(string memory colorType, uint256 position) private pure returns (string memory color) {
      string memory colorAux;
      bytes32 colorTypeHash = keccak256(bytes(colorType));
      uint256 preventPosition = position < 1 ? 1 : position;
      string memory convertedPosition = Strings.toString((preventPosition * 50)); // Use Strings.toString() for integer to string conversion

      if (colorTypeHash == keccak256("green")) {
          colorAux = string(abi.encodePacked("0,", convertedPosition, ",0"));
      } else if (colorTypeHash == keccak256("yellow")) {
          colorAux = string(abi.encodePacked("241,255,", convertedPosition));
      } else if (colorTypeHash == keccak256("white")) {
          colorAux = string(abi.encodePacked("255,255,", convertedPosition));
      } else if (colorTypeHash == keccak256("blue")) {
          colorAux = string(abi.encodePacked("0,0,", convertedPosition));
      }

      color = string(abi.encodePacked("rgb(", colorAux, ")"));
  }

  function getPosition(uint256 score, uint256 interval) private pure  returns (uint256 position) {
    if (score < interval) {
      position = 0;
    } else if(score > interval && score < interval * 2) {
      position = 1;
    } else if(score > interval * 2 && score < interval + 3) {
      position = 2;
    } else {
      position = 3;
    }
  }

 
  function generateBackground(uint256 prCount) public pure returns (string memory svg) {
    string memory color = getColor("green", getPosition(prCount , 5));
     svg = string(
      abi.encodePacked('<rect width="1000" height="1000" fill="', color, '" />'));    
  }

  function generateCard(
    string memory username,
    uint256 prCount,
    string memory repository
  ) public pure returns (string memory svg) {
  string memory convertedPrCount = Strings.toString(prCount * 1);
  
  svg = string(
    abi.encodePacked(
      '<rect x="42" y="728" width="932" height="246" rx="24" fill="rgb(38,26,59)"/>',
      '<text fill="white" font-family="Fira Code" font-size="32" x="253" y="776">',
      '<tspan dx="60" dy="15">Contributor:</tspan><tspan dx="20" fill="rgb(246,112,199)">', username ,'</tspan>',
      '<tspan x="255" dy="45">Total no. of PRs:</tspan> <tspan dx="20" fill="rgb(153,246,224)">', convertedPrCount ,'</tspan>',
      '<tspan x="325" dy="45">Repository:</tspan><tspan dx="20" fill="rgb(221,214,254)">', repository ,'</tspan>', 
      '</text>'
      )
    );
  } 

  function generateAvatar(uint256 prCount) public pure returns (string memory svg) {
    string memory bearColor = getColor("white", getPosition(prCount , 3));
    string memory bearBorder = getColor("blue", getPosition(prCount , 2));

    svg = string(
      abi.encodePacked(
        '<path d="m201.25 524.9v-241.07h17.735v-122.83h31.53v-37.442h68.315v31.53h31.529v40.726h206.92v-18.393h11.166v-30.216h109.04v30.216h34.814v63.06h-34.814v31.53h34.814v247.64h-53.206v32.844h-30.873v42.696h-346.17v-35.471h-31.53v-34.814h-49.265z" fill="', bearColor , '"/>',
        '<rect x="318.82" y="375.79" width="236.47" height="69.628" fill="rgb(234, 236, 245)"/>',
        '<rect x="352.98" y="409.95" width="170.79" height="69.628" fill="rgb(234, 236, 245)"/>',
        '<rect x="387.14" y="442.8" width="102.47" height="69.628" fill="rgb(234, 236, 245)"/>',
        '<rect x="218.98" y="240.48" width="31.481" height="31.481" fill="', bearBorder , '"/>',
        '<rect x="218.98" y="147.2" width="31.481" height="31.481" fill="', bearBorder , '"/>',
        '<rect x="318.83" y="147.2" width="31.481" height="31.481" fill="', bearBorder , '"/>',
        '<rect x="187.45" y="177.42" width="31.53" height="63.06" fill="', bearBorder , '"/>',
        '<rect x="287.3" y="177.42" width="31.53" height="63.06" fill="', bearBorder , '"/>',
        '<rect x="250.51" y="208.95" width="68.315" height="31.53" fill="', bearBorder , '"/>',
        '<rect x="387.14" y="411.26" width="68.315" height="31.53" fill="', bearBorder , '"/>',
        '<rect x="421.3" y="411.26" width="68.315" height="31.53" fill="', bearBorder , '"/>',
        '<rect transform="rotate(-90 318.83 411.26)" x="318.83" y="411.26" width="68.315" height="31.53" fill="', bearBorder , '"/>',
        '<rect transform="rotate(-90 523.77 411.26)" x="523.77" y="411.26" width="68.315" height="31.53" fill="', bearBorder , '"/>',
        '<rect transform="rotate(-90 422.61 479.58)" x="422.61" y="479.58" width="68.315" height="31.53" fill="', bearBorder , '"/>',
        '<rect x="350.36" y="177.42" width="210.2" height="31.53" fill="', bearBorder , '"/>',
        '<rect x="280.73" y="571.54" width="214.14" height="31.53" fill="', bearBorder , '"/>',
        '<rect x="250.51" y="115.67" width="68.315" height="31.53" fill="', bearBorder , '"/>',
        '<rect x="218.98" y="508.48" width="31.481" height="31.481" fill="', bearBorder , '"/>',
        '<rect x="250.51" y="540.01" width="31.481" height="31.481" fill="', bearBorder , '"/>',
        '<rect x="187.45" y="272.01" width="31.53" height="268" fill="', bearBorder , '"/>',
        '<rect transform="matrix(-1 0 0 1 690.61 240.48)" width="31.481" height="31.481" fill="', bearBorder , '"/>',
        '<rect transform="matrix(-1 0 0 1 690.61 147.2)" width="31.481" height="31.481" fill="', bearBorder , '"/>',
        '<rect transform="matrix(-1 0 0 1 590.77 147.2)" width="31.481" height="31.481" fill="', bearBorder , '"/>',
        '<rect transform="matrix(-1 0 0 1 722.14 177.42)" width="31.53" height="63.06" fill="', bearBorder , '"/>',
        '<rect transform="matrix(-1 0 0 1 622.3 177.42)" width="31.53" height="63.06" fill="', bearBorder , '"/>',
        '<rect transform="matrix(-1 0 0 1 659.08 208.95)" width="68.315" height="31.53" fill="', bearBorder , '"/>',
        '<rect transform="matrix(-1 0 0 1 559.24 177.42)" width="210.2" height="31.53" fill="', bearBorder , '"/>',
        '<rect transform="matrix(-1 0 0 1 628.87 571.54)" width="214.14" height="31.53" fill="', bearBorder , '"/>',
        '<rect transform="matrix(-1 0 0 1 659.08 115.67)" width="68.315" height="31.53" fill="', bearBorder , '"/>',
        '<rect transform="matrix(-1 0 0 1 690.61 508.48)" width="31.481" height="31.481" fill="', bearBorder , '"/>',
        '<rect transform="matrix(-1 0 0 1 659.08 540.01)" width="31.481" height="31.481" fill="', bearBorder , '"/>',
        '<rect transform="matrix(-1 0 0 1 722.14 272.01)" width="31.53" height="268" fill="', bearBorder , '"/>',
        '<rect x="250.51" y="240.48" width="68.315" height="31.53" fill="rgb(213, 217, 235)"/>',
        '<rect x="250.51" y="508.48" width="31.481" height="31.481" fill="rgb(213, 217, 235)"/>',
        '<rect x="218.98" y="208.95" width="31.481" height="31.481" fill="rgb(213, 217, 235)"/>',
        '<rect x="282.04" y="540.01" width="345.51" height="31.53" fill="rgb(213, 217, 235)"/>',
        '<rect transform="matrix(1 0 0 -1 627.56 303.54)" width="31.53" height="63.06" fill="rgb(213, 217, 235)"/>',
        '<rect transform="matrix(1 0 0 -1 659.08 240.48)" width="31.53" height="63.06" fill="rgb(213, 217, 235)"/>',
        '<rect transform="matrix(1 0 0 -1 590.77 272.01)" width="68.315" height="31.53" fill="rgb(213, 217, 235)"/>',
        '<rect transform="matrix(-1 0 0 1 659.04 508.48)" width="31.481" height="31.481" fill="rgb(213, 217, 235)"/>',
        '<rect transform="matrix(-1 0 0 1 690.61 272.01)" width="31.53" height="236.47" fill="rgb(213, 217, 235)"/>'
      )
    );
  }

  function generateAvatarChain(uint256 prCount) public pure returns (string memory svg) {
    string memory color = getColor("yellow", getPosition(prCount , 2));
    svg = string(
      abi.encodePacked(
        '<path d="m506.99 603.15h21.775v21.775h-21.774v21.773h-21.775v-21.774h21.774v-21.774zm-104.52 0h-21.774v21.775h21.774v-21.775zm0 21.774h21.774v21.774h-21.774v-21.774z" clip-rule="evenodd" fill="', color, '" fill-rule="evenodd"/>',
        '<rect transform="rotate(-90 422.08 690.24)" x="422.08" y="690.24" width="65.323" height="21.774" fill="', color, '" />',
        '<rect transform="rotate(-90 465.62 690.24)" x="465.62" y="690.24" width="65.323" height="21.774" fill="', color, '" />',
        '<rect x="422.08" y="624.92" width="65.323" height="21.774" fill="', color, '" />',
        '<rect x="422.08" y="668.47" width="65.323" height="21.774" fill="', color, '" />',
        '<rect x="443.85" y="712.02" width="43.548" height="21.774" fill="', color, '" />',
        '<rect x="443.85" y="733.79" width="43.548" height="21.774" fill="', color, '" />',
        '<rect transform="rotate(-90 443.85 755.57)" x="443.85" y="755.57" width="65.323" height="21.774" fill="', color, '" />'
      )
    ); 
  }

} 
