# Juice Periphery
A small collection of Juicebox contracts not part of the core deployment, but that may be of use when building/extending on core contracts.

## JBOwnable
A JB variation upon [OpenZeppelin Ownable](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol) to allow for more seamless Ownable support for projects, changes from the regular Ownable are:
- Ability to transfer ownership to a JB Project instead of a harcoded address
- Ability to grant users/contracts permission to call OnlyOwner methods using `JBOperatorStore`
- Includes the `JBOperatable` modifiers with support for [OpenZeppelin `Context`](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Context.sol) to allow for (optional) meta-transaction support

All features are backwards compatible with OpenZeppelin Ownable, this should be a drop-in replacement.