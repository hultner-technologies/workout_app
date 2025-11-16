# Architecture Decision Record: MCP Server Hosting Platform

**Status**: Proposed
**Date**: 2025-11-15
**Decision Makers**: Team
**Related Epic**: EPIC_mcp_integration.md

## Context

We need to host a FastMCP (Python) server that:
1. Connects to Supabase (PostgreSQL) for data access
2. Supports both STDIO (local) and HTTP (remote) transports
3. Implements OAuth 2.1 authentication
4. **Must be permanently free** (side project, spare time development)
5. **Low maintenance** (solo developer working in spare time)
6. Avoids vendor lock-in
7. Provides reasonable performance (<2s p95 latency)

### Project Context

This is a side project with a solo developer working in spare time. The database was previously hosted on Fly.io for ~2 years successfully before migrating to Supabase (IPv4 charges made phone connectivity complex). The hosting solution must be:
- Permanently free (not time-limited credits)
- Low maintenance
- Reliable for personal use

### Critical Constraint: Pyodide Limitations

**Research Finding**: Cloudflare Workers use Pyodide (Python via WebAssembly) which **cannot** use native PostgreSQL drivers (psycopg2, asyncpg, pg8000).

**Root Cause**: Pyodide runs in WebAssembly and lacks TCP socket support required by native database drivers.

**Workaround**: Use HTTP-based database access (Supabase REST API / PostgREST).

**Implication**: Any Pyodide-based hosting requires REST API, which adds:
- Latency (HTTP overhead vs native protocol)
- Complexity (JSON serialization, auth headers)
- Limited query capabilities (vs raw SQL)

## Hosting Platform Comparison

### Technical Capabilities

| Platform | Python Support | DB Access | Free Tier | Vendor Lock-In | Setup Complexity |
|----------|---------------|-----------|-----------|----------------|------------------|
| **Cloudflare Workers** | Pyodide (limited) | REST API only | 100k req/day | Low | Medium |
| **Railway** | Native | Native drivers | $5 credit/mo | Low | Low |
| **Fly.io** | Native | Native drivers | 3 VMs free | Low | Medium |
| **Render** | Native | Native drivers | 750 hrs/mo | Low | Low |
| **Vercel** | Native | Native drivers | 100 GB-hrs/mo | Medium | Low |
| **AWS Lambda** | Native | Native drivers | 1M req/mo | High | High |
| **Self-hosted VPS** | Native | Native drivers | ~$5/mo | None | High |

### Free Tier Volume Estimates

**Assumptions**:
- Average MCP request: 2 DB queries (e.g., auth + data fetch)
- Average response size: 10 KB
- User session: 10-20 requests (one conversation)
- Active users per day: 10-50

| Platform | Requests/Month | Users/Day (est) | Notes |
|----------|----------------|-----------------|-------|
| **Cloudflare Workers** | ~3M (100k/day) | 150-300 | Most generous, but REST API only |
| **Railway** | ~10k* | 30-60 | $5 credit = ~1 month then paid |
| **Fly.io** | ~100k* | 50-100 | 3 shared VMs, good for dev |
| **Render** | ~2M* | 100-200 | 750 hrs = always-on free tier |
| **Vercel** | ~400k* | 200-400 | Good for serverless functions |
| **AWS Lambda** | 1M | 500-1000 | Generous but complex billing |

_* Estimates based on compute time, not just request count_

### Performance Comparison

**Latency Estimates** (p50):

| Platform | Cold Start | Warm Request | DB Query (Native) | DB Query (REST API) |
|----------|-----------|--------------|-------------------|---------------------|
| Cloudflare Workers | 5-50ms | 1-10ms | N/A | 50-150ms |
| Railway | 0ms (always-on) | 10-50ms | 5-20ms | 50-150ms |
| Fly.io | 50-200ms | 10-50ms | 5-20ms | 50-150ms |
| Render | 0ms (always-on) | 10-50ms | 5-20ms | 50-150ms |
| Vercel | 100-500ms | 50-150ms | 10-30ms | 50-150ms |

