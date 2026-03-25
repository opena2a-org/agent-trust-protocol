> **[OpenA2A](https://github.com/opena2a-org/opena2a)**: [CLI](https://github.com/opena2a-org/opena2a) · [HackMyAgent](https://github.com/opena2a-org/hackmyagent) · [Secretless](https://github.com/opena2a-org/secretless-ai) · [AIM](https://github.com/opena2a-org/agent-identity-management) · [Browser Guard](https://github.com/opena2a-org/AI-BrowserGuard) · [DVAA](https://github.com/opena2a-org/damn-vulnerable-ai-agent)
# Agent Trust Protocol (ATP)

An open standard for verifiable trust assertions about AI agents.

ATP enables any party to answer "Should I trust this agent?" with a cryptographically verifiable, auditable, and decentralized response.

## Quick Start

```bash
# Query an agent's trust
curl "https://api.oa2a.org/api/v1/trust/proof?did=did:atp:mcp_server:@modelcontextprotocol/server-filesystem"

# Verify a trust proof
curl -X POST https://api.oa2a.org/api/v1/trust/verify \
  -H "Content-Type: application/json" \
  -d @proof.json

# Discover a trust authority
curl https://api.oa2a.org/.well-known/atp
```

## Specification

[ATP-SPEC.md](ATP-SPEC.md) — the full protocol specification.

## Conformance Levels

| Level | Name | What It Means |
|-------|------|---------------|
| 1 | Basic Trust | DID + signed proofs. Single authority. |
| 2 | Auditable Trust | + transparency log. Tamper-evident. |
| 3 | Decentralized Trust | + federation consensus. Multi-authority. |

## Interoperability

ATP is designed to complement:
- [Google A2A Protocol](https://github.com/google/A2A) — trust proof in agent cards
- [SLSA](https://slsa.dev) — provenance level factors into trust score
- [Sigstore](https://sigstore.dev) — keyless co-signing of trust proofs
- [Certificate Transparency (RFC 6962)](https://datatracker.ietf.org/doc/html/rfc6962) — compatible log structure
- [W3C DID Core](https://www.w3.org/TR/did-core/) — agent identifiers

## Reference Implementation

The [OpenA2A Registry](https://github.com/opena2a-org/opena2a-registry) implements ATP at Level 2.

## Related Standards

- [AIP (Agent Identity Protocol)](https://github.com/opena2a-org/agent-identity-protocol) — identity + capabilities
- [OASB (Open Agent Security Benchmark)](https://github.com/opena2a-org/oasb) — security controls

## License

Apache-2.0
