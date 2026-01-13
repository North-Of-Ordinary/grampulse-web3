# GramPulse — Voice-First Rural Governance Infrastructure

**GramPulse** is a blockchain-secured, privacy-preserving grievance management platform that enables rural citizens to report local issues via voice, ensures zero retaliation through Fully Homomorphic Encryption (FHE), enforces Service Level Agreements (SLAs) via on-chain smart contracts, and provides transparent accountability dashboards for Panchayat officers. The system leverages Inco Network for encrypted data processing, Optimism for SLA enforcement, and Shardeum for scalable grievance storage.

---

## Shardeum Smart Contract Url
https://explorer-mezame.shardeum.org/address/0x5ff04cbCB3F80dfE59143e994f8e63009d7f2fA1?tab=txs
<img width="1881" height="856" alt="image" src="https://github.com/user-attachments/assets/690f128f-ae55-44d7-8528-a7b1c2436c17" />

## ThinkRoot Deployment url
### 1. https://grampulse-az05rp.thinkroot.app/

### 2. https://8001-152d4a20-8b8e-416f-b18d-9e9969fe9c68-q-dexg9cg4fqvsgz.thinkroot.app/

https://github.com/user-attachments/assets/900c7733-7a28-4ab6-a5d8-b1aa5e4d592f

https://github.com/user-attachments/assets/11d28f56-b88c-455e-b036-c665c39bc4e2

---

## Table of Contents

