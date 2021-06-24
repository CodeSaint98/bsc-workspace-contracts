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


MAINNET ADDRESSES
-----------------
_BUSDPAIRADDRESS: 0x58F876857a02D6762E0101bb5C46A8c1ED44Dc16
_BNBPAIRADDRESS: 0x58F876857a02D6762E0101bb5C46A8c1ED44Dc16
_BUSD_TOKEN: 0x8301f2213c0eed49a7e28ae4c3e91722919b8b47
_PANCAKESWAPROUTER V2: 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3
_VBNB: 0xA07c5b74C9B40447a954e1466938b865b6BBea36
_testnetBUSDPAIRADDRESS: 0x26e364CBF4b51927baA0318bA5fc26F26A1b1658


   */



// PANCAKEPAIR.SOL START

interface IPancakePair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}


// PANCAKEPAIR.SOL END



// START import "./dependencies.sol"

contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor() internal {}

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
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

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// END import "./dependencies.sol"


// START import "./VTokenInterface.sol"

abstract contract VTokenInterface{
    function transfer(address dst, uint amount) external virtual returns (bool);
    function transferFrom(address src, address dst, uint amount) external virtual returns (bool);
    function approve(address spender, uint amount) external virtual returns (bool);
    function allowance(address owner, address spender) external virtual view returns (uint);
    function balanceOf(address owner) external virtual view returns (uint);
    function balanceOfUnderlying(address owner) external virtual returns (uint);
    function getAccountSnapshot(address account) external virtual view returns (uint, uint, uint, uint);
    function borrowRatePerBlock() external virtual view returns (uint);
    function supplyRatePerBlock() external virtual view returns (uint);
    function totalBorrowsCurrent() external virtual returns (uint);
    function borrowBalanceCurrent(address account) external virtual returns (uint);
    function borrowBalanceStored(address account) public virtual view returns (uint);
    function exchangeRateCurrent() public virtual returns (uint);
    function exchangeRateStored() public virtual view returns (uint);
    function getCash() external virtual view returns (uint);
    function accrueInterest() public virtual returns (uint);
    function seize(address liquidator, address borrower, uint seizeTokens) external virtual returns (uint);
    function mint(uint mintAmount) external virtual returns (uint);
    function redeem(uint redeemTokens) external virtual returns (uint);
    function redeemUnderlying(uint redeemAmount) external virtual returns (uint);
    function borrow(uint borrowAmount) external virtual returns (uint);
    function repayBorrow(uint repayAmount) external virtual returns (uint);
    function repayBorrowBehalf(address borrower, uint repayAmount) external virtual returns (uint);
    function liquidateBorrow(address borrower, uint repayAmount, VTokenInterface vTokenCollateral) external virtual returns (uint);

}

// END import "./VTokenInterface.sol"



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
   
   interface PancakeSwapRouterLT {

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (
        uint256 amountTokenA,
        uint256 amountTokenB,
        uint256 liquidity
    );

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (
        uint256 amountB
    );

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (
        uint256[] memory amounts
    );
    
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
        
    function WETH() external pure returns (address);
    
}


   contract BNBTransfer is Ownable{
       
       event MyLog(string, uint256);
       
        uint256 public BNBbalance;
        uint256 public BUSDbalance;
        bool has_stake_BNB;
       
       address public BUSDpairAddress;
       address public BNBpairAddress;
       BUSDBasic public BUSD_Token;
       VTokenInterface VBNB;
       PancakeSwapRouterLT public PANCAKE_ROUTER;
    
    constructor(
        address _BUSDpairAddress,
        address _BNBpairAddress,
        address _BUSD_Token,
        address payable _VBNB,
        address _pancakeswapRouter) public{
            BUSDpairAddress = _BUSDpairAddress;
            BNBpairAddress = _BNBpairAddress;
            BUSD_Token = BUSDBasic(_BUSD_Token);
            VBNB = VTokenInterface(_VBNB);
            PANCAKE_ROUTER = PancakeSwapRouterLT(_pancakeswapRouter);
        }
    
       function depositBNB(uint256 amount) public payable{
           //deposit BNB
	   require(msg.value == amount);
           BNBbalance += msg.value;
           has_stake_BNB = true;
       }
       
       
       function withdrawBNB(uint BNBAmount) public onlyOwner{
           require(BNBAmount<BNBbalance, "You do not have that much BNB");
           payable(address(this)).transfer(BNBAmount);
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

        (uint Res0, uint Res1,) = pair.getReserves();

    // decimals
        uint res0 = Res0*(10**BUSD_Token.decimals());
        return((amount*res0)/Res1); // return amount of token0 needed to buy token1
      }
        
        function convertBNBToBUSD(uint BUSDAmount) public payable {
            // Buy BUSD with BNB stored in the contract
           require(has_stake_BNB, "This account has no BNB staked");
           uint deadline = block.timestamp + 120;
           uint tAmount = getEstimatedBUSDPrice(BUSDAmount);
           PANCAKE_ROUTER.swapETHForExactTokens(tAmount,getPathForBNBtoBUSD(),address(this), deadline);
           // refund leftover ETH to user
        (bool success,) = msg.sender.call{ value: address(this).balance }("");
        BUSDbalance += tAmount;
        require(success, "refund failed");
       }
       
       function convertBUSDToBNB(uint BNBAmount) public payable {
           require(has_stake_BNB, "This account has no BNB staked");
           uint tAmount = getEstimatedBUSDPrice(BNBAmount);
           require(BUSDbalance>tAmount, "This account does not have enough BUSD");
           uint deadline = block.timestamp + 120;
           BUSD_Token.approve(address(PANCAKE_ROUTER), tAmount );
           PANCAKE_ROUTER.swapExactTokensForETH(tAmount, BNBAmount, getPathForBUSDtoBNB(), address(this), deadline);
           
       }
       
       function stakeBNB(uint BNBAmount) public payable returns (bool) {
           require(BNBAmount<BNBbalance, "You do not have that much BNB");
           // Amount of current exchange rate from cToken to underlying
        uint256 exchangeRateMantissa = VBNB.exchangeRateCurrent();
        emit MyLog("Exchange Rate (scaled up by 1e18): ", exchangeRateMantissa);

        // Amount added to you supply balance this block
        uint256 supplyRateMantissa = VBNB.supplyRatePerBlock();
        emit MyLog("Supply Rate: (scaled up by 1e18)", supplyRateMantissa);

        VBNB.mint(BNBAmount);
        return true;
       }
       
       function redeemVBNB() public payable returns (bool) {
           uint VBNBbalance = VBNB.balanceOf(address(this));
           VBNB.redeem(VBNBbalance);
       }

fallback() external payable {
    // nothing to do
}

	// remove after production  
	  function kill() public onlyOwner{
        address payable owner1 = payable(address(owner()));
        selfdestruct(owner1);		    
		   }
       
   }