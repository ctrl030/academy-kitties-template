pragma solidity 0.5.12;

// preparing for some functions to be restricted   - not used?
import "./Ownable.sol";

// using safemath to rule out over- and underflow and such  - seems done
import "./Safemath.sol";

// importing ERC721 token standard interface, all functions need to be fully created  - implement
import "./IERC721.sol";

contract Monkeycontract is IERC721 {

  // using safemath, now should use uint256 for all numbers  - seems done
  using SafeMath for uint256; 


  // State variables

  // 1 name to store - will be queried by name function  - seems done
  string private _name;

  // 1 symbol to store - will be queried by symbol function - seems done
  string private _symbol;

  // storing the totalSupply - will be queried by totalSupply function - needs to be updated via a real mint function later (connect to Monkey Factory) - done for now
  uint256 private _totalSupply;

  // a mapping to store each address's number of Crypto Monkeys - will be queried by balanceOf function - must update at minting (seems done) and transfer (seems done)
  mapping(address => uint256) private _numberOfCMOsOfAddressMapping;
 
  // mapping of all the tokenIDs and their ownerssss - will be queried by ownerOf function - seems done
  mapping (uint256 => address) private _monkeyIdsAndTheirOwnersMapping;

 

  // Events

  // Transfer event, emit after successful transfer with these parameters  - seems done - why indexed? what does it mean, do I need that?
  event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

  // Approval event, emit after successful approval with these parameters  - implement "you can transfer my CMO - functionality"
  // event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

  // Minted event, emit after successful minting with these parameters  -  seems done
  event Minted (address owner, uint256 tokenId);



  // Constructor function, is setting _name, _symbol and _totalSupply  - seems done

  constructor () public {
    _name = "Crypto Monkeys";
    _symbol = "CMO";
    _totalSupply = 0;    
  } 


  // Functions

  
  // Returns the name of the token. - seems done
  function name() external view returns (string memory tokenName){
    return _name;
  };

  
  // Returns the symbol of the token. - seems done  
  function symbol() external view returns (string memory tokenSymbol){
    return _symbol;
  };

  // query the totalSupply - seems done
  function totalSupply() external view returns (uint256 total){
    return _totalSupply;
  };

  // Returns the number of tokens in ``owner``'s account. - seems done
  function balanceOf(address owner) external view returns (uint256 balance){
    return _numberOfCMOsOfAddressMapping[owner];
  };
  
  // returns the owner of given tokenId, which is stored in the _monkeyIdsAndTheirOwnersMapping at the [tokenId] position - seems done
  function ownerOf(uint256 tokenId) external view returns (address owner){    
    return _monkeyIdsAndTheirOwnersMapping[tokenId];
  };

  /*  need mint function.. needs to generate new ERC721, i.e.  - how can I store the ETH amount that was paid in the event I emit? what data type is ether?
  generate tokenId, - seems done
  store it and assign it to the owner in a mapping  - seems done
  make transferable  - seems done, just change owner via transfer function in the _monkeyIdsAndTheirOwnersMapping
  emit Minted - seems done
 */
  function mint () public payable {
    // requires payment of 0.1 ether to use this function
    require(msg.value >= 0.1 ether);

    // declaring tokenId variable, the variable has only the scope of this function and will dissolve after running it, but...
    uint256 tokenId;

    // ... we set the tokenId for this token that is being minted to the amount of the _totalSupply (first CMO will have tokenId = 0, and so on) and then..
    tokenId = _totalSupply;

    // ... save this tokenId to te _monkeyIdsAndTheirOwnersMapping where we keep all of the tokenIds, 
    // and assign and owner to them, which at the moment of minting is the msg.sender
    _monkeyIdsAndTheirOwnersMapping[tokenId] = msg.sender;

    // then we add 1 to the _numberOfCMOsOfAddressMapping, where we store all the addresses that own Crypto Monkeys and the amount of them
    _numberOfCMOsOfAddressMapping[msg.sender].add(1);

    // we update the _totalSupply (as we use this variable to generate the tokenIds, this will never go down, because that would create double ids, etc. 
    // So if we want a burning function, just transfer to a burn address, will still count towards totalSupply.  
    // We could also create another uint256 that keeps track of how many  CMOs are in that burn address, 
    // and then substract that number from totalSupply, so that we know how many are in circulation, unburned. Or similar.)
    _totalSupply.length = _totalSupply.add(1);

    // emitting the Minted event, logging the minting address (msg.sender) and the tokenId of the CMO that was minted
    emit Minted (msg.sender, tokenId)
  }

  /* @dev Transfers `tokenId` token from `msg.sender` to `to`.
  *
  * Requirements:
  *
  * - `to` cannot be the zero address. - seems done
  * - `to` can not be the contract address. - How do I find contract address? Where do we store it?
  * - `tokenId` token must be owned by `msg.sender`. - seems done
  *
  * Emits a {Transfer} event.
  */

  function transfer(address to, uint256 tokenId) public {

    //`to` cannot be the zero address. 
    require (to != address(0));

    // FIX, need contract address / where to find it after generated
    // require (to != );

    // `tokenId` token must be owned by `msg.sender`
    require (_monkeyIdsAndTheirOwnersMapping[tokenId] == msg.sender);

    // transferring, i.e. changing ownership entry in the _monkeyIdsAndTheirOwnersMapping for the tokenId
    _monkeyIdsAndTheirOwnersMapping[tokenId] = to;

    // updating "balance" of address in _numberOfCMOsOfAddressMapping, 'to' address has 1 CMO more
    _numberOfCMOsOfAddressMapping[to].add(1);

    // updating "balance" of address in _numberOfCMOsOfAddressMapping, sender has 1 CMO less
    _numberOfCMOsOfAddressMapping[msg.sender].sub(1);

    emit Transfer (msg.sender, to, tokenId)

  } 
    




}