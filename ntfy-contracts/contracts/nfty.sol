pragma solidity 0.6.2;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

//@dev contract definition
contract NFTY is ERC721 {
  using Counters for Counters.Counter;
  Counters.Counter private tokenIds;
  constructor(string memory name, string memory symbol)
    public
    ERC721(name, symbol)
  {}

  function mintToken(address tokenOwner, string memory tokenURI)
    public
    returns (uint256)
  {
    tokenIds.increment();
    _mint(tokenOwner, tokenIds.current());
    _setTokenURI(tokenIds.current(), tokenURI);
    return tokenIds.current();
  }
}