**Key Insight**: REST API adds 50-150ms regardless of platform. Native drivers are 5-20ms.

### Cost After Free Tier

| Platform | Free → Paid | Cost Model | Est. Cost (1000 users) |
|----------|-------------|------------|------------------------|
| Cloudflare Workers | 100k req/day | $0.50/M req | $15-30/mo |
| Railway | $5 credit | $0.000231/GB-sec | $10-20/mo |
| Fly.io | 3 VMs | $1.94/VM/mo | $6-12/mo |
| Render | 750 hrs | $7/mo per instance | $7/mo |
| Vercel | 100 GB-hrs | $20/mo team plan | $20/mo |

## Decision Criteria

### Must Have
1. ✅ Python 3.10+ support
2. ✅ HTTP/HTTPS support for MCP
3. ✅ Environment variables for secrets
4. ✅ Free tier for development/low usage
5. ✅ PostgreSQL/Supabase connectivity

### Should Have
1. Native PostgreSQL drivers (not just REST API)
2. Low cold start latency (<500ms)
3. Simple deployment (minimal DevOps)
4. Easy migration path (avoid lock-in)
5. Good documentation

### Nice to Have
1. Built-in rate limiting
2. Automatic scaling
3. Logging/monitoring
4. Multi-region deployment
5. WebSocket support

## Analysis

### Option 1: Cloudflare Workers (Pyodide)

**Pros**:
- ✅ Most generous free tier (100k req/day)
- ✅ Excellent global latency (edge compute)
- ✅ Fast cold starts (5-50ms)
- ✅ Built-in rate limiting
- ✅ Simple deployment (`wrangler deploy`)
- ✅ Low vendor lock-in (FastMCP is portable)

**Cons**:
- ❌ **Pyodide = REST API only** (no native drivers)
- ❌ Limited Python stdlib
- ❌ Cannot use many Python packages
- ❌ Higher per-request DB latency (REST overhead)
- ❌ Debugging is harder (WebAssembly)
- ❌ Complex migration (need alternative for native drivers)

**Verdict**: Good for pure compute, problematic for database-heavy workloads.

### Option 2: Railway

**Pros**:
- ✅ Native Python (no Pyodide)
- ✅ Native PostgreSQL drivers (asyncpg, psycopg2)
- ✅ Simple deployment (`railway up`)
- ✅ Always-on (no cold starts)
- ✅ Built-in logging/monitoring
- ✅ Easy migration (standard Python)

**Cons**:
- ⚠️ Free tier is time-limited ($5 credit)
- ⚠️ Becomes paid after ~1 month
- ⚠️ More expensive at scale vs Cloudflare

**Verdict**: Excellent developer experience, but not truly free long-term.

### Option 3: Fly.io

**Pros**:
- ✅ Native Python
- ✅ Native PostgreSQL drivers
- ✅ 3 free VMs (permanent free tier)
- ✅ Good performance
- ✅ Multi-region support
- ✅ Easy migration (Docker-based)

**Cons**:
- ⚠️ More complex setup (Dockerfile required)
- ⚠️ Slower cold starts (50-200ms)
- ⚠️ Shared VMs (resource contention)

**Verdict**: Good balance of free tier and native drivers.

### Option 4: Render

**Pros**:
- ✅ Native Python
- ✅ Native PostgreSQL drivers
- ✅ 750 hours/month free (permanent)
- ✅ Simple deployment (Git push)
- ✅ Always-on (no cold starts)
- ✅ Good documentation

**Cons**:
- ⚠️ 750 hrs ≈ always-on for 1 month, then needs multiple instances
- ⚠️ Free tier limited to 512MB RAM
- ⚠️ Slower than edge compute

**Verdict**: Great for getting started, outgrows free tier quickly.

### Option 5: Self-Hosted VPS

**Pros**:
- ✅ Complete control
- ✅ No vendor lock-in
- ✅ Native everything
- ✅ Predictable costs ($5-10/mo)

