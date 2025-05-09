const sig = @import("../../../sig.zig");

const Pubkey = sig.core.Pubkey;
const Slot = sig.core.Slot;
const Hash = sig.core.Hash;
const vote_program = sig.runtime.program.vote_program;

pub const IntializeAccount = struct {
    node_pubkey: Pubkey,
    /// The vote authority keypair signs vote transactions. Can be the same as the identity account.
    authorized_voter: Pubkey,
    /// The authorized withdrawer keypair is used to withdraw funds from a vote account,
    /// including validator rewards. Only this keypair can access the funds.
    authorized_withdrawer: Pubkey,
    /// Commission is the percentage of network rewards kept by the validator.
    /// The rest is distributed to delegators based on their stake weight.
    commission: u8,

    pub const AccountIndex = enum(u8) {
        /// `[WRITE]` Uninitialized vote account
        account = 0,
        /// `[]` Rent sysvar
        rent_sysvar = 1,
        /// `[]` Clock sysvar
        clock_sysvar = 2,
        /// `[SIGNER]` New validator identity (node_pubkey)
        signer = 3,
    };
};

pub const Authorize = struct {
    /// Public Key to be made the new authority for the vote account.
    new_authority: Pubkey,
    /// Type of autorization to grant.
    vote_authorize: vote_program.state.VoteAuthorize,

    pub const AccountIndex = enum(u8) {
        /// `[WRITE]` Vote account to be updated with the Pubkey for authorization
        account = 0,
        /// `[]` Clock sysvar
        clock_sysvar = 1,
        /// `[SIGNER]` Vote or withdraw authority
        current_authority = 2,
    };
};

pub const VoteAuthorizeWithSeedArgs = struct {
    authorization_type: vote_program.state.VoteAuthorize,
    current_authority_derived_key_owner: Pubkey,
    current_authority_derived_key_seed: []const u8,
    new_authority: Pubkey,

    pub const AccountIndex = enum(u8) {
        /// `[WRITE]` Vote account to be updated
        account = 0,
        /// `[]` Clock sysvar
        clock_sysvar = 1,
        /// `[SIGNER]` Base key of current Voter or Withdrawer authority's derived key
        current_base_authority = 2,
    };
};

pub const VoteAuthorizeCheckedWithSeedArgs = struct {
    authorization_type: vote_program.state.VoteAuthorize,
    current_authority_derived_key_owner: Pubkey,
    current_authority_derived_key_seed: []const u8,

    pub const AccountIndex = enum(u8) {
        /// `[Write]` Vote account to be updated
        account = 0,
        /// `[]` Clock sysvar
        clock_sysvar = 1,
        ///  `[SIGNER]` Base key of current Voter or Withdrawer authority's derived key
        current_base_authority = 2,
        /// `[SIGNER]` New vote or withdraw authority
        new_authority = 3,
    };
};

pub const VoteAuthorize = enum {
    withdrawer,
    voter,

    pub const AccountIndex = enum(u8) {
        /// `[Write]` Vote account to be updated with the Pubkey for authorization
        account = 0,
        /// `[]` Clock sysvar
        clock_sysvar = 1,
        ///  `[SIGNER]` Vote or withdraw authority
        current_authority = 2,
        /// `[SIGNER]` New vote or withdraw authority
        new_authority = 3,
    };
};

pub const UpdateVoteIdentity = struct {
    pub const AccountIndex = enum(u8) {
        /// `[Write]` Vote account to be updated with the given authority public key
        account = 0,
        /// `[SIGNER]` New validator identity (node_pubkey)
        new_identity = 1,
        ///  `[SIGNER]` Withdraw authority
        current_authority = 2,
    };
};

pub const UpdateCommission = struct {
    pub const AccountIndex = enum(u8) {
        /// `[Write]` Vote account to be updated
        account = 0,
        /// `[SIGNER]` Withdraw authority
        current_authority = 1,
    };
};

