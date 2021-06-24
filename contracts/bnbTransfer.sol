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
   import "./dependencies.sol";
   import "https://github.com/pancakeswap/pancake-swap-core/blob/master/contracts/interfaces/IPancakePair.sol";
   import "./VTokenInterface.sol";
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
    
       function depositBNB() public payable{
           //deposit BNB
           BNBbalance += msg.value;
           has_stake_BNB = true;
       }
       
       
       function withdrawBNB(uint BNBAmount) public onlyOwner{
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
        BUSDBasic token1 = BUSDBasic(pair.token1());

        (uint Res0, uint Res1,) = pair.getReserves();

    // decimals
        uint res0 = Res0*(10**token1.decimals());
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
       
   }