pragma solidity ^0.8.14

contract UniswapV3Pool {
    
    error InvalidRange();
    error ZeroLiquidity();

    using Tick for mapping(int24 => TickInfo);
    using Position for mapping(bytes32 => Position.Info);
    using Position for Position.Info;

    int24 internal constant MIN_TICK = -887272;
    int24 internal constant MAX_TICK = -MIN_TICK;

    address public immutable token0;
    address public immutable token1;

    struct Slot0 {
        uint160 sqrtPriceX96;
        int24 tick;
    }

    Slot0 public slot0;
    uint128 public liquidity;

    mapping(int24 => Tick.info) public ticks;
    mapping(bytes32 => Position.info) public positions;

    constructor(
        address token0_,
        address token1_,
        uint160 sqrtPriceX96,
        int24 tick
    ) {

        token0 = token0_;
        token1 = token1_;
        slot0 = Slot0({sqrtPriceX96: sqrtPriceX96, tick: tick});
    }

    function mint(
        address owner,
        int24 lowerTick,
        int24 upperTick,
        uint128 amount
    ) external returns(uint256 amount0, uint256 amount1) {

        if(
            lowerTick >= upperTick ||
            lowerTick < MIN_TICK ||
            upperTick > MAX_TICK
        ) revert InvalidRange();

        if (amount == 0) revert ZeroLiquidity();

        ticks.update(lowerTick, amount);
        ticks.update(upperTick, amount);

        Position.Info storage position = positions.get(
            owner,
            lowerTick,
            upperTick
        );

        position.update(amount);

        
    }
}