pub const Withdraw = struct {
    pub const AccountIndex = enum(u8) {
        /// `[Write]` Vote account to be updated
        account = 0,
        /// `[Write]` Recipient account
        recipient_authority = 1,
        /// `[SIGNER]` Withdraw authority
        current_authority = 2,
    };
};

pub const Vote = struct {
    vote: vote_program.state.Vote,

    pub const AccountIndex = enum(u8) {
        /// `[WRITE]` Vote account to vote with
        account = 0,
        /// `[]` Slot hashes sysvar
        slot_sysvar = 1,
        ///  `[]` Clock sysvar
        clock_sysvar = 2,
        /// `[SIGNER]` Vote authority
        vote_authority = 3,
    };
};

pub const VoteSwitch = struct {
    vote: vote_program.state.Vote,
    hash: Hash,

    pub const AccountIndex = enum(u8) {
        /// `[WRITE]` Vote account to vote with
        account = 0,
        /// `[]` Slot hashes sysvar
        slot_sysvar = 1,
        ///  `[]` Clock sysvar
        clock_sysvar = 2,
        /// `[SIGNER]` Vote authority
        vote_authority = 3,
    };
};

pub const VoteStateUpdate = struct {
    vote_state_update: vote_program.state.VoteStateUpdate,

    pub const AccountIndex = enum(u8) {
        /// `[WRITE]` Vote account to vote with
        account = 0,
        /// `[]` Vote authority
        vote_authority = 1,
    };
};

pub const VoteStateUpdateSwitch = struct {
    vote_state_update: vote_program.state.VoteStateUpdate,
    hash: Hash,

    pub const AccountIndex = enum(u8) {
        /// `[WRITE]` Vote account to vote with
        account = 0,
        /// `[]` Vote authority
        vote_authority = 1,
    };
};

pub const TowerSync = struct {
    tower_sync: vote_program.state.TowerSync,

    pub const AccountIndex = enum(u8) {
        /// `[WRITE]` Vote account to vote with
        account = 0,
        /// `[]` Vote authority
        vote_authority = 1,
    };
};

pub const TowerSyncSwitch = struct {
    tower_sync: vote_program.state.TowerSync,
    hash: Hash,

    pub const AccountIndex = enum(u8) {
        /// `[WRITE]` Vote account to vote with
        account = 0,
        /// `[]` Vote authority
        vote_authority = 1,
    };
};

