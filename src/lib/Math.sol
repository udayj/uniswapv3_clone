// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.14;

import "./FixedPoint96.sol";
import "prb-math/PRBMath.sol";

library Math {

    function calcAmount0Delta(
        uint160 sqrtPriceAX96,
        uint160 sqrtPriceBX96,
        uint128 liquidity
    ) internal pure returns(uint256 amount0) {

        if (sqrtPriceAX96 > sqrtPriceBX96)
            (sqrtPriceAX96, sqrtPriceBX96) = (sqrtPriceBX96, sqrtPriceAX96);
        require(sqrtPriceAX96>0);

        amount0 = divRoundingUp(
            mulDivRoundingUp(
                (uint256(liquidity) << FixedPoint96.RESOLUTION),
                sqrtPriceBX96-sqrtPriceAX96,
                sqrtPriceBX96
            ),
            sqrtPriceAX96
        );
    }

    function calcAmount1Delta(
        uint160 sqrtPriceAX96,
        uint160 sqrtPriceBX96,
        uint128 liquidity
    ) internal pure returns(uint256 amount1) {

        if (sqrtPriceAX96 > sqrtPriceBX96)
            (sqrtPriceAX96, sqrtPriceBX96) = (sqrtPriceBX96, sqrtPriceAX96);
        
        amount1 = mulDivRoundingUp(
            (uint256(liquidity) << FixedPoint96.RESOLUTION),
            (sqrtPriceBX96 - sqrtPriceAX96),
            FixedPoint96.Q96
        );
    }
}