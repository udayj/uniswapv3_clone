// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.14;

import "./Math.sol";

library SwapMath {
    function computeSwapStep(
        uint160 sqrtPriceCurrentX96,
        uint160 sqrtPriceTargetX96,
        uint128 liquidity,
        uint256 amountRemaining
    ) internal pure returns (uint160 sqrtPriceNextX96, uint256 amountIn, uint256 amountOut) {
        bool zeroForOne = sqrtPriceCurrentX96 >= sqrtPriceTargetX96;

        // we are calculating what would be the delta in the swapped in token for the given
        // liquidity level
        // if it is less than or equal to the amountRemaining tokens of the swapped in token
        // then we reach the price boundary
        amountIn = zeroForOne
            ? Math.calcAmount0Delta(sqrtPriceCurrentX96, sqrtPriceTargetX96, liquidity)
            : Math.calcAmount1Delta(sqrtPriceCurrentX96, sqrtPriceTargetX96, liquidity);

        if (amountRemaining >= amountIn) {
            sqrtPriceNextX96 = sqrtPriceTargetX96;
        } else {
            sqrtPriceNextX96 =
                Math.getNextSqrtPriceFromInput(sqrtPriceCurrentX96, liquidity, amountRemaining, zeroForOne);
        }

        amountIn = Math.calcAmount0Delta(sqrtPriceCurrentX96, sqrtPriceNextX96, liquidity);
        amountOut = Math.calcAmount1Delta(sqrtPriceCurrentX96, sqrtPriceNextX96, liquidity);

        if (!zeroForOne) {
            (amountIn, amountOut) = (amountOut, amountIn);
        }
    }
}
