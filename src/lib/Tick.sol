pragma solidity ^0.8.14;

import "./LiquidityMath.sol";

library Tick {

    struct Info {
        bool initialized;
        uint128 liquidityGross;
        int128 liquidityNet;
        uint256 feeGrowthOutside0X128;
        uint256 feeGrowthOutside1X128;
    }

    function update(
        mapping(int24 => Tick.Info) storage self,
        int24 tick,
        int24 currentTick,
        int128 liquidityDelta,
        uint256 feeGrowthGlobal0x128,
        uint256 feeGrowthGlobal1x128,
        bool upper
    ) internal returns (bool flipped) {

        Tick.Info storage tickInfo = self[tick];
        uint128 liquidityBefore = tickInfo.liquidityGross;
        uint128 liquidityAfter = LiquidityMath.addLiquidity(
            liquidityBefore,
            liquidityDelta
        );

        if (liquidityBefore == 0) {
            tickInfo.initialized = true;

            if(tick < currentTick) {
                tickInfo.feeGrowthOutside0X128 = feeGrowthGlobal0x128;
                tickInfo.feeGrowthOutside1X128 = feeGrowthGlobal1x128;
            }
        }
        flipped = (liquidityAfter == 0) != (liquidityBefore == 0);
        tickInfo.liquidityGross = liquidityAfter;
        // while swapping, when crossing an upper tick, we are adding the liquidityDelta to the state liquidity
        // hence, if liquidityDelat is negative, then only the liquidity will ultimately get substrated from the current liquidity
        // opposite holds for lower tick, we reverse the sign of the liquidityDelat before substracting the liquidity and that is
        // why liquidityDelta is added at lower ticks
        tickInfo.liquidityNet = upper
            ? int128(int256(tickInfo.liquidityNet) - liquidityDelta)
            : int128(int256(tickInfo.liquidityNet) + liquidityDelta);

    }

     function cross(
        mapping(int24 => Tick.Info) storage self, 
        int24 tick,
        uint256 feeGrowthGlobal0X128,
        uint256 feeGrowthGlobal1X128)
        internal
        returns (int128 liquidityDelta)
    {
        Tick.Info storage info = self[tick];

        info.feeGrowthOutside0X128 = feeGrowthGlobal0X128 - info.feeGrowthOutside0X128;
        info.feeGrowthOutside1X128 = feeGrowthGlobal1X128 - info.feeGrowthOutside1X128;
        liquidityDelta = info.liquidityNet;
    }

    function getFeeGrowthInside(
        mapping(int24 => Tick.Info) storage self,
        int24 lowerTick_,
        int24 upperTick_,
        int24 currentTick,
        uint256 feeGrowthGlobal0X128,
        uint256 feeGrowthGlobal1X128
    )
    internal
    view
    returns (uint256 feeGrowthInside0X128, uint256 feeGrowthInside1X128) {

        Tick.Info storage lowerTick = self[lowerTick_];
        Tick.Info storage upperTick = self[upperTick_];

        uint256 feeGrowthBelow0X128;
        uint256 feeGrowthBelow1X128;

        if (currentTick >= lowerTick_) {
            feeGrowthBelow0X128 = lowerTick.feeGrowthOutside0X128;
            feeGrowthBelow1X128 = lowerTick.feeGrowthOutside1X128;
        } else {
            feeGrowthBelow0X128 =
                feeGrowthGlobal0X128 -
                lowerTick.feeGrowthOutside0X128;
            feeGrowthBelow1X128 =
                feeGrowthGlobal1X128 -
                lowerTick.feeGrowthOutside1X128;
        }

        uint256 feeGrowthAbove0X128;
        uint256 feeGrowthAbove1X128;
        if (currentTick < upperTick_) {
            feeGrowthAbove0X128 = upperTick.feeGrowthOutside0X128;
            feeGrowthAbove1X128 = upperTick.feeGrowthOutside1X128;
        } else {
            feeGrowthAbove0X128 =
                feeGrowthGlobal0X128 -
                upperTick.feeGrowthOutside0X128;
            feeGrowthAbove1X128 =
                feeGrowthGlobal1X128 -
                upperTick.feeGrowthOutside1X128;
        }

        feeGrowthInside0X128 =
            feeGrowthGlobal0X128 -
            feeGrowthBelow0X128 -
            feeGrowthAbove0X128;
        feeGrowthInside1X128 =
            feeGrowthGlobal1X128 -
            feeGrowthBelow1X128 -
            feeGrowthAbove1X128;

    }
}
