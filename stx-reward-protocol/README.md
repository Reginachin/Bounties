# Bounty Smart Contract

A Clarity smart contract for managing bounties and rewards on the Stacks blockchain. This contract enables users to create bounties with rewards, allows others to claim them, and provides functionality for bounty management.

## Features

- Create bounties with STX rewards
- Claim bounties and receive rewards
- Cancel bounties (creator only)
- View active bounties
- Track bounty status and history

## Contract Functions

### Public Functions

#### `create-bounty (description reward-amount)`
Creates a new bounty with a specified description and reward amount in STX.

Parameters:
- `description`: UTF-8 string (max 256 characters) describing the bounty
- `reward-amount`: Amount of STX to be paid as reward (uint)

Returns:
- `(ok uint)`: The ID of the created bounty
- `(err uint)`: Error code if creation fails

#### `claim-bounty (bounty-id)`
Claims an active bounty and receives the reward.

Parameters:
- `bounty-id`: The ID of the bounty to claim (uint)

Returns:
- `(ok true)`: If claim is successful
- `(err uint)`: Error code if claim fails

#### `cancel-bounty (bounty-id)`
Cancels an active bounty and returns the reward to the creator.

Parameters:
- `bounty-id`: The ID of the bounty to cancel (uint)

Returns:
- `(ok true)`: If cancellation is successful
- `(err uint)`: Error code if cancellation fails

### Read-Only Functions

#### `get-bounty-details (bounty-id)`
Retrieves details of a specific bounty.

Parameters:
- `bounty-id`: The ID of the bounty (uint)

Returns:
- Bounty data structure or none if not found

#### `get-total-bounties()`
Returns the total number of bounties ever created.

Returns:
- Total bounty count (uint)

#### `get-active-bounties (max-results)`
Returns a list of active bounties.

Parameters:
- `max-results`: Maximum number of bounties to return (uint)

Returns:
- List of active bounties

## Error Codes

- `u100`: Not authorized
- `u101`: Invalid reward amount
- `u102`: Insufficient funds
- `u103`: Bounty not found
- `u104`: Bounty not active
- `u105`: Bounty already claimed
- `u106`: Cannot claim own bounty
- `u107`: Invalid bounty ID
- `u108`: Invalid bounty description

## Data Structures

### Bounty
```clarity
{
  creator: principal,
  description: (string-utf8 256),
  reward-amount: uint,
  is-active: bool,
  claimed-by: (optional principal),
  creation-timestamp: uint,
  completion-timestamp: (optional uint)
}
```

## Usage Examples

### Creating a Bounty
```clarity
;; Create a bounty with 100 STX reward
(contract-call? .bounty-contract create-bounty "Build a website" u100000000)
```

### Claiming a Bounty
```clarity
;; Claim bounty with ID 1
(contract-call? .bounty-contract claim-bounty u1)
```

### Canceling a Bounty
```clarity
;; Cancel bounty with ID 1
(contract-call? .bounty-contract cancel-bounty u1)
```

## Important Notes

1. All STX amounts should be in micro-STX (1 STX = 1,000,000 micro-STX)
2. Only the bounty creator can cancel their bounty
3. Creators cannot claim their own bounties
4. Bounties cannot be claimed once they are marked as inactive
5. The contract holds the STX reward until the bounty is either claimed or canceled

## Security Considerations

1. Funds are locked in the contract until a bounty is either claimed or canceled
2. Only the original creator can cancel a bounty
3. Double-claiming is prevented through state checks
4. Reward amounts are verified against sender's balance
5. All state changes are protected by appropriate checks