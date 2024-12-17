;; Bounty or Task Reward Smart Contract

;; Constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERROR_NOT_AUTHORIZED (err u100))
(define-constant ERROR_INVALID_REWARD_AMOUNT (err u101))
(define-constant ERROR_INSUFFICIENT_FUNDS (err u102))
(define-constant ERROR_BOUNTY_NOT_FOUND (err u103))
(define-constant ERROR_BOUNTY_NOT_ACTIVE (err u104))
(define-constant ERROR_BOUNTY_ALREADY_CLAIMED (err u105))
(define-constant ERROR_CANNOT_CLAIM_OWN_BOUNTY (err u106))
(define-constant ERROR_INVALID_BOUNTY_ID (err u107))
(define-constant ERROR_INVALID_BOUNTY_DESCRIPTION (err u108))

;; Data variables
(define-data-var bounty-counter uint u0)

;; Maps
(define-map bounties
  { bounty-id: uint }
  {
    creator: principal,
    description: (string-utf8 256),
    reward-amount: uint,
    is-active: bool,
    claimed-by: (optional principal),
    creation-timestamp: uint,
    completion-timestamp: (optional uint)
  }
)

;; Private functions
(define-private (is-contract-owner)
  (is-eq tx-sender CONTRACT_OWNER)
)

(define-private (get-current-timestamp)
  (unwrap-panic (get-block-info? time (- block-height u1)))
)

(define-private (is-valid-bounty-id (bounty-id uint))
  (< bounty-id (var-get bounty-counter))
)

(define-private (is-valid-description (description (string-utf8 256)))
  (> (len description) u0)
)

;; Public functions

;; Create a new bounty
(define-public (create-bounty (description (string-utf8 256)) (reward-amount uint))
  (let
    (
      (bounty-id (var-get bounty-counter))
      (creation-time (get-current-timestamp))
    )
    (asserts! (is-valid-description description) ERROR_INVALID_BOUNTY_DESCRIPTION)
    (asserts! (> reward-amount u0) ERROR_INVALID_REWARD_AMOUNT)
    (asserts! (>= (stx-get-balance tx-sender) reward-amount) ERROR_INSUFFICIENT_FUNDS)
    
    (try! (stx-transfer? reward-amount tx-sender (as-contract tx-sender)))
    
    (map-set bounties
      { bounty-id: bounty-id }
      {
        creator: tx-sender,
        description: description,
        reward-amount: reward-amount,
        is-active: true,
        claimed-by: none,
        creation-timestamp: creation-time,
        completion-timestamp: none
      }
    )
    
    (var-set bounty-counter (+ bounty-id u1))
    (ok bounty-id)
  )
)

;; Claim a bounty and receive the reward
(define-public (claim-bounty (bounty-id uint))
  (let
    (
      (bounty (unwrap! (map-get? bounties { bounty-id: bounty-id }) ERROR_BOUNTY_NOT_FOUND))
      (completion-time (get-current-timestamp))
    )
    (asserts! (is-valid-bounty-id bounty-id) ERROR_INVALID_BOUNTY_ID)
    (asserts! (get is-active bounty) ERROR_BOUNTY_NOT_ACTIVE)
    (asserts! (is-none (get claimed-by bounty)) ERROR_BOUNTY_ALREADY_CLAIMED)
    (asserts! (not (is-eq tx-sender (get creator bounty))) ERROR_CANNOT_CLAIM_OWN_BOUNTY)
    
    (try! (as-contract (stx-transfer? (get reward-amount bounty) tx-sender tx-sender)))
    
    (map-set bounties
      { bounty-id: bounty-id }
      (merge bounty {
        is-active: false,
        claimed-by: (some tx-sender),
        completion-timestamp: (some completion-time)
      })
    )
    
    (ok true)
  )
)

;; Cancel a bounty (only the creator can cancel)
(define-public (cancel-bounty (bounty-id uint))
  (let
    (
      (bounty (unwrap! (map-get? bounties { bounty-id: bounty-id }) ERROR_BOUNTY_NOT_FOUND))
    )
    (asserts! (is-valid-bounty-id bounty-id) ERROR_INVALID_BOUNTY_ID)
    (asserts! (is-eq tx-sender (get creator bounty)) ERROR_NOT_AUTHORIZED)
    (asserts! (get is-active bounty) ERROR_BOUNTY_NOT_ACTIVE)
    (asserts! (is-none (get claimed-by bounty)) ERROR_BOUNTY_ALREADY_CLAIMED)
    
    (try! (as-contract (stx-transfer? (get reward-amount bounty) tx-sender (get creator bounty))))
    
    (map-set bounties
      { bounty-id: bounty-id }
      (merge bounty {
        is-active: false
      })
    )
    
    (ok true)
  )
)

;; Read-only functions

;; Get bounty details
(define-read-only (get-bounty-details (bounty-id uint))
  (map-get? bounties { bounty-id: bounty-id })
)

;; Get the total number of bounties
(define-read-only (get-total-bounties)
  (var-get bounty-counter)
)

;; Get active bounties
(define-read-only (get-active-bounties (max-results uint))
  (let
    (
      (total-bounties (var-get bounty-counter))
      (result-limit (min max-results total-bounties))
    )
    (filter is-bounty-active 
      (map get-bounty-details 
        (generate-sequence-to-limit result-limit)
      )
    )
  )
)

(define-private (is-bounty-active (bounty (optional {
    creator: principal,
    description: (string-utf8 256),
    reward-amount: uint,
    is-active: bool,
    claimed-by: (optional principal),
    creation-timestamp: uint,
    completion-timestamp: (optional uint)
  })))
  (match bounty
    bounty-data (get is-active bounty-data)
    false
  )
)

(define-private (generate-sequence-to-limit (n uint))
  (list
    u0 u1 u2 u3 u4 u5 u6 u7 u8 u9 u10 u11 u12 u13 u14 u15
    u16 u17 u18 u19 u20 u21 u22 u23 u24 u25 u26 u27 u28 u29 u30 u31
  )
)

(define-private (min (a uint) (b uint))
  (if (<= a b) a b)
)