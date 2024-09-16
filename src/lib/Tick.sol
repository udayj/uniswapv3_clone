pragma solidity ^0.8.14;

function update(
    mapping(int24 => Tick.info) storage self,
    int24 tick,
    uint128 liquidityDelta
) internal {

    Tick.info storage tickInfo = self[tick];
    uint128 liquidityBefore = tickInfo.liquidity;
    uint128 liquidityAfter = liquidityBefore + liquidityDelta;
    if (liquidityBefore == 0) {
        tickInfo.initialized = true;
    }

    tickInfo.liquidity = liquidityAfter;

}