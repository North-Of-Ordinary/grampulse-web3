# PHASE 5: Comprehensive Web3 Governance & Transparency Layer

## Overview

PHASE 5 implements a complete Web3 governance and transparency system for GramPulse, combining:

1. **DAO Governance** - Community proposal and voting system
2. **Transparency Dashboard** - Public metrics and statistics
3. **Reputation System** - Soulbound badges and leaderboards
4. **Advanced Attestations** - Batch operations and revocation

---

## 🏛️ DAO Governance System

### Features
- Create proposals for community decisions
- Timelock-based voting periods
- Quadratic voting support
- OpenZeppelin Governor compatible

### Smart Contract Interface
```solidity
interface IGovernor {
    function propose(address[] targets, uint256[] values, bytes[] calldatas, string description) returns (uint256)
    function castVote(uint256 proposalId, uint8 support) returns (uint256)
    function execute(address[] targets, uint256[] values, bytes[] calldatas, bytes32 descriptionHash) returns (uint256)
}
```

### API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/governance/proposal` | POST | Create new proposal |
| `/api/governance/vote` | POST | Cast vote on proposal |
| `/api/governance/execute` | POST | Execute passed proposal |
| `/api/governance/proposal/:id` | GET | Get proposal details |
| `/api/governance/params` | GET | Get governance parameters |

### Proposal States
1. **Pending** - Proposal created, waiting for voting period
2. **Active** - Voting in progress
3. **Canceled** - Proposal was canceled
4. **Defeated** - Did not reach quorum or majority
5. **Succeeded** - Passed voting, ready for execution
6. **Queued** - In timelock queue
7. **Executed** - Successfully executed
8. **Expired** - Timelock expired

---

## 📊 Transparency Dashboard

### Metrics Displayed
- Total attestations created
- Verified attestations count
- Active issues count
- Resolution rate percentage
- Average resolution time
- Today's activity

### API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/dashboard/overview` | GET | Get dashboard overview |
| `/api/dashboard/categories` | GET | Get category statistics |
| `/api/dashboard/panchayats` | GET | Get panchayat rankings |
| `/api/dashboard/trend` | GET | Get daily trend data |
| `/api/dashboard/recent` | GET | Get recent attestations |
| `/api/dashboard/export` | GET | Export dashboard data |

### Panchayat Efficiency Score
Calculated as: `(volumeScore * 0.5) + (speedScore * 0.5)`
- Volume Score: Based on issue resolution count (max 50 points)
- Speed Score: Based on average resolution time (max 50 points)

---

## 🏆 Reputation System

### Badge Types (Soulbound NFTs)
| Badge | Points Required | Description |
|-------|----------------|-------------|
| 🚀 Quick Resolver | - | Resolve issues within 24 hours |
| 🦸 Community Hero | - | Exceptional community service |
| ⭐ Consistency Star | - | Consistent monthly performance |
| 🎯 First Responder | - | First to respond to issues |
| 🏅 Milestone 100 | 100 | Reach 100 reputation points |
| 🎖️ Milestone 500 | 500 | Reach 500 reputation points |
| 🏆 Milestone 1000 | 1000 | Reach 1000 reputation points |
| 👑 Top Performer | - | Top 10 monthly ranking |
| 💡 Innovation Award | - | Innovative solutions |
| ❤️ Citizen Favorite | - | Highest citizen ratings |

### Point Values
| Action | Points |
|--------|--------|
| Issue Resolved | +10 |
| Quick Resolution (<24h) | +5 |
| First Responder | +2 |
| Positive Feedback | +3 |
| Community Event | +15 |
| Training Completed | +20 |
| Negative Feedback | -5 |

### Reputation Tiers
| Tier | Points Range | Color |
|------|-------------|-------|
| Newcomer | 0-49 | Gray |
| Active | 50-199 | Blue |
| Skilled | 200-499 | Green |
| Expert | 500-999 | Purple |
| Master | 1000-1999 | Orange |
| Legendary | 2000+ | Gold |

### API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/reputation/score/:address` | GET | Get reputation score |
| `/api/reputation/badges/:address` | GET | Get earned badges |
| `/api/reputation/leaderboard` | GET | Get top performers |
| `/api/reputation/points` | POST | Add reputation points |
| `/api/reputation/badge` | POST | Award badge |

---

## 📦 Batch Attestation Operations

### Features
- Create multiple attestations in single transaction
- Batch revocation support
- Referenced attestations (linked chains)
- Gas estimation for batch operations

### API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/batch/attest` | POST | Create batch attestations |
| `/api/batch/revoke` | POST | Revoke single attestation |
| `/api/batch/revoke-many` | POST | Batch revoke attestations |
| `/api/batch/referenced` | POST | Create referenced attestation |
| `/api/batch/chain/:uid` | GET | Get attestation chain |
| `/api/batch/full-workflow` | POST | Full attestation workflow |

---

## 🎨 Flutter UI Components

### New Screens
1. **Transparency Dashboard** (`/transparency-dashboard`)
   - Overview statistics cards
   - Blockchain network info
   - Daily trend chart
   - Category distribution
   - Panchayat rankings