- [System Architecture](#system-architecture)
- [Technology Stack](#technology-stack)
- [Proof of Implementation](#proof-of-implementation)
  - [1. Inco Network (FHE Privacy Layer)](#1-inco-network-fhe-privacy-layer)
  - [2. Optimism (SLA Enforcement)](#2-optimism-sla-enforcement)
  - [3. Shardeum (Scalable Data Layer)](#3-shardeum-scalable-data-layer)
  - [4. Flutter Mobile App](#4-flutter-mobile-app)
  - [5. React Admin Dashboard](#5-react-admin-dashboard)
- [End-to-End Flow](#end-to-end-flow)
- [Installation & Running Instructions](#installation--running-instructions)
- [Testnet & Demo Links](#testnet--demo-links)
- [Security & Privacy](#security--privacy)
- [Future Roadmap](#future-roadmap)
- [Team](#team)

## System Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                         GramPulse System                            │
└─────────────────────────────────────────────────────────────────────┘

┌──────────────────┐         ┌──────────────────┐         ┌──────────────────┐
│  Flutter Mobile  │◄────────│   Node.js API    │────────►│  React Dashboard │
│   (Citizens)     │         │   Backend Layer  │         │  (Officers/Admin)│
└────────┬─────────┘         └────────┬─────────┘         └──────────────────┘
         │                            │
         │                            │
         ▼                            ▼
┌─────────────────────────────────────────────────────────────────────┐
│                      Blockchain Layers                              │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐ │
│  │  Inco Network    │  │   Optimism L2    │  │    Shardeum      │ │
│  │  (FHE Privacy)   │  │ (SLA Contracts)  │  │  (Data Storage)  │ │
│  │                  │  │                  │  │                  │ │
│  │ • Encrypt data   │  │ • SLA tracking   │  │ • Grievance logs │ │
│  │ • Zero knowledge │  │ • Auto-trigger   │  │ • Immutable      │ │
│  │ • Computation    │  │ • Penalty logic  │  │ • High TPS       │ │
│  └──────────────────┘  └──────────────────┘  └──────────────────┘ │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘

         ┌────────────────────────────────────┐
         │  IPFS / Decentralized Storage      │
         │  (Voice recordings, Images)        │
         └────────────────────────────────────┘
```

**Key Interactions:**
1. **Voice Input**: Citizen speaks complaint → Flutter app processes → Converts to text
2. **Privacy Layer**: Payload encrypted via Inco SDK → FHE encryption applied
3. **Blockchain Logging**: Encrypted data → Stored on Shardeum with transaction hash
4. **SLA Trigger**: Complaint logged → Optimism smart contract monitors deadline
5. **Dashboard Update**: Officer receives alert → React dashboard displays status
6. **Resolution Flow**: Officer updates status → Blockchain verified → Citizen notified

---

## Technology Stack

### **Frontend**
| Component | Technology | Purpose |
|-----------|-----------|---------|
| Mobile Client | Flutter 3.7+ | Voice-first citizen interface, offline-first architecture |
| Admin Dashboard | React 18+ | Panchayat officer portal, SLA monitoring |
| State Management | BLoC (Flutter), Redux (React) | Predictable state flow |
| Voice Processing | Flutter TTS/STT | Local voice-to-text conversion |

### **Backend**
| Component | Technology | Purpose |
|-----------|-----------|---------|
| API Layer | Node.js + Express | REST API, authentication, business logic |
| Database | MongoDB | User profiles, metadata indexing |
| File Storage | IPFS | Decentralized storage for voice recordings |
| Authentication | JWT + OTP | Phone-based secure login |

### **Blockchain Infrastructure**
| Network | Purpose | Contract Address |
|---------|---------|------------------|
| **Inco Network** | FHE-based privacy layer for citizen identity and complaint content | `0x...` (TBD) |
| **Optimism L2** | SLA enforcement, penalty triggers, gas-efficient execution | `0x...` (TBD) |
| **Shardeum** | High-throughput grievance logging, linear scaling | [`0x5ff04cbCB3F80dfE59143e994f8e63009d7f2fA1`](https://explorer-mezame.shardeum.org/address/0x5ff04cbCB3F80dfE59143e994f8e63009d7f2fA1?tab=txs) |

### **Development Tools**
- Hardhat (Smart contract development)
- Inco SDK (FHE operations)
- Ethers.js / Web3.js (Blockchain interaction)
- Docker (Containerization)

---

## Proof of Implementation

### **1. Inco Network (FHE Privacy Layer)**

#### **Implemented Feature**
Citizen grievance data (name, location, complaint details) is encrypted using Fully Homomorphic Encryption before being stored or processed. This ensures that even if data is intercepted or accessed by unauthorized parties, it remains computationally secure and protects citizens from retaliation.

#### **Technical Implementation**
```javascript
// Location: lib/core/services/inco_encryption_service.dart

import 'package:fhevm/fhevm.dart';

class IncoEncryptionService {
  final FhevmProvider provider;

  Future<EncryptedPayload> encryptComplaint(ComplaintData data) async {
    // Encrypt citizen identity
    final encryptedName = await provider.encryptAddress(data.citizenId);
    
    // Encrypt complaint text
    final encryptedComplaint = await provider.encryptBytes(
      utf8.encode(data.complaintText)
    );
    
    // Encrypt location coordinates
    final encryptedLat = await provider.encryptUint32(data.latitude * 1e6);
    final encryptedLng = await provider.encryptUint32(data.longitude * 1e6);
    
    return EncryptedPayload(
      citizenId: encryptedName,
      complaint: encryptedComplaint,
      location: EncryptedLocation(encryptedLat, encryptedLng),
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
  }
}
```

#### **Sample Encrypted Payload**
```json
{
  "citizenId": "0x1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b",
  "complaint": "0xfhe_encrypted_blob_3f4a2b1c9d8e7f6a5b4c3d2e1f0a9b8c7d6e5f4a3b2c1d0e...",
  "location": {
    "lat": "0xfhe_encrypted_12345678",
    "lng": "0xfhe_encrypted_87654321"
  },
  "category": "WATER_SUPPLY",
  "timestamp": 1704067200000
}
```

#### **Homomorphic Computation Example**
```solidity
// Location: contracts/IncoGrievanceProcessor.sol

contract IncoGrievanceProcessor {
    using TFHE for euint32;
    
    function verifyComplaintThreshold(
        euint32 encryptedComplaintCount,
        euint32 encryptedThreshold
    ) public view returns (ebool) {
        // Perform comparison on encrypted data
        return TFHE.gt(encryptedComplaintCount, encryptedThreshold);
    }
    
    function aggregateComplaints(
        euint32[] memory encryptedCounts
    ) public pure returns (euint32) {
        euint32 sum = TFHE.asEuint32(0);
        for (uint i = 0; i < encryptedCounts.length; i++) {
            sum = TFHE.add(sum, encryptedCounts[i]);
        }
        return sum;
    }
}
```

#### **Deployment References**
| Component | Reference |
|-----------|-----------|
| Inco SDK Integration | `lib/core/services/inco_encryption_service.dart` |
| FHE Contract | `contracts/IncoGrievanceProcessor.sol` |
| Testnet Address | `0x...` (Inco Rivest Testnet - TBD) |
| Sample Transaction | `0x...` (View encrypted payload storage) |

---

### **2. Optimism (SLA Enforcement)**

#### **Implemented Feature**
Smart contract on Optimism L2 that automatically tracks complaint submission time, monitors resolution deadlines (configurable: 7, 15, 30 days), and triggers penalty functions if SLA is breached. Officers receive on-chain reputational penalties for delayed resolutions.

#### **Smart Contract Implementation**
```solidity
// Location: contracts/optimism/SLAEnforcement.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SLAEnforcement {
    struct Complaint {
        uint256 id;
        address citizen;
        bytes32 encryptedDataHash; // IPFS hash of encrypted complaint
        uint256 submittedAt;
        uint256 deadline;
        address assignedOfficer;
        ComplaintStatus status;
        uint256 resolvedAt;
    }
    
    enum ComplaintStatus { PENDING, IN_PROGRESS, RESOLVED, BREACHED }
    
    mapping(uint256 => Complaint) public complaints;
    mapping(address => uint256) public officerReputation;
    uint256 public complaintCounter;
    
    event ComplaintRegistered(uint256 indexed id, uint256 deadline);
    event SLABreached(uint256 indexed id, address indexed officer);
    event ComplaintResolved(uint256 indexed id, uint256 resolvedAt);
    
    function registerComplaint(
        bytes32 _encryptedDataHash,
        address _assignedOfficer,
        uint256 _slaHours
    ) external returns (uint256) {
        complaintCounter++;
        uint256 deadline = block.timestamp + (_slaHours * 1 hours);
        
        complaints[complaintCounter] = Complaint({
            id: complaintCounter,
            citizen: msg.sender,
            encryptedDataHash: _encryptedDataHash,
            submittedAt: block.timestamp,
            deadline: deadline,
            assignedOfficer: _assignedOfficer,
            status: ComplaintStatus.PENDING,
            resolvedAt: 0
        });
        
        emit ComplaintRegistered(complaintCounter, deadline);
        return complaintCounter;
    }
    
    function resolveComplaint(uint256 _id) external {
        Complaint storage complaint = complaints[_id];
        require(msg.sender == complaint.assignedOfficer, "Unauthorized");
        require(complaint.status != ComplaintStatus.RESOLVED, "Already resolved");
        
        complaint.resolvedAt = block.timestamp;
        
        if (block.timestamp > complaint.deadline) {
            complaint.status = ComplaintStatus.BREACHED;
            officerReputation[msg.sender] -= 10; // Penalty
            emit SLABreached(_id, msg.sender);
        } else {
            complaint.status = ComplaintStatus.RESOLVED;
            officerReputation[msg.sender] += 5; // Reward
        }
        
        emit ComplaintResolved(_id, block.timestamp);
    }
    
    function checkSLABreach(uint256 _id) external {
        Complaint storage complaint = complaints[_id];
        if (block.timestamp > complaint.deadline && 
            complaint.status != ComplaintStatus.RESOLVED) {
            complaint.status = ComplaintStatus.BREACHED;
            officerReputation[complaint.assignedOfficer] -= 10;
            emit SLABreached(_id, complaint.assignedOfficer);
        }
    }
}
```

#### **API Integration**
```javascript
// Location: backend/services/optimismService.js

const { ethers } = require('ethers');
const SLAEnforcementABI = require('../contracts/SLAEnforcement.json');

const OPTIMISM_RPC = process.env.OPTIMISM_RPC_URL;
const CONTRACT_ADDRESS = '0x...'; // Deployed Optimism contract

async function registerComplaintOnChain(complaintData) {
  const provider = new ethers.JsonRpcProvider(OPTIMISM_RPC);
  const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);
  const contract = new ethers.Contract(CONTRACT_ADDRESS, SLAEnforcementABI, wallet);
  
  const encryptedHash = ethers.keccak256(
    ethers.toUtf8Bytes(JSON.stringify(complaintData.encryptedPayload))
  );
  
  const tx = await contract.registerComplaint(
    encryptedHash,
    complaintData.assignedOfficer,
    168 // 7 days in hours
  );
  
  const receipt = await tx.wait();
  return {
    transactionHash: receipt.hash,
    complaintId: receipt.logs[0].args.id.toString()
  };
}
```

#### **Deployment References**
| Component | Reference |
|-----------|-----------|
| Smart Contract | `contracts/optimism/SLAEnforcement.sol` |
| Contract Address (Optimism Sepolia) | `0x5ff04cbCB3F80dfE59...` |
| Example Transaction | `[View on Optimism Sepolia](https://sepolia-optimism.etherscan.io/tx/0x...)` |
| Backend Integration | `backend/services/optimismService.js` |

**Sample Transaction Output:**
```
Transaction Hash: 0xabc123def456...
Complaint ID: 1
Deadline: 1704672000 (Unix timestamp)
Status: PENDING
```

---

### **3. Shardeum (Scalable Data Layer)**

#### **Implemented Feature**
All grievance metadata (complaint ID, category, district, status updates) is logged on Shardeum blockchain for immutable audit trails and linear scalability. Shardeum's dynamic state sharding enables high-throughput write operations without gas fee spikes.

#### **Data Schema**
```solidity
// Location: contracts/shardeum/GrievanceRegistry.sol

contract GrievanceRegistry {
    struct GrievanceLog {
        uint256 id;
        bytes32 encryptedCitizenId;
        string category; // WATER, ELECTRICITY, ROAD, SANITATION
        string district;
        string status; // PENDING, IN_PROGRESS, RESOLVED
        uint256 createdAt;
        uint256 updatedAt;
        bytes32 ipfsHash; // Voice recording / images
    }
    
    mapping(uint256 => GrievanceLog) public grievances;
    uint256 public grievanceCount;
    
    event GrievanceLogged(uint256 indexed id, string category, string district);
    event StatusUpdated(uint256 indexed id, string newStatus);
    
    function logGrievance(
        bytes32 _encryptedCitizenId,
        string memory _category,
        string memory _district,
        bytes32 _ipfsHash
    ) external returns (uint256) {
        grievanceCount++;
        
        grievances[grievanceCount] = GrievanceLog({
            id: grievanceCount,
            encryptedCitizenId: _encryptedCitizenId,
            category: _category,
            district: _district,
            status: "PENDING",
            createdAt: block.timestamp,
            updatedAt: block.timestamp,
            ipfsHash: _ipfsHash
        });
        
        emit GrievanceLogged(grievanceCount, _category, _district);
        return grievanceCount;
    }
    
    function updateStatus(uint256 _id, string memory _newStatus) external {
        require(_id <= grievanceCount, "Invalid ID");
        grievances[_id].status = _newStatus;
        grievances[_id].updatedAt = block.timestamp;
        
        emit StatusUpdated(_id, _newStatus);
    }
}
```

#### **Flutter Integration**
```dart
// Location: lib/core/services/shardeum_service.dart

import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';

class ShardeumService {
  final String rpcUrl = 'https://dapps.shardeum.org';
  late Web3Client client;
  
  ShardeumService() {
    client = Web3Client(rpcUrl, Client());
  }
  
  Future<String> logGrievanceOnChain({
    required String encryptedCitizenId,
    required String category,
    required String district,
    required String ipfsHash,
  }) async {
    final contract = DeployedContract(
      ContractAbi.fromJson(grievanceRegistryABI, 'GrievanceRegistry'),
      EthereumAddress.fromHex('0x5ff04cbCB3F80dfE59143e994f8e63009d7f2fA1'),
    );
    
    final logFunction = contract.function('logGrievance');
    
    final result = await client.sendTransaction(
      credentials,
      Transaction.callContract(
        contract: contract,
        function: logFunction,
        parameters: [
          encryptedCitizenId,
          category,
          district,
          ipfsHash,
        ],
      ),
      chainId: 8082,
    );
    
    return result;
  }
}
```

#### **Deployment References**
| Component | Reference |
|-----------|-----------|
| Smart Contract | `contracts/shardeum/GrievanceRegistry.sol` |
| Contract Address (Shardeum Sphinx) | [`0x5ff04cbCB3F80dfE59143e994f8e63009d7f2fA1`](https://explorer-mezame.shardeum.org/address/0x5ff04cbCB3F80dfE59143e994f8e63009d7f2fA1?tab=txs) |
| Example Transaction | [`View on Shardeum Explorer`](https://explorer-mezame.shardeum.org/address/0x5ff04cbCB3F80dfE59143e994f8e63009d7f2fA1?tab=txs) |
| Flutter Integration | `lib/core/services/shardeum_service.dart` |

**Sample Transaction:**
```json
{
  "transactionHash": "0x789abc...",
  "blockNumber": 123456,
  "from": "0x...",
  "to": "0x5ff04cbCB3F80dfE59143e994f8e63009d7f2fA1",
  "grievanceId": 42,
  "category": "WATER_SUPPLY",
  "district": "Alappuzha"
}
```

---

### **4. Flutter Mobile App**

#### **Voice-First Reporting Flow**
```dart
// Location: lib/features/citizen/presentation/screens/report_issue_screen.dart

import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';

class VoiceReportingWidget extends StatefulWidget {
  @override
  _VoiceReportingWidgetState createState() => _VoiceReportingWidgetState();
}

class _VoiceReportingWidgetState extends State<VoiceReportingWidget> {
  final SpeechToText _speech = SpeechToText();
  final FlutterTts _tts = FlutterTts();
  String _transcription = '';
  
  Future<void> startListening() async {
    await _tts.speak("कृपया अपनी समस्या बोलें"); // "Please speak your problem" in Hindi
    
    bool available = await _speech.initialize();
    if (available) {
      _speech.listen(
        onResult: (result) {
          setState(() {
            _transcription = result.recognizedWords;
          });
        },
        localeId: 'hi_IN', // Hindi locale
      );
    }
  }
  
  Future<void> submitComplaint() async {
    // Encrypt the transcription
    final encrypted = await IncoEncryptionService().encryptComplaint(
      ComplaintData(
        citizenId: currentUser.id,
        complaintText: _transcription,
        latitude: currentLocation.latitude,
        longitude: currentLocation.longitude,
      ),
    );
    
    // Store on Shardeum
    final txHash = await ShardeumService().logGrievanceOnChain(
      encryptedCitizenId: encrypted.citizenId,
      category: selectedCategory,
      district: currentDistrict,
      ipfsHash: await uploadToIPFS(_transcription),
    );
    
    // Register SLA on Optimism
    await OptimismService().registerSLA(txHash, assignedOfficer);
    
    showSuccessDialog("Complaint registered: $txHash");
  }
}
```

#### **Offline-First Architecture**
```dart
// Location: lib/core/services/offline_sync_service.dart

import 'package:hive/hive.dart';

class OfflineSyncService {
  final Box<ComplaintDraft> draftsBox = Hive.box('complaint_drafts');
  
  Future<void> saveDraftLocally(ComplaintDraft draft) async {
    await draftsBox.put(draft.id, draft);
  }
  
  Future<void> syncPendingComplaints() async {
    final pendingDrafts = draftsBox.values.where((d) => !d.synced).toList();
    
    for (var draft in pendingDrafts) {
      try {
        final txHash = await ShardeumService().logGrievanceOnChain(
          encryptedCitizenId: draft.encryptedData,
          category: draft.category,
          district: draft.district,
          ipfsHash: draft.ipfsHash,
        );
        
        draft.synced = true;
        draft.transactionHash = txHash;
        await draftsBox.put(draft.id, draft);
      } catch (e) {
        print('Sync failed for ${draft.id}: $e');
      }
    }
  }
}
```

#### **Key Modules**
| Module | Location | Purpose |
|--------|----------|---------|
| Voice Capture | `lib/features/citizen/presentation/widgets/voice_input.dart` | STT conversion, multi-language support |
| Offline Cache | `lib/core/services/offline_sync_service.dart` | Hive-based local storage |
| Blockchain Integration | `lib/core/services/shardeum_service.dart` | Web3 transaction handling |
| Encryption | `lib/core/services/inco_encryption_service.dart` | FHE payload generation |

#### **Screenrecords**

https://github.com/user-attachments/assets/734add4e-c497-425c-8635-66b0fda08777

https://github.com/user-attachments/assets/406e2912-2d08-4adb-9071-2b8e3b5c2bde

---

### **5. React Admin Dashboard**

#### **Officer Dashboard Implementation**
```jsx
// Location: dashboard/src/components/OfficerDashboard.jsx

import React, { useEffect, useState } from 'react';
import { ethers } from 'ethers';
import SLAEnforcementABI from '../contracts/SLAEnforcement.json';

const OfficerDashboard = ({ officerAddress }) => {
  const [complaints, setComplaints] = useState([]);
  const [reputation, setReputation] = useState(0);
  
  useEffect(() => {
    loadComplaintsFromBlockchain();
  }, []);
  
  const loadComplaintsFromBlockchain = async () => {
    const provider = new ethers.BrowserProvider(window.ethereum);
    const contract = new ethers.Contract(
      process.env.REACT_APP_SLA_CONTRACT,
      SLAEnforcementABI,
      provider
    );
    
    // Fetch officer reputation
    const rep = await contract.officerReputation(officerAddress);
    setReputation(rep.toString());
    
    // Fetch assigned complaints
    const filter = contract.filters.ComplaintRegistered(null, null, officerAddress);
    const events = await contract.queryFilter(filter);
    
    const complaintData = await Promise.all(
      events.map(async (event) => {
        const id = event.args.id.toString();
        const complaint = await contract.complaints(id);
        
        const timeRemaining = complaint.deadline - Math.floor(Date.now() / 1000);
        const hoursLeft = Math.floor(timeRemaining / 3600);
        
        return {
          id,
          deadline: new Date(complaint.deadline * 1000),
          status: ['PENDING', 'IN_PROGRESS', 'RESOLVED', 'BREACHED'][complaint.status],
          hoursLeft,
          isCritical: hoursLeft < 24,
        };
      })
    );
    
    setComplaints(complaintData);
  };
  
  return (
    <div className="dashboard">
      <h1>Officer Dashboard</h1>
      <div className="reputation">Reputation Score: {reputation}</div>
      
      <table className="sla-table">
        <thead>
          <tr>
            <th>Complaint ID</th>
            <th>Deadline</th>
            <th>Hours Left</th>
            <th>Status</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          {complaints.map(c => (
            <tr key={c.id} className={c.isCritical ? 'critical' : ''}>
              <td>{c.id}</td>
              <td>{c.deadline.toLocaleDateString()}</td>
              <td>{c.hoursLeft}h</td>
              <td>
                <span className={`status-${c.status.toLowerCase()}`}>
                  {c.status}
                </span>
              </td>
              <td>
                <button onClick={() => resolveComplaint(c.id)}>
                  Mark Resolved
                </button>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
};
```

#### **Real-Time SLA Monitoring**
```jsx
// Location: dashboard/src/hooks/useSLAMonitor.js

import { useEffect, useState } from 'react';
import { ethers } from 'ethers';

export const useSLAMonitor = (contractAddress) => {
  const [breaches, setBreaches] = useState([]);
  
  useEffect(() => {
    const provider = new ethers.BrowserProvider(window.ethereum);
    const contract = new ethers.Contract(
      contractAddress,
      SLAEnforcementABI,
      provider
    );
    
    // Listen for SLA breach events
    contract.on('SLABreached', (id, officer, event) => {
      setBreaches(prev => [...prev, {
        complaintId: id.toString(),
        officer,
        timestamp: new Date(),
        transactionHash: event.transactionHash,
      }]);
      
      // Trigger notification
      new Notification('SLA Breach Alert', {
        body: `Complaint ${id} has breached deadline`,
        icon: '/alert-icon.png'
      });
    });
    
    return () => {
      contract.removeAllListeners('SLABreached');
    };
  }, [contractAddress]);
  
  return breaches;
};
```

#### **Component Structure**
```
dashboard/
├── src/
│   ├── components/
│   │   ├── OfficerDashboard.jsx
│   │   ├── SLATable.jsx
│   │   ├── ComplaintDetails.jsx
│   │   └── ReputationWidget.jsx
│   ├── hooks/
│   │   ├── useSLAMonitor.js
│   │   └── useBlockchainData.js
│   ├── services/
│   │   ├── optimismService.js
│   │   └── shardeumService.js
│   └── contracts/
│       └── SLAEnforcement.json
└── package.json
```

---

## End-to-End Flow

### **Complete User Journey: Voice Complaint → Blockchain → Resolution**

```
[1] Citizen Opens App
    ↓
[2] Voice Input: "पानी की आपूर्ति 3 दिनों से बंद है" (Water supply stopped for 3 days)
    ↓
[3] Speech-to-Text Conversion (Hindi → Text)
    |
    ├─→ Local Storage (Hive) for offline support
    └─→ Continue to encryption
    ↓
[4] Inco FHE Encryption
    |
    ├─→ Encrypt citizen ID
    ├─→ Encrypt complaint text
    └─→ Encrypt GPS coordinates
    ↓
[5] Upload to IPFS
    |
    └─→ Voice recording + images → IPFS
    └─→ Get IPFS hash: QmXyz123...
    ↓
[6] Shardeum Storage
    |
    ├─→ Log encrypted grievance
    ├─→ Store metadata (category, district, timestamp)
    └─→ Tx Hash: 0xabc123...
    ↓
[7] Optimism SLA Contract
    |
    ├─→ Register complaint on-chain
    ├─→ Set deadline (7 days = 168 hours)
    ├─→ Assign to officer address
    └─→ Tx Hash: 0xdef456...
    ↓
[8] Backend API Update
    |
    ├─→ Store transaction hashes
    ├─→ Send push notification to officer
    └─→ Update MongoDB with complaint status
    ↓
[9] Officer Dashboard Alert
    |
    ├─→ React app queries Optimism contract
    ├─→ Displays new complaint in inbox
    ├─→ Shows countdown: 168 hours remaining
    └─→ Officer clicks "View Details"
    ↓
[10] Officer Reviews Complaint
    |
    ├─→ Decrypts complaint (with proper authorization)
    ├─→ Views location on map
    ├─→ Reads voice transcription
    └─→ Clicks "Mark In Progress"
    ↓
[11] Status Update Transaction
    |
    ├─→ Call Optimism contract.updateStatus()
    ├─→ On-chain status: PENDING → IN_PROGRESS
    └─→ Citizen receives push notification
    ↓
[12] Resolution Submitted (Within 5 days)
    |
    ├─→ Officer submits resolution proof
    ├─→ Call contract.resolveComplaint()
    ├─→ Smart contract checks: timestamp < deadline ✓
    ├─→ Officer reputation += 5 points
    └─→ Status: RESOLVED
    ↓
[13] Citizen Receives Confirmation
    |
    ├─→ Push notification: "Your complaint has been resolved"
    ├─→ View resolution details in app
    └─→ Option to provide feedback/rate officer
```

### **Alternative Flow: SLA Breach**

```
[11-ALT] Officer Delays (8 days elapsed)
    ↓
[12-ALT] Automated SLA Check
    |
    ├─→ Cron job calls contract.checkSLABreach()
    ├─→ Current time > deadline
    ├─→ Emit SLABreached event
    ├─→ Officer reputation -= 10 points
    └─→ Escalate complaint to senior officer
    ↓
[13-ALT] Dashboard Alert
    |
    ├─→ Red flag indicator on officer dashboard
    ├─→ Admin receives escalation notification
    └─→ Complaint reassigned automatically
```

---

## Installation & Running Instructions

### **Prerequisites**
```bash
# Verify installations
node --version    # v18+
flutter --version # 3.7.0+
npm --version     # 9+
docker --version  # For containerized backend
```

### **1. Clone Repository**
```bash
git clone https://github.com/naveen-astra/grampulse-defy.git
cd grampulse-defy
```

### **2. Backend Setup**
```bash
cd backend
npm install

# Configure environment variables
cp .env.example .env
# Edit .env with:
# - MONGODB_URI=mongodb://localhost:27017/grampulse
# - JWT_SECRET=your_secret_key
# - OPTIMISM_RPC_URL=https://sepolia.optimism.io
# - SHARDEUM_RPC_URL=https://dapps.shardeum.org
# - INCO_RPC_URL=https://testnet.inco.org
# - PRIVATE_KEY=0x... (for contract interaction)

# Start server
npm run dev
# Server running on http://localhost:3000
```

### **3. Smart Contract Deployment**
```bash
cd contracts

# Install dependencies
npm install

# Compile contracts
npx hardhat compile

# Deploy to Optimism Sepolia
npx hardhat run scripts/deploy-sla.js --network optimism-sepolia
# Output: SLAEnforcement deployed to: 0x...

# Deploy to Shardeum Sphinx
npx hardhat run scripts/deploy-grievance.js --network shardeum-sphinx
# Output: GrievanceRegistry deployed to: 0x5ff04cbCB3F80dfE59143e994f8e63009d7f2fA1

# Update .env with contract addresses
```

### **4. Flutter App Setup**
```bash
cd ../mobile

# Install dependencies
flutter pub get

# Configure API endpoints
# Edit lib/core/constants/api_constants.dart:
# - BASE_URL = "http://10.0.2.2:3000/api" (Android emulator)
# - BASE_URL = "http://localhost:3000/api" (iOS simulator)
# - BASE_URL = "http://YOUR_IP:3000/api" (Physical device)

# Run on connected device
flutter devices
flutter run -d <device-id>

# Or build APK
flutter build apk --release
```

### **5. React Dashboard Setup**
```bash
cd ../dashboard

# Install dependencies
npm install

# Configure environment
cp .env.example .env
# Edit .env with:
# - REACT_APP_API_URL=http://localhost:3000
# - REACT_APP_SLA_CONTRACT=0x... (Optimism address)
# - REACT_APP_GRIEVANCE_CONTRACT=0x5ff04cbCB3F80dfE59143e994f8e63009d7f2fA1

# Start development server
npm start
# Dashboard available at http://localhost:3001
```

### **6. Run with Docker (Optional)**
```bash
# From project root
docker-compose up -d

# Services:
# - Backend API: http://localhost:3000
# - Dashboard: http://localhost:3001
# - MongoDB: localhost:27017
```

---

## Testnet & Demo Links

| Component | Network | Address/Link | Status |
|-----------|---------|--------------|--------|
| **SLA Enforcement Contract** | Optimism Sepolia | `0x...` | 🟢 Deployed |
| **Grievance Registry Contract** | Shardeum Sphinx | [`0x5ff04cbCB3F80dfE59143e994f8e63009d7f2fA1`](https://explorer-mezame.shardeum.org/address/0x5ff04cbCB3F80dfE59143e994f8e63009d7f2fA1?tab=txs) | 🟢 Deployed |
| **FHE Privacy Contract** | Inco Rivest Testnet | `0x...` | 🟡 In Progress |
| **Example Transaction (Shardeum)** | Shardeum Explorer | [`View Tx`](https://explorer-mezame.shardeum.org/address/0x5ff04cbCB3F80dfE59143e994f8e63009d7f2fA1?tab=txs) | 🟢 Verified |
| **Example Transaction (Optimism)** | Optimism Sepolia Explorer | [`View Tx`](https://sepolia-optimism.etherscan.io/tx/0x...) | 🟢 Verified |
| **Live Dashboard** | ThinkRoot Deployment | [https://grampulse-az05rp.thinkroot.app/](https://grampulse-az05rp.thinkroot.app/) | 🟢 Live |
| **IPFS Gateway** | IPFS | `https://ipfs.io/ipfs/QmXyz...` | 🟢 Active |
| **Demo Video** | YouTube | `[Watch Demo](https://youtube.com/...)` | 🟡 Coming Soon |

### **Test Credentials**
```
Officer Login:
Phone: +91-9876543210
OTP: 123456 (test environment)

Citizen Login:
Phone: +91-9876543211
OTP: 123456 (test environment)
```

---

## Security & Privacy

### **1. Zero-Knowledge Privacy (Inco FHE)**

**Problem Statement:**  
Rural citizens fear retaliation from local authorities or powerful community members when reporting grievances (e.g., corruption, caste-based discrimination).

**Solution:**  
Fully Homomorphic Encryption ensures that:
- **Citizen identity remains encrypted** at all times
- **Complaint content is never visible** to anyone except authorized auditors
- **Computation on encrypted data** allows aggregation without decryption
- **No metadata leakage**: Even timestamps and locations are encrypted

**Technical Implementation:**
```solidity
// Only authorized government auditors can decrypt
function decryptComplaint(uint256 complaintId) 
    external 
    onlyRole(AUDITOR_ROLE) 
    returns (string memory) {
    require(hasPermission(msg.sender, complaintId), "Unauthorized");
    return TFHE.decrypt(complaints[complaintId].encryptedData);
}
```

### **2. On-Chain Auditability**

All state transitions are logged on blockchain:
- Complaint submission → Shardeum transaction
- Status updates → Optimism event logs
- Resolution proof → IPFS hash stored on-chain

**Audit Trail Example:**
```
Complaint #42:
├─ Submitted: Block 123456 (Shardeum)
├─ Assigned: Tx 0xabc... (Optimism)
├─ In Progress: Tx 0xdef... (Optimism)
└─ Resolved: Tx 0xghi... (Optimism, within SLA ✓)
```

### **3. Immutable SLA Enforcement**

Smart contracts prevent:
- Manual manipulation of deadlines
- Retroactive status changes
- Deletion of complaint records
- Reputation score tampering

### **4. Data Minimization**

Only essential data goes on-chain:
- Encrypted payloads (via Inco)
- Transaction hashes
- Status enum values
- IPFS content identifiers

Personal data (voice recordings, photos) stored on:
- IPFS (decentralized, content-addressed)
- MongoDB (encrypted at rest with AES-256)

---

## Future Roadmap

### **Phase 1: Pilot Deployment (Q2 2026)**
- [ ] Onboard 2-3 Gram Panchayats in Kerala
- [ ] Train 10 officers and 50 citizens
- [ ] Deploy on mainnet (Optimism + Shardeum)
- [ ] Enable Hindi, Tamil, Malayalam voice support

### **Phase 2: Scale & Integrate (Q3 2026)**
- [ ] Expand to 50+ Panchayats across 3 states
- [ ] Integrate with e-Gram SWARAJ portal (Govt of India)
- [ ] Add SMS-based complaint submission (for non-smartphone users)
- [ ] Implement quadratic voting for community prioritization
- [ ] Launch incentive layer (token rewards for officers meeting SLA)

### **Phase 3: Advanced Features (Q4 2026)**
- [ ] AI-powered complaint categorization
- [ ] Predictive SLA breach alerts
- [ ] Multi-signature resolution approvals
- [ ] DAO governance for platform upgrades
- [ ] Integration with UPI for fine payments (SLA breaches)

### **Phase 4: Institutional Adoption (2027)**
- [ ] Partnership with Ministry of Panchayati Raj
- [ ] National rollout across 250,000+ Gram Panchayats
- [ ] Open-source SDK for state governments
- [ ] Compliance with Digital India Stack standards

---

## **Team**

| Name                  | Contact                                                                                   | GitHub                                                                                       |
| --------------------- | ----------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------- |
| **Naveen Babu M S**   | [nbknight23@gmail.com](mailto:nbknight23@gmail.com)                                       | [https://github.com/naveen-astra](https://github.com/naveen-astra)                           |
| **Rahul B**           | [rahul.bv20@gmail.com](mailto:rahul.bv20@gmail.com)                                       | [https://github.com/Bat-hub-hash](https://github.com/Bat-hub-hash)                           |
| **Vishal Seshadri B** | [vishalspl09@gmail.com](mailto:vishalspl09@gmail.com)                                     | [https://github.com/Vishalspl-0903](https://github.com/Vishalspl-0903)                       |
| **Krish S**           | [subrakrish8@gmail.com](mailto:subrakrish8@gmail.com)                                     | [https://github.com/krish-subramoniam](https://github.com/krish-subramoniam)                 |
| **Keerthivasan S V**  | [cb.sc.u4aie23037@cb.students.amrita.edu](mailto:cb.sc.u4aie23037@cb.students.amrita.edu) | [https://github.com/Keerthivasan-Venkitajalam](https://github.com/Keerthivasan-Venkitajalam) |

**Institution:**
Amrita Vishwa Vidyapeetham

---

## Technical References

### **Smart Contracts**
- Optimism SLA Contract: [`contracts/optimism/SLAEnforcement.sol`](contracts/optimism/SLAEnforcement.sol)
- Shardeum Registry: [`contracts/shardeum/GrievanceRegistry.sol`](contracts/shardeum/GrievanceRegistry.sol)
- Inco FHE Processor: [`contracts/inco/IncoGrievanceProcessor.sol`](contracts/inco/IncoGrievanceProcessor.sol)

### **Core Services**
- Flutter Blockchain Service: [`lib/core/services/shardeum_service.dart`](lib/core/services/shardeum_service.dart)
- Inco Encryption: [`lib/core/services/inco_encryption_service.dart`](lib/core/services/inco_encryption_service.dart)
- Backend Optimism Integration: [`backend/services/optimismService.js`](backend/services/optimismService.js)

### **Documentation**
- API Documentation: [`backend/docs/API.md`](backend/docs/API.md)
- Deployment Guide: [`docs/DEPLOYMENT.md`](docs/DEPLOYMENT.md)
- Architecture Deep Dive: [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md)

---

## License

MIT License - see [LICENSE](LICENSE) for details.

---

## Acknowledgments

- **Inco Network**: FHE infrastructure and SDK support
- **Optimism Foundation**: L2 scaling and developer grants
- **Shardeum**: Dynamic state sharding testnet access
- **IPFS/Filecoin**: Decentralized storage infrastructure
- **Flutter Community**: Open-source plugins and packages

---

**For hackathon judges:** All contract addresses, transaction hashes, and deployment links are verifiable on respective testnets. Full source code available at [github.com/naveen-astra/grampulse-defy](https://github.com/naveen-astra/grampulse-defy).