**Cons**:
- ❌ Manual management (security, updates)
- ❌ No auto-scaling
- ❌ Higher ops burden
- ❌ Single region (higher latency)

**Verdict**: Good for mature product, too much work for MVP.

## Recommendation

### Phase 1 (MVP): Local STDIO Only
- **Hosting**: None (runs locally)
- **Why**: Fast development, no deployment complexity
- **Cost**: $0
- **Limitation**: Only works on user's machine

### Phase 2 (Beta/Production): Fly.io

**Primary Recommendation: Fly.io**

**Why**:
1. **Permanent free tier** (3 shared VMs - no time limit, no credit expiration)
2. Native PostgreSQL drivers (5-20ms latency vs 50-150ms REST API)
3. Proven reliability (user ran database here for ~2 years successfully)
4. Low maintenance (Docker-based, simple deployment)
5. Easy to migrate away (standard Python + Docker)
6. Good for side projects (no surprise billing)

**Deployment**:
```bash
# Initial setup
fly launch

# Deploy
fly deploy

# Scale to 3 free VMs
fly scale count 3
```

**Free Tier Limits**:
- 3 shared-CPU VMs (always free)
- ~100k requests/month estimated capacity
- Sufficient for personal/side project use
- No IPv4 needed for HTTP-only MCP server

**Alternative (if need more resources later)**:

If traffic exceeds Fly.io free tier capabilities (~100k req/month):
- Cloudflare Workers ($15-30/mo) - accepts REST API latency trade-off for scale
- OR paid Fly.io ($6-12/mo for 3 dedicated VMs)
- OR Railway ($10-20/mo)

### Long-term Scaling

**Personal use** (<10 users): Fly.io free tier is sufficient indefinitely

**If project grows** (>100 users):
- Start with Fly.io free tier
- Monitor usage and performance
- Scale up only when necessary
- Consider Cloudflare Workers if REST API latency acceptable

## Vendor Lock-In Mitigation

### Keep Platform-Agnostic Code

```python
# Good: Platform-agnostic
import os
from fastmcp import FastMCP

DB_URL = os.getenv("DATABASE_URL")
mcp = FastMCP("Workout Coach")

# Bad: Platform-specific
from cloudflare_workers import kv_storage  # Locked to Cloudflare
```

### Use Standard Interfaces

- Environment variables (not platform-specific config)
- Standard HTTP (not platform-specific networking)
- Native PostgreSQL drivers (when possible)
- Generic authentication (OAuth 2.1 standard)

### Maintain Migration Scripts

```bash
# .github/workflows/deploy.sh

case $PLATFORM in
  railway)
    railway up
    ;;
  fly)
    fly deploy
    ;;
  render)
    render deploy
    ;;
esac
```

### Database Access Abstraction

```python
# database.py - Abstract DB access

class DatabaseClient:
    """Abstract database access to support both native and REST API"""

    async def query(self, sql: str, params: dict):
        if os.getenv("USE_REST_API"):
            # Cloudflare Workers path
            return await self._query_rest_api(sql, params)
        else:
            # Native driver path (Railway, Fly.io, Render)
            return await self._query_native(sql, params)
```

This allows switching between Cloudflare Workers (REST API) and native driver platforms with one environment variable.

## Testing Strategy

### Phase 1: Local Only
- Run with STDIO transport
- PostgreSQL via localhost or Supabase tunnel
- Test with Claude Desktop

### Phase 2: Deploy to Railway
- Deploy to Railway staging environment
- Test HTTP transport with OAuth
- Validate rate limiting
- Load test with expected traffic

### Phase 3: Compare Platforms
If latency becomes issue:
1. Deploy same code to Fly.io (native drivers)
2. Deploy same code to Cloudflare Workers (REST API)
3. Measure p50/p95 latency
4. Make data-driven decision

## Monitoring & Evaluation

Track these metrics to inform hosting decisions:

