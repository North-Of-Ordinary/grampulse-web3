# GramPulse Attestation Backend

Backend attestation middleware for the GramPulse DeGov application. This service handles blockchain attestations using the Ethereum Attestation Service (EAS) on Optimism.

## Overview

GramPulse uses on-chain attestations to create verifiable, tamper-proof records of:
- **Grievance Resolutions**: When an officer/volunteer resolves a citizen complaint
- **Reputation Points**: Contributions to village welfare (Phase 5)
- **Village Sustainability Index (VSI)**: Monthly village health scores (Phase 6)

## Architecture

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│  Flutter App    │────▶│  Attestation    │────▶│   Optimism      │
│  (Firebase)     │     │  Backend        │     │   (EAS)         │
└─────────────────┘     └─────────────────┘     └─────────────────┘
        │                       │                       │
        │                       │                       │
        ▼                       ▼                       ▼
   Offline-first          API Key Auth           On-chain record
   Local storage          Rate limiting          Permanent, public
```

## Prerequisites

- Node.js 18+
- npm or yarn
- Ethereum wallet with ETH on Optimism (for attestation gas fees)
- EAS Schema UID (for resolution attestations)

## Quick Start

1. **Clone and install dependencies:**
   ```bash
   cd backend
   npm install
   ```

2. **Configure environment:**
   ```bash
   cp .env.example .env
   # Edit .env with your values
   ```

3. **Start the server:**
   ```bash
   # Development (with hot reload)
   npm run dev

   # Production
   npm start
   ```

## Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `PORT` | Server port | No (default: 3001) |
| `NODE_ENV` | Environment (development/production) | No |
| `NETWORK` | Blockchain network (optimism-mainnet/optimism-sepolia) | Yes |
| `RPC_URL` | Optimism RPC endpoint | Yes |
| `ATTESTER_PRIVATE_KEY` | Private key for signing attestations | Yes |
| `EAS_CONTRACT_ADDRESS` | EAS contract address | Yes |
| `SCHEMA_REGISTRY_ADDRESS` | Schema registry address | Yes |
| `RESOLUTION_SCHEMA_UID` | Pre-registered schema UID | Yes |
| `API_KEY` | API key for authentication | Yes |
| `ALLOWED_ORIGINS` | CORS allowed origins | No |
| `RATE_LIMIT_RPM` | Requests per minute limit | No (default: 30) |

## API Endpoints

### Health Check

```http
GET /health
```

Returns service health status and configuration.

### Create Resolution Attestation

```http
POST /attest/resolution
Content-Type: application/json
x-api-key: <your-api-key>

{
  "grievanceId": "firebase-doc-id",
  "villageId": "village-123",
  "resolverRole": "officer",
  "ipfsHash": "QmXxx..." (optional)
}
```

**Response:**
```json
{
  "success": true,
  "requestId": "uuid",
  "data": {
    "attestationUid": "0x...",
    "transactionHash": "0x...",
    "timestamp": 1704067200,
    "explorerUrl": "https://optimistic.etherscan.io/tx/0x..."
  }
}
```

### Verify Attestation

```http
GET /verify/:uid
```

**Response:**
```json
{
  "valid": true,
  "attestation": {
    "uid": "0x...",
    "schema": "0x...",
    "attester": "0x...",
    "timestamp": 1704067200,
    "data": {
      "grievanceId": "firebase-doc-id",
      "villageId": "village-123",
      "resolverRole": "officer",
      "ipfsHash": "QmXxx...",
      "resolutionTimestamp": 1704067200
    }
  }
}
```

## Resolution Schema

The resolution attestation schema is:

```solidity
string grievanceId,
string villageId,
string resolverRole,
string ipfsHash,
uint256 resolutionTimestamp
```

This schema is registered on EAS and referenced by its UID in the configuration.

## Registering a New Schema

If you need to register the resolution schema on a new network:

1. Visit [EAS Schema Registry](https://optimism.easscan.org/schema/create)
2. Enter the schema: `string grievanceId,string villageId,string resolverRole,string ipfsHash,uint256 resolutionTimestamp`
3. Set resolver to `0x0000000000000000000000000000000000000000`
4. Mark as revocable
5. Copy the resulting Schema UID to your `.env`

## Security Considerations

1. **Private Key Security**: Never commit your `.env` file. Use secret management in production.
2. **API Key Rotation**: Rotate API keys periodically.
3. **Rate Limiting**: Default 30 req/min. Adjust based on your needs.
4. **CORS**: Configure `ALLOWED_ORIGINS` for your production domains.

## Gas Costs

Each attestation costs gas on Optimism:
- Resolution attestation: ~50,000-100,000 gas
- At current Optimism gas prices, this is typically < $0.01 per attestation

Ensure your attester wallet maintains sufficient ETH for gas fees.

## Integration with Flutter

The Flutter app calls this backend to create attestations:

```dart
// In Web3Service
Future<String> createResolutionAttestation({
  required String grievanceId,
  required String villageId,
  required String resolverRole,
  String? ipfsHash,
}) async {
  final response = await http.post(
    Uri.parse('$attestationServiceUrl/attest/resolution'),
    headers: {
      'Content-Type': 'application/json',
      'x-api-key': apiKey,
    },
    body: jsonEncode({
      'grievanceId': grievanceId,
      'villageId': villageId,
      'resolverRole': resolverRole,
      'ipfsHash': ipfsHash,
    }),
  );
  
  final data = jsonDecode(response.body);
  return data['data']['attestationUid'];
}
```

## Deployment

### Docker (Recommended)

```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
EXPOSE 3001
CMD ["npm", "start"]
```

### Cloud Run / Fly.io

See deployment guides in `/docs` folder (coming soon).

## Monitoring

The service logs to:
- Console (development)
- `logs/error.log` (production errors)
- `logs/combined.log` (all production logs)

## Future Phases

- **Phase 5**: Reputation attestations (civic contribution points)
- **Phase 6**: Village Sustainability Index (VSI) attestations

## Contributing

See [CONTRIBUTING.md](../CONTRIBUTING.md) for guidelines.

## License

MIT License - See [LICENSE](../LICENSE) for details.
