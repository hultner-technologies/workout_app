# Phase 2: MCP HTTP Transport + OAuth 2.1 Authentication

**Status**: Planning
**Priority**: Medium (after Phase 1)
**Effort**: Medium (2-3 weeks)
**Labels**: `mcp`, `http`, `oauth`, `phase-2`
**Epic**: EPIC_mcp_integration.md
**Depends On**: Phase 1 #XXX, Pre-req: ISSUE_oauth_setup.md

## Goal

Deploy the MCP server to Fly.io with HTTP transport and full OAuth 2.1 authentication, making it accessible remotely from Claude Desktop and other MCP clients.

## Success Criteria

User can:
1. Deploy MCP server to Fly.io (free tier)
2. Authorize via Supabase OAuth from Claude Desktop
3. Access their workout data remotely via authenticated HTTP connection
4. Have rate limiting protect against abuse (100 req/hour/user)

## Scope

### In Scope
- ✅ HTTP transport (streamable-http)
- ✅ OAuth 2.1 flow (authorization code + PKCE)
- ✅ JWT token validation middleware
- ✅ Deployment to Fly.io
- ✅ Dockerfile for containerization
- ✅ Per-user rate limiting (100 req/hour)
- ✅ CORS configuration
- ✅ Production logging & monitoring
- ✅ Environment-based configuration (dev/prod)

### Out of Scope
- ❌ Plan creation (Phase 3)
- ❌ Write operations (Phase 3)
- ❌ MCP registry publication (Phase 4)
- ❌ Multi-region deployment
- ❌ Advanced caching

## Implementation

### 1. Add HTTP Transport Support

Update `server.py` to support both STDIO and HTTP:

```python
# server.py
import os
from fastapi import FastAPI
from fastmcp import FastMCP

app = FastAPI()
mcp = FastMCP("Workout Coach")

# Existing STDIO resources and tools are auto-discovered

if __name__ == "__main__":
    transport = os.getenv("MCP_TRANSPORT", "stdio")

    if transport == "http":
        import uvicorn
        # Mount MCP at /mcp endpoint
        app = mcp.get_asgi_app(mount_path="/mcp")
        uvicorn.run(app, host="0.0.0.0", port=8000)
    else:
        # Default: STDIO for local development
        mcp.run(transport="stdio")
```

### 2. OAuth 2.1 Integration

Add OAuth endpoints (from pre-req ISSUE_oauth_setup.md):

```python
# oauth.py
from fastapi import FastAPI, HTTPException
from fastapi.responses import RedirectResponse
import httpx
import jwt
from jwt import PyJWKClient

app = FastAPI()

# OAuth configuration
SUPABASE_URL = os.getenv("SUPABASE_URL")
OAUTH_CLIENT_ID = os.getenv("OAUTH_CLIENT_ID")
OAUTH_CLIENT_SECRET = os.getenv("OAUTH_CLIENT_SECRET")

@app.get("/.well-known/oauth-authorization-server")
async def authorization_server_metadata():
    """OAuth 2.1 Authorization Server Metadata (RFC 8414)"""
    return {
        "issuer": SUPABASE_URL,
        "authorization_endpoint": f"{SUPABASE_URL}/auth/v1/authorize",
        "token_endpoint": f"{request.base_url}oauth/token",
        "jwks_uri": f"{SUPABASE_URL}/auth/v1/jwks",
        "response_types_supported": ["code"],
        "grant_types_supported": ["authorization_code", "refresh_token"],
        "code_challenge_methods_supported": ["S256"],
        "scopes_supported": ["read", "write"],
    }

@app.get("/oauth/authorize")
async def authorize(...):
    # Redirect to Supabase OAuth
    # (Full implementation in ISSUE_oauth_setup.md)
    pass

@app.post("/oauth/token")
async def token_exchange(...):
    # Exchange code for token via Supabase
    # (Full implementation in ISSUE_oauth_setup.md)
    pass

# JWT validation middleware
def validate_token(token: str) -> dict:
    jwks_client = PyJWKClient(f"{SUPABASE_URL}/auth/v1/jwks")
    signing_key = jwks_client.get_signing_key_from_jwt(token)

    payload = jwt.decode(
        token,
        signing_key.key,
        algorithms=["RS256"],
        audience="authenticated"
    )
    return payload
```

### 3. Rate Limiting

Implement per-user rate limiting:

```python
# rate_limit.py
from datetime import datetime, timedelta
from collections import defaultdict
from fastapi import HTTPException

class RateLimiter:
    def __init__(self, requests_per_hour: int = 100):
        self.requests_per_hour = requests_per_hour
        self.user_requests = defaultdict(list)

    def check_rate_limit(self, user_id: str):
        now = datetime.now()
        hour_ago = now - timedelta(hours=1)

        # Clean old requests
        self.user_requests[user_id] = [
            ts for ts in self.user_requests[user_id]
            if ts > hour_ago
        ]

        if len(self.user_requests[user_id]) >= self.requests_per_hour:
            raise HTTPException(
                status_code=429,
                detail=f"Rate limit exceeded: {self.requests_per_hour} requests per hour"
            )

        self.user_requests[user_id].append(now)

# Global rate limiter instance
rate_limiter = RateLimiter(requests_per_hour=100)
```

### 4. Dockerfile

Create Dockerfile for Fly.io deployment:

```dockerfile
# Dockerfile
FROM python:3.12-slim

WORKDIR /app

# Install uv
RUN pip install uv

# Copy project files
COPY pyproject.toml ./
COPY src/ ./src/

# Install dependencies
RUN uv pip install --system -e .

# Expose port
EXPOSE 8000

# Run server with HTTP transport
ENV MCP_TRANSPORT=http
CMD ["python", "-m", "workout_mcp.server"]
```

