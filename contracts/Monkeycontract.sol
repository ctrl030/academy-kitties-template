pragma solidity 0.5.12;

// preparing for some functions to be restricted   - not used?
import "./Ownable.sol";

// using safemath to rule out over- and underflow and such  - seems done
import "./Safemath.sol";

// importing ERC721 token standard interface, all functions need to be fully created  - seems done?
import "./IERC721.sol";

contract MonkeyContract is IERC721 {

  // using safemath, now should use uint256 for all numbers  - seems done
  using SafeMath for uint256; 


  // State variables

  // 1 name to store - will be queried by name function  - seems done
  string private _name;

  // 1 symbol to store - will be queried by symbol function - seems done
  string private _symbol;

  // storing the totalSupply - will be queried by totalSupply function - needs to be updated via a real mint function later (connect to Monkey Factory) - seems done for now
  uint256 private _totalSupply;

  // a mapping to store each address's number of Crypto Monkeys - will be queried by balanceOf function - must update at minting (seems done) and transfer (seems done)
  mapping(address => uint256) private _numberOfCMOsOfAddressMapping;

  // mapping of all the tokenIds and their ownerssss - will be queried by ownerOf function - seems done
  mapping (uint256 => address) private _monkeyIdsAndTheirOwnersMapping;
  
  // mapping of the allowed addresses for a piece - entry must be deleted when CMO is transfered - seems done
  mapping (uint256 => address) private _CMO2AllowedAddressMapping;


  /* older version, trying it easier now
  // mapping of all the tokenIds and their owners and their allowedAddress;
  mapping (uint256 => mapping (address => address)) private _CMO2owner2allowedAddressMapping;
  
  // mapping, so that each address can have a list of their CMOs and inside that an address, that is allowed to take/move that CMO
  mapping (address => mapping (uint256 => address)) private _address2CMO2allowedAddressMapping;
  */

  


  // Events

  // Transfer event, emit after successful transfer with these parameters  - seems done - why indexed? what does it mean, do I need that?
  event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

  // Approval event, emit after successful approval with these parameters  - implement "you can transfer my CMO - functionality"
  event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

  // Minted event, emit after successful minting with these parameters  -  seems done
  event Minted (address owner, uint256 tokenId);



  // Constructor function, is setting _name, and _symbol and - seems done

  constructor () public {
    _name = "Crypto Monkeys";
    _symbol = "CMO";       
  } 


  // Functions

  // allows another address to take / move your CMO
  function approve(uint256 tokenId, address allowedAddress) public {   

    // requires that the msg.sender is the owner of the CMO to be moved
    require (_monkeyIdsAndTheirOwnersMapping[tokenId] == msg.sender);

    // stores the allowed address into the mapping for it, with the monkey being the key
    _CMO2AllowedAddressMapping[tokenId] = allowedAddress;

    emit Approval(msg.sender, allowedAddress, tokenId); 

    /*  older version, trying it easier
    // mapping the allowedAddress to the CMO (tokenId) to be taken/moved, inside the mapping that maps all CMOs to their owners.
    _address2CMO2allowedAddressMapping[msg.sender][tokenId] = allowedAddress;
    */

  }

  
  // Returns the name of the token. - seems done
  function name() external view returns (string memory){
    return _name;
  }

  
  // Returns the symbol of the token. - seems done  
  function symbol() external view returns (string memory){
    return _symbol;
  }

  // query the totalSupply - seems done
  function totalSupply() external view returns (uint256){
    return _totalSupply;
  }

  // Returns the number of tokens in ``owner``'s account. - seems done
  function balanceOf(address owner) external view returns (uint256){
    return _numberOfCMOsOfAddressMapping[owner];
  }
  
  // returns the owner of given tokenId, which is stored in the _monkeyIdsAndTheirOwnersMapping at the [tokenId] position - seems done
  function ownerOf(uint256 tokenId) external view returns (address){    
    return _monkeyIdsAndTheirOwnersMapping[tokenId];
  }

  /*  need mint function.. needs to generate new ERC721, i.e.  - how can I store the ETH amount that was paid in the event I emit? what data type is ether?
  generate tokenId, - seems done
  store it and assign it to the owner in a mapping  - seems done
  make transferable  - seems done, just change owner via transfer function in the _monkeyIdsAndTheirOwnersMapping
  emit Minted - seems done
 */
  function mint () public {  
    // declaring tokenId variable, the variable has only the scope of this function and will dissolve after running it, but...
    uint256 tokenId;

    // ... we set the tokenId for this token that is being minted to the amount of the _totalSupply (first CMO will have tokenId = 0, and so on) and then..
    tokenId = _totalSupply;

    // ... save this tokenId to te _monkeyIdsAndTheirOwnersMapping where we keep all of the tokenIds, 
    // and assign and owner to them, which at the moment of minting is the msg.sender
    _monkeyIdsAndTheirOwnersMapping[tokenId] = msg.sender;

    // adds 1 to the _numberOfCMOsOfAddressMapping, where we store all the addresses that own Crypto Monkeys and the amount of them
    _numberOfCMOsOfAddressMapping[msg.sender].add(1);

    // we update the _totalSupply (as we use this variable to generate the tokenIds, this will never go down, because that would create double ids, etc. 
    // So if we want a burning function, just transfer to a burn address, will still count towards totalSupply.  
    // We could also create another uint256 that keeps track of how many CMOs are in that burn address, 
    // and then substract that number from totalSupply into another uint256 variable, so that we know how many are in circulation, unburned. Or similar.)
    _totalSupply = _totalSupply.add(1);

    // emitting the Minted event, logging the minting address (msg.sender) and the tokenId of the CMO that was minted
    emit Minted (msg.sender, tokenId);

  }

  /* @dev Transfers `tokenId` token from `msg.sender` to `to`.
  *
  * Requirements:
  *
  * - `to` cannot be the zero address. - seems done
  * - `to` can not be the contract address.  seems done
  * - `tokenId` token must be owned by `msg.sender`. - seems done
  *
  * Emits a {Transfer} event.
  */

  function transfer(address to, uint256 tokenId) public {

    //`to` cannot be the zero address. 
    require (to != address(0));

    // to` can not be the contract address.
    require (to != address(this));

    // `tokenId` token must be owned by `msg.sender`
    require (_monkeyIdsAndTheirOwnersMapping[tokenId] == msg.sender);

    // try {
      // deleting any allowed address for the transfered CMO
      delete _CMO2AllowedAddressMapping[tokenId];

      // transferring, i.e. changing ownership entry in the _monkeyIdsAndTheirOwnersMapping for the tokenId
      _monkeyIdsAndTheirOwnersMapping[tokenId] = to;  

      // updating "balance" of address in _numberOfCMOsOfAddressMapping, 'to' address has 1 CMO more
      _numberOfCMOsOfAddressMapping[to].add(1);

      // updating "balance" of address in _numberOfCMOsOfAddressMapping, sender has 1 CMO less
      _numberOfCMOsOfAddressMapping[msg.sender].sub(1);
    //}
    
    //catch (err) {
    //  console.log("Error is: " + err);
    //}

    emit Transfer (msg.sender, to, tokenId);

  } 
    
}