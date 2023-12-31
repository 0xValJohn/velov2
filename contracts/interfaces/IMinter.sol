// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IMinter {
    error AlreadyNudged();
    error NotEpochGovernor();
    error TailEmissionsInactive();

    event Mint(address indexed _sender, uint256 _weekly, uint256 _circulating_supply, bool indexed _tail);
    event Nudge(uint256 indexed _period, uint256 _oldRate, uint256 _newRate);

    /// @notice Timestamp of start of epoch that updatePeriod was last called in
    function activePeriod() external returns (uint256);

    /// @notice Allows epoch governor to modify the tail emission rate by at most 1 basis point
    ///         per epoch to a maximum of 100 basis points or to a minimum of 1 basis point.
    ///         Note: the very first nudge proposal must take place the week prior
    ///         to the tail emission schedule starting.
    /// @dev Throws if not epoch governor.
    ///      Throws if not currently in tail emission schedule.
    ///      Throws if already nudged this epoch.
    ///      Throws if nudging above maximum rate.
    ///      Throws if nudging below minimum rate.
    ///      This contract is coupled to EpochGovernor as it requires three option simple majority voting.
    function nudge() external;

    /// @notice Calculates rebases according to the formula
    ///         weekly * (ve.totalSupply / velo.totalSupply) ^ 3 / 2
    ///         Note that ve.totalSupply is the locked ve supply
    ///         velo.totalSupply is the total ve supply minted
    /// @param _minted Amount of VELO minted this epoch
    /// @return _growth Rebases
    function calculateGrowth(uint256 _minted) external view returns (uint256 _growth);

    /// @notice Processes emissions and rebases. Callable once per epoch (1 week).
    /// @return _period Start of current epoch.
    function updatePeriod() external returns (uint256 _period);
}
