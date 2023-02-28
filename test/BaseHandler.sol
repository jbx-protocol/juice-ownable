// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {CommonBase} from "forge-std/Base.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import {StdUtils} from "forge-std/StdUtils.sol";
import {console} from "forge-std/console.sol";
import {StdAssertions} from "forge-std/StdAssertions.sol";


abstract contract OwnableHandler is CommonBase, StdCheats, StdUtils, StdAssertions  {
    mapping(bytes32 => uint256) public calls;
    
    modifier countCall(bytes32 key) {
        calls[key]++;
        _;
    }
}