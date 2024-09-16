pragma solidity ^0.8.14;

function update(
    Info storage self,
    uint128 liquidityDelta
) internal {

    uint128 liquidityBefore = self.liquidity;
    uint128 liquidityAfter = liquidityBefore + liquidityDelta;
    self.liquidity = liquidityAfter;
}

function get(
    mapping(bytes32 => Info) storage self,
    address owner,
    int24 lowerTick,
    int24 upperTick
) internal returns(Position.Info storage position) {

    position = self[
        keccak256(abi.encodePacked(owner, lowerTick, upperTick))
    ];
}