2. **Governance Screen** (`/governance`)
   - Active proposals list
   - Create proposal dialog
   - Vote dialog with For/Against/Abstain
   - How-it-works information

3. **Leaderboard Screen** (`/leaderboard`)
   - Top performers ranking
   - Badge gallery with all badge types
   - Points earning guide
   - Officer profile details

### BLoC State Management
- `DashboardBloc` - Dashboard metrics state
- `GovernanceBloc` - Proposals and voting state
- `ReputationBloc` - Leaderboard and badges state

---

## 🔧 Configuration

### Environment Variables
```env
# PHASE 5 Additions
GOVERNOR_CONTRACT_ADDRESS=0x...
REPUTATION_TOKEN_ADDRESS=0x...

# Pinata IPFS (for metadata)
PINATA_API_KEY=your_key
PINATA_SECRET_KEY=your_secret
PINATA_JWT=your_jwt
```

### Backend Config
```javascript
blockchain: {
  chainId: 11155111,
  networkName: 'sepolia',
  rpcUrl: 'https://sepolia.infura.io/v3/...',
  explorerUrl: 'https://sepolia.etherscan.io',
  governorAddress: '0x...',
  reputationTokenAddress: '0x...'
}
```

---

## 📁 File Structure

```
backend/src/
├── services/
│   ├── governanceService.js      # DAO governance operations
│   ├── reputationService.js      # Reputation system
│   ├── dashboardService.js       # Transparency metrics
│   └── batchAttestationService.js # Batch operations
├── routes/
│   ├── governance.js             # Governance API routes
│   ├── reputation.js             # Reputation API routes
│   ├── dashboard.js              # Dashboard API routes
│   └── batch.js                  # Batch attestation routes

lib/
├── core/services/web3/
│   ├── governance_service.dart   # Governance client
│   ├── reputation_service.dart   # Reputation client
│   └── dashboard_service.dart    # Dashboard client
├── features/
│   ├── dashboard/presentation/
│   │   ├── screens/
│   │   │   └── transparency_dashboard_screen.dart
│   │   ├── widgets/
│   │   │   └── dashboard_widgets.dart
│   │   └── bloc/
│   │       └── dashboard_bloc.dart
│   ├── governance/presentation/
│   │   ├── screens/
│   │   │   └── governance_screen.dart
│   │   ├── widgets/
│   │   │   └── governance_widgets.dart
│   │   └── bloc/
│   │       └── governance_bloc.dart
│   └── reputation/presentation/
│       ├── screens/
│       │   └── leaderboard_screen.dart
│       ├── widgets/
│       │   └── reputation_widgets.dart
│       └── bloc/
│           └── reputation_bloc.dart
└── app/
    └── router.dart               # Updated with new routes
```

---

## 🚀 Usage Examples

### Creating a Proposal
```dart
context.read<GovernanceBloc>().add(
  CreateProposal(
    title: 'Allocate funds for road repair',
    description: 'Proposal to allocate ₹5,00,000 for main road repair',
    category: 'infrastructure',
    targets: ['0x...'],
    values: ['0'],
    calldatas: ['0x...'],
  ),
);
```

### Casting a Vote
```dart
context.read<GovernanceBloc>().add(
  CastVote(
    proposalId: proposalId,
    support: VoteType.for_,
    reason: 'This will benefit the community',
  ),
);
```

### Loading Leaderboard
```dart
context.read<ReputationBloc>().add(
  LoadLeaderboard(limit: 10),
);
```

---

## ✅ Completion Status

- [x] Backend governance service
- [x] Backend reputation service
- [x] Backend dashboard service
- [x] Backend batch attestation service
- [x] Backend governance routes
- [x] Backend reputation routes
- [x] Backend dashboard routes
- [x] Backend batch routes
- [x] Flutter governance service
- [x] Flutter reputation service
- [x] Flutter dashboard service
- [x] Transparency dashboard screen
- [x] Governance screen with voting
- [x] Leaderboard screen with badges
- [x] Router configuration
- [x] Documentation

---

## 📚 Smart Contracts (Reference)

### Governor Contract
Deploy an OpenZeppelin Governor contract with:
- Voting delay: 1 day
- Voting period: 1 week
- Proposal threshold: 1% of total supply
- Quorum: 4% of total supply

### Reputation Token (ERC-5192)
Deploy a Soulbound token contract for badges:
- Non-transferable
- Burnable by owner only
- Metadata stored on IPFS

---

## 🔗 Integration Points

### With Existing PHASE 1-4 Features
- Attestations trigger reputation points
- Issue resolution awards badges
- Dashboard shows attestation statistics
- Proposals can reference attestation UIDs

### Navigation
Add buttons/menu items in existing screens to access:
- `/transparency-dashboard` - From any dashboard
- `/governance` - From officer/admin screens
- `/leaderboard` - From any profile screen

---

## 📈 Future Enhancements

1. **PHASE 6 Options:**
   - Mobile wallet integration (WalletConnect)
   - Push notifications for votes
   - Multi-signature proposals
   - Delegation system
   - Token-gated features

2. **Analytics:**
   - Historical trend analysis
   - Predictive resolution times
   - Anomaly detection

3. **Gamification:**
   - Achievement system
   - Seasonal leaderboards
   - NFT rewards for milestones