/// [agave] https://github.com/anza-xyz/solana-sdk/blob/3426febe49bd701f54ea15ce11d539e277e2810e/vote-interface/src/instruction.rs#L26
pub const Instruction = union(enum) {
    /// Initialize a vote account
    ///
    /// # Account references
    ///   0. `[WRITE]` Uninitialized vote account
    ///   1. `[]` Rent sysvar
    ///   2. `[]` Clock sysvar
    ///   3. `[SIGNER]` New validator identity (node_pubkey)
    initialize_account: IntializeAccount,

    /// Authorize a key to send votes or issue a withdrawal
    ///
    /// # Account references
    ///   0. `[WRITE]` Vote account to be updated with the Pubkey for authorization
    ///   1. `[]` Clock sysvar
    ///   2. `[SIGNER]` Current vote or withdraw authority
    authorize: Authorize,

    /// Given that the current Voter or Withdrawer authority is a derived key,
    /// this instruction allows someone who can sign for that derived key's
    /// base key to authorize a new Voter or Withdrawer for a vote account.
    ///
    /// # Account references
    ///   0. `[Write]` Vote account to be updated
    ///   1. `[]` Clock sysvar
    ///   2. `[SIGNER]` Base key of current Voter or Withdrawer authority's derived key
    authorize_with_seed: VoteAuthorizeWithSeedArgs,

    /// Given that the current Voter or Withdrawer authority is a derived key,
    /// this instruction allows someone who can sign for that derived key's
    /// base key to authorize a new Voter or Withdrawer for a vote account.
    ///
    /// This instruction behaves like `AuthorizeWithSeed` with the additional requirement
    /// that the new vote or withdraw authority must also be a signer.
    ///
    /// # Account references
    ///   0. `[Write]` Vote account to be updated
    ///   1. `[]` Clock sysvar
    ///   2. `[SIGNER]` Base key of current Voter or Withdrawer authority's derived key
    ///   3. `[SIGNER]` New vote or withdraw authority
    authorize_checked_with_seed: VoteAuthorizeCheckedWithSeedArgs,

    /// Authorize a key to send votes or issue a withdrawal
    ///
    /// This instruction behaves like `Authorize` with the additional requirement that the new vote
    /// or withdraw authority must also be a signer.
    ///
    /// # Account references
    ///   0. `[WRITE]` Vote account to be updated with the Pubkey for authorization
    ///   1. `[]` Clock sysvar
    ///   2. `[SIGNER]` Vote or withdraw authority
    ///   3. `[SIGNER]` New vote or withdraw authority
    authorize_checked: VoteAuthorize,

    /// Update the vote account's validator identity (node_pubkey)
    ///
    /// # Account references
    ///   0. `[WRITE]` Vote account to be updated with the given authority public key
    ///   1. `[SIGNER]` New validator identity (node_pubkey)
    ///   2. `[SIGNER]` Withdraw authority
    update_validator_identity,

    /// Update the commission for the vote account
    ///
    /// # Account references
    ///   0. `[WRITE]` Vote account to be updated
    ///   1. `[SIGNER]` Withdraw authority
    update_commission: u8,
    /// Withdraw some amount of funds
    ///
    /// # Account references
    ///   0. `[WRITE]` Vote account to withdraw from
    ///   1. `[WRITE]` Recipient account
    ///   2. `[SIGNER]` Withdraw authority
    withdraw: u64,
    /// A Vote instruction with recent votes
    ///
    /// # Account references
    ///   0. `[WRITE]` Vote account to vote with
    ///   1. `[]` Slot hashes sysvar
    ///   2. `[]` Clock sysvar
    ///   3. `[SIGNER]` Vote authority
    vote: Vote,
    /// A Vote instruction with recent votes
    ///
    /// # Account references
    ///   0. `[WRITE]` Vote account to vote with
    ///   1. `[]` Slot hashes sysvar
    ///   2. `[]` Clock sysvar
    ///   3. `[SIGNER]` Vote authority
    vote_switch: VoteSwitch,
    /// Update the onchain vote state for the signer.
    ///
    /// # Account references
    ///   0. `[Write]` Vote account to vote with
    ///   1. `[SIGNER]` Vote authority
    update_vote_state: VoteStateUpdate,
    /// Update the onchain vote state for the signer along with a switching proof.
    ///
    /// # Account references
    ///   0. `[Write]` Vote account to vote with
    ///   1. `[SIGNER]` Vote authority
    update_vote_state_switch: VoteStateUpdateSwitch,
    /// Update the onchain vote state for the signer.
    ///
    /// # Account references
    ///   0. `[Write]` Vote account to vote with
    ///   1. `[SIGNER]` Vote authority
    compact_update_vote_state: VoteStateUpdate,
    /// Update the onchain vote state for the signer along with a switching proof.
    ///
    /// # Account references
    ///   0. `[Write]` Vote account to vote with
    ///   1. `[SIGNER]` Vote authority
    compact_update_vote_state_switch: VoteStateUpdateSwitch,
    /// Sync the onchain vote state with local tower
    ///
    /// # Account references
    ///   0. `[Write]` Vote account to vote with
    ///   1. `[SIGNER]` Vote authority
    tower_sync: TowerSync,
    /// Sync the onchain vote state with local tower along with a switching proof
    ///
    /// # Account references
    ///   0. `[Write]` Vote account to vote with
    ///   1. `[SIGNER]` Vote authority
    tower_sync_switch: TowerSyncSwitch,
};
