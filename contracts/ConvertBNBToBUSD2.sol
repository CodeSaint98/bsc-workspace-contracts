// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.6.12;

/**
   * 1) Contract owner can deposit BNB into smart contract
* 2) Contract owner can withdraw BNB from contract
* 3) The contract owner can request the contract to Stake a set amount of BnB in the contract with the venus protocol
* 4) The contract owner user can request the contract to unstake a set amount of BNB from venus protocol
* 5) The contract owner can use pancake swap to swap BNB in the contract to BUSD that is kept in the contract
* 6) The contract owner can use pancake swap to swap BUSD in the contract to BNB that is kept in the contract
* 7) The contract needs to track BNB currently in Contract, BUSD currently in contract, and amount BNB staked with venus protocol
   */
   //_testnetBUSDPAIRADDRESS: 0x26e364CBF4b51927baA0318bA5fc26F26A1b1658
   //_testBUSDToken: 0x8301f2213c0eed49a7e28ae4c3e91722919b8b47
   //_PANCAKESWAPROUTER V2: 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3
   // txn hash: https://testnet.bscscan.com/tx/0x81a1b40f109010c9e614c09bbc00d0d3ef2a064c2f9b9bf704342c77c030823d
   import "https://github.com/pancakeswap/pancake-swap-core/blob/master/contracts/interfaces/IPancakePair.sol";
   import "https://github.com/pancakeswap/pancake-swap-periphery/blob/master/contracts/interfaces/IPancakeRouter02.sol";
   
   
   
   library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}


   interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface BUSDBasic{
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
    }
   


   contract BNBConvert{
       using SafeMath for uint256;
       
       address public BUSDpairAddress;
       uint256 public BNBbalance;
       uint256 public BUSDbalance;
       BUSDBasic public BUSD_Token;
       IERC20 public WETH;
       IPancakeRouter02 public PANCAKE_ROUTER;
    constructor(
        address _BUSDpairAddress,
        address _pancakeswapRouter,
         address _BUSD_Token) public{
            BUSDpairAddress = _BUSDpairAddress;
            PANCAKE_ROUTER = IPancakeRouter02(_pancakeswapRouter);
            BUSD_Token = BUSDBasic(_BUSD_Token);
            WETH = IERC20(PANCAKE_ROUTER.WETH());
        }
        
        function depositBNB() public payable{
           //deposit BNB
           BNBbalance += msg.value;
       }
       
        function withdrawBNB(uint BNBAmount) public{
           require(BNBAmount<BNBbalance, "You do not have that much BNB");
           payable(msg.sender).transfer(BNBAmount);
           BNBbalance -= BNBAmount;
         
       }
       
        function getPathForBNBtoBUSD() private view returns (address[] memory) {
        address[] memory path = new address[](2);
        path[0] = PANCAKE_ROUTER.WETH();
        path[1] = address(BUSD_Token);
    
        return path;
       }
       function getPathForBUSDtoBNB() private view returns (address[] memory) {
        address[] memory path = new address[](2);
        path[0] = address(BUSD_Token);
        path[1] = PANCAKE_ROUTER.WETH();
    
        return path;
      }
    
       function getEstimatedBUSDPrice(uint amount) public view returns(uint){
    
        IPancakePair pair = IPancakePair(BUSDpairAddress);

        (uint256 Res0, uint256 Res1,) = pair.getReserves();

    // decimals
        uint256 res1 = Res1*(10**18);
        return((amount*res1)/Res0); // return amount of token0 needed to buy token1
      }
       
      function convertBNBToBUSD(uint BUSDAmount) public {
            // Buy BUSD with BNB stored in the contract
           uint deadline = block.timestamp + 120;
           uint tAmount = getEstimatedBUSDPrice(BUSDAmount);
           require(BNBbalance>tAmount, "You do not have enough BNB staked in the contract");
           PANCAKE_ROUTER.swapETHForExactTokens{value: BNBbalance}(tAmount,getPathForBNBtoBUSD(),address(this), deadline);
           // refund leftover ETH to user
        address(this).call.value(address(this).balance)("");
        BUSDbalance += BUSDAmount;
        BNBbalance -= tAmount;
       }
       
    
       receive() payable external{}
   }