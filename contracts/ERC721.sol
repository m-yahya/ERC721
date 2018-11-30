pragma solidity ^0.4.24;
import "browser/ERC721Interface.sol";

interface ERC721TokenReceiver {
    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes _data) external returns (bytes4);
}

contract ERC721 is ERC721Interface{

    mapping (address => uint256) ownerNFTokenCount;
    mapping (uint256 => address) ownerOfToken;
    mapping (uint256 => address) approvalForToken;
    mapping (address => mapping(address => bool)) operatorApprovals;

    function balanceOf (address _owner) external view returns (uint256){
        return ownerNFTokenCount[_owner];
    }

    function ownerOf (uint256 _tokenId) external view returns (address){
        return ownerOfToken[_tokenId];
    }

    function transferFrom(address _from, address _to, uint256 _tokenId) external payable{
        transfer(_from, _to, _tokenId);

    }

    function transfer(address _from, address _to, uint256 _tokenId) private {

        require(msg.sender == _from || approvalForToken[_tokenId] == msg.sender || operatorApprovals[_from][msg.sender] == true);
        require(ownerOfToken[_tokenId] == _from);
        require (_to != address(0));

        ownerOfToken[_tokenId] = _to;
        ownerNFTokenCount[_from] -= 1;
        ownerNFTokenCount[_to] += 1;

    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes _data) external payable{
        transfer(_from, _to, _tokenId);
        if(isContract(_to)){
            // call onERC721Received function
            require(ERC721TokenReceiver(_to).onERC721Received(msg.sender, _from, _tokenId, _data) == 0x150b7a02);
        }
    }

   function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable{
    transfer(_from, _to, _tokenId);
    if(isContract(_to)){
        // call onERC721Received function
        require(ERC721TokenReceiver(_to).onERC721Received(msg.sender, _from, _tokenId, '') == 0x150b7a02);
        }
   }

   function approve(address _approved, uint256 _tokenId) external payable{
       require(ownerOfToken[_tokenId] == msg.sender);
       approvalForToken[_tokenId] = _approved;
   }

   function getApproved(uint256 _tokenId) external view returns(address){
       return approvalForToken[_tokenId];
   }

   function setApprovalForAll(address _operator, bool _approved) external {
       operatorApprovals[msg.sender][_operator] == _approved;
   }

   function isApprovedForAll(address _owner, address _operator) external view returns (bool){
       return operatorApprovals[_owner][_operator];
   }

    function isContract(address _to) private view returns (bool){
        uint256 size;
        assembly {size := extcodesize(_to)}
        return(size > 0);
    }

}