### 5. Fly.io Configuration

Create `fly.toml`:

```toml
app = "workout-mcp"
primary_region = "arn"  # Stockholm (close to Europe)

[build]
  dockerfile = "Dockerfile"

[env]
  MCP_TRANSPORT = "http"

[[services]]
  internal_port = 8000
  protocol = "tcp"

  [[services.ports]]
    port = 80
    handlers = ["http"]

  [[services.ports]]
    port = 443
    handlers = ["tls", "http"]

[http_service]
  internal_port = 8000
  force_https = true
  auto_stop_machines = true
  auto_start_machines = true
  min_machines_running = 0  # Scale to zero when idle (free tier)

[[vm]]
  memory = '256mb'
  cpu_kind = 'shared'
  cpus = 1
```

### 6. Deployment Script

Create deployment helper:

```bash
#!/bin/bash
# deploy.sh

# Check if flyctl is installed
if ! command -v flyctl &> /dev/null; then
    echo "Installing flyctl..."
    curl -L https://fly.io/install.sh | sh
fi

# Login to Fly.io
flyctl auth login

# Create app (first time only)
if ! flyctl apps list | grep -q "workout-mcp"; then
    flyctl launch --no-deploy
fi

# Set secrets
flyctl secrets set \
    SUPABASE_URL="$SUPABASE_URL" \
    SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY" \
    OAUTH_CLIENT_ID="$OAUTH_CLIENT_ID" \
    OAUTH_CLIENT_SECRET="$OAUTH_CLIENT_SECRET"

# Deploy
flyctl deploy

# Show app status
flyctl status
flyctl logs
```

### 7. CORS Configuration

Add CORS for Claude Desktop and web clients:

```python
# server.py
from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:*",
        "https://claude.ai",
        "mcp://*"  # MCP protocol
    ],
    allow_credentials=True,
    allow_methods=["GET", "POST", "OPTIONS"],
    allow_headers=["Authorization", "Content-Type"],
)
```

### 8. Environment Configuration

Support dev/prod configurations:

```python
# config.py
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    environment: str = "development"
    supabase_url: str
    supabase_anon_key: str
    oauth_client_id: str
    oauth_client_secret: str
    rate_limit_per_hour: int = 100
    log_level: str = "INFO"

    class Config:
        env_file = ".env"

settings = Settings()
```

## Testing Strategy

### 1. Local HTTP Testing

Test HTTP transport locally before deploying:

```bash
# Start server with HTTP transport
MCP_TRANSPORT=http python -m workout_mcp.server

# Test discovery endpoint
curl http://localhost:8000/.well-known/oauth-authorization-server

# Test MCP endpoint (requires auth)
curl -H "Authorization: Bearer $TOKEN" http://localhost:8000/mcp
```

### 2. OAuth Flow Testing

Test complete OAuth flow:
1. Open authorization URL in browser
2. Authenticate with Supabase
3. Capture authorization code from callback
4. Exchange code for token
5. Verify token works for MCP requests

### 3. Rate Limiting Testing

```python
# tests/test_rate_limit.py
async def test_rate_limit():
    # Make 101 requests as same user
    for i in range(101):
        if i < 100:
            response = await client.get("/mcp/tool", headers=auth_headers)
            assert response.status_code == 200
        else:
            response = await client.get("/mcp/tool", headers=auth_headers)
            assert response.status_code == 429  # Rate limited
```

### 4. Deployment Testing

After deploying to Fly.io:
1. Test OAuth flow with production URL
2. Configure Claude Desktop with production server
3. Verify all Phase 1 queries still work
4. Monitor logs for errors
5. Test rate limiting with production database

## Documentation Updates

### README.md

Add deployment section:
- Fly.io setup instructions
- Environment variables configuration
- OAuth app setup in Supabase
- Claude Desktop configuration for remote server

### Production Monitoring

```bash
# View logs
flyctl logs

# Check metrics
flyctl metrics

# SSH into VM
flyctl ssh console

# Scale manually if needed
flyctl scale count 1  # Always have 1 VM running
```

## Acceptance Criteria

- [ ] HTTP transport working locally
- [ ] OAuth 2.1 flow implemented and tested
- [ ] JWT validation working correctly
- [ ] Rate limiting prevents abuse (100 req/hour/user)
- [ ] Dockerfile builds successfully
- [ ] Deployed to Fly.io free tier
- [ ] Claude Desktop can connect and authorize
- [ ] All Phase 1 functionality works remotely
- [ ] CORS configured correctly
- [ ] Production logging in place
- [ ] Documentation complete

## Cost Estimate

- **Development**: $0 (local)
- **Production**: $0 (Fly.io free tier - 3 shared VMs)
- **Supabase**: $0 (free tier should be sufficient)
- **Total**: $0/month

## Future Work (Phase 3)

- Add write operations (plan creation)
- Implement user_plan support
- Add caching layer
- Consider multi-region deployment if users are global

## References

- [FastMCP HTTP Deployment](https://gofastmcp.com/deployment/http)
- [Fly.io Free Tier](https://fly.io/docs/about/pricing/)
- [OAuth 2.1 Specification](https://oauth.net/2.1/)
- Pre-req: ISSUE_oauth_setup.md
- Phase 1: ISSUE_phase1_mvp_readonly.md
- Epic: EPIC_mcp_integration.md

## Related Issues

- Depends on: Phase 1 #XXX
- Depends on: ISSUE_oauth_setup #XXX
- Blocks: Phase 3 #XXX