| Metric | Target | Action if Exceeded |
|--------|--------|-------------------|
| p95 latency | <2s | Investigate DB queries, consider caching |
| Request volume | <10k/day | Within free tier, no action |
| Request volume | >100k/month | Monitor performance, evaluate if upgrade needed |
| Database query time | <100ms | Optimize queries, add indexes |
| Cold start time | <500ms | Acceptable for side project (Fly.io free tier) |
| Monthly cost | $0 | Must stay free (side project constraint) |

## Decision

**For All Phases**: Fly.io with native PostgreSQL drivers

**Rationale**:
1. **Permanent free tier** (no credit expiration, no surprise charges)
2. Native drivers = better performance (5-20ms vs 50-150ms REST API)
3. Proven reliability (user's database ran on Fly.io for 2 years successfully)
4. Low maintenance (Docker-based, standard deployment)
5. No Pyodide limitations
6. Perfect for side project / spare time development
7. Easy migration path if needed (standard Python + Docker)

**Re-evaluation triggers**:
1. Traffic exceeds 100k req/month → Monitor performance, may still fit in free tier
2. Need global edge performance → Consider Cloudflare Workers (accept REST API trade-off)
3. Need dedicated VMs → Upgrade to paid Fly.io ($6-12/mo)

**Status**: Approved - Aligns with project constraints (side project, spare time, permanently free)

## Consequences

### Positive
- ✅ Truly free forever (no time-limited credits)
- ✅ Fast database queries (native drivers: 5-20ms)
- ✅ Simple development workflow
- ✅ No Pyodide limitations
- ✅ Low maintenance overhead
- ✅ Easy to migrate platforms if needed
- ✅ Proven platform (user has experience)
- ✅ No surprise billing

### Negative
- ⚠️ Shared VMs (resource contention possible, but acceptable for side project)
- ⚠️ Slightly more complex setup than Railway (requires Dockerfile)
- ⚠️ Cold starts (50-200ms) vs always-on options
- ⚠️ Less global performance than Cloudflare edge (but good enough)

### Neutral
- Need to maintain abstraction for potential future migration
- Will need to evaluate if project scales significantly (>100 users)
- Free tier limits should be sufficient for personal/side project use indefinitely

## References

- [Cloudflare Workers Python Limitations](https://developers.cloudflare.com/workers/languages/python/)
- [Pyodide Database Limitations](https://pyodide.org/en/stable/usage/wasm-constraints.html)
- [Railway Pricing](https://railway.app/pricing)
- [Fly.io Free Tier](https://fly.io/docs/about/pricing/)
- [FastMCP Deployment](https://gofastmcp.com/deployment/http)
- [Supabase REST API](https://supabase.com/docs/guides/api)

## Appendix: Database Access Patterns

### Native Driver (Railway/Fly.io/Render)

```python
import asyncpg

async def get_exercise_history(user_id: str, exercise: str):
    conn = await asyncpg.connect(os.getenv("DATABASE_URL"))
    rows = await conn.fetch("""
        SELECT * FROM exercise_stats
        WHERE name = $1
        AND performed_session_id IN (
            SELECT performed_session_id FROM performed_session
            WHERE app_user_id = $2
        )
        ORDER BY completed_at DESC
        LIMIT 100
    """, exercise, user_id)
    await conn.close()
    return rows
```

**Performance**: ~5-20ms query time

### REST API (Cloudflare Workers)

```python
import httpx

async def get_exercise_history(user_id: str, exercise: str):
    # Supabase REST API with RLS
    async with httpx.AsyncClient() as client:
        response = await client.get(
            f"{SUPABASE_URL}/rest/v1/exercise_stats",
            params={
                "name": f"eq.{exercise}",
                "order": "completed_at.desc",
                "limit": 100
            },
            headers={
                "Authorization": f"Bearer {user_jwt}",
                "apikey": SUPABASE_ANON_KEY
            }
        )
        return response.json()
```

**Performance**: ~50-150ms (HTTP overhead + parsing)

**Key Difference**: 3-5x slower, but acceptable for MCP use case (not real-time).
