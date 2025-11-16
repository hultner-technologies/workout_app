# Pre-Requisite: Configure Supabase OAuth 2.1 for MCP

**Status**: Planning
**Priority**: Medium (blocks Phase 2)
**Effort**: Small
**Labels**: `auth`, `oauth`, `prerequisite`, `mcp`
**Epic**: EPIC_mcp_integration.md
**Blocks**: Phase 2 - HTTP Transport + OAuth

## Problem

MCP specification requires OAuth 2.1 with specific features:
- Authorization Server Metadata (RFC 8414)
- Dynamic Client Registration (optional but recommended)
- PKCE (Proof Key for Code Exchange)

Supabase Auth supports OAuth 2.1, but we need to configure it properly for MCP clients (like Claude Desktop).

## Requirements

### Functional
- [ ] MCP clients can discover authorization server endpoints
- [ ] Clients can register dynamically (or use pre-configured client)
- [ ] OAuth flow works with PKCE
- [ ] JWT tokens include necessary claims
- [ ] Tokens can be validated by MCP server

### Security
- [ ] HTTPS only (enforced)
- [ ] PKCE mandatory for authorization code flow
- [ ] Short-lived access tokens (1 hour)
- [ ] Secure token storage recommendations
- [ ] Proper CORS configuration

## Supabase OAuth Configuration

### 1. Create OAuth Application

In Supabase Dashboard:
1. Navigate to Organization Settings → OAuth Apps
2. Create new OAuth app:
   - **Name**: "Workout MCP Server"
   - **Description**: "MCP server for AI-powered workout assistance"
   - **Website URL**: `http://localhost:8000` (dev) or production URL
   - **Callback URLs**:
     - `http://localhost:8000/oauth/callback` (dev)
     - `https://your-domain.com/oauth/callback` (production)
     - `mcp://oauth/callback` (for MCP clients)
   - **Scopes**: (see below)

3. Note the **Client ID** and **Client Secret**

### 2. Define OAuth Scopes

MCP server needs specific scopes for data access:

```
read:workouts     - Read workout performance data
read:exercises    - Read exercise catalog
read:plans        - Read workout plans
write:plans       - Create/modify user plans (Phase 3)
read:analytics    - Access performance analytics
```

**Implementation in Supabase**:

Supabase doesn't have custom scopes by default. We'll use RLS policies for fine-grained access control and use standard scopes:
- `read`: Read access to user's own data
- `write`: Write access to user's own data

RLS policies already enforce data access rules.

### 3. Authorization Server Metadata

MCP servers MUST expose `/.well-known/oauth-authorization-server` endpoint.

**Implementation** (in MCP server):

```python
# server.py - OAuth endpoints

from fastapi import FastAPI
from fastmcp import FastMCP

app = FastAPI()
mcp = FastMCP("Workout Coach")

@app.get("/.well-known/oauth-authorization-server")
async def authorization_server_metadata():
    """OAuth 2.1 Authorization Server Metadata (RFC 8414)"""
    base_url = os.getenv("MCP_SERVER_URL", "http://localhost:8000")
    supabase_url = os.getenv("SUPABASE_URL")

    return {
        "issuer": supabase_url,
        "authorization_endpoint": f"{supabase_url}/auth/v1/authorize",
        "token_endpoint": f"{supabase_url}/auth/v1/token",
        "jwks_uri": f"{supabase_url}/auth/v1/jwks",
        "response_types_supported": ["code"],
        "grant_types_supported": ["authorization_code", "refresh_token"],
        "code_challenge_methods_supported": ["S256"],  # PKCE
        "token_endpoint_auth_methods_supported": ["client_secret_basic", "client_secret_post"],
        "scopes_supported": ["read", "write"],
        "service_documentation": f"{base_url}/docs",
    }

@app.get("/oauth/authorize")
async def authorize(
    client_id: str,
    redirect_uri: str,
    response_type: str,
    scope: str,
    state: str,
    code_challenge: str,
    code_challenge_method: str = "S256"
):
    """
    Redirect to Supabase OAuth authorize endpoint.

    MCP client → Our server → Supabase Auth
    """
    supabase_auth_url = f"{os.getenv('SUPABASE_URL')}/auth/v1/authorize"

    # Validate client_id matches our configured OAuth app
    if client_id != os.getenv("OAUTH_CLIENT_ID"):
        raise HTTPException(401, "Invalid client_id")

    # Build authorization URL
    params = {
        "client_id": os.getenv("SUPABASE_OAUTH_CLIENT_ID"),  # Our Supabase OAuth app
        "redirect_uri": redirect_uri,
        "response_type": response_type,
        "scope": scope,
        "state": state,
        "code_challenge": code_challenge,
        "code_challenge_method": code_challenge_method
    }

    redirect_url = f"{supabase_auth_url}?{urlencode(params)}"
    return RedirectResponse(redirect_url)


@app.post("/oauth/token")
async def token_exchange(
    grant_type: str,
    code: str,
    redirect_uri: str,
    client_id: str,
    client_secret: str,
    code_verifier: str
):
    """
    Exchange authorization code for access token.

    Proxies to Supabase token endpoint with PKCE verification.
    """
    # Exchange code with Supabase
    async with httpx.AsyncClient() as client:
        response = await client.post(
            f"{os.getenv('SUPABASE_URL')}/auth/v1/token",
            data={
                "grant_type": grant_type,
                "code": code,
                "redirect_uri": redirect_uri,
                "code_verifier": code_verifier
            },
            auth=(os.getenv("SUPABASE_OAUTH_CLIENT_ID"), os.getenv("SUPABASE_OAUTH_CLIENT_SECRET"))
        )

        return response.json()
```

### 4. JWT Token Validation

MCP server must validate JWT tokens on every request.

```python
# auth.py - Token validation

import jwt
from jwt import PyJWKClient
from functools import wraps

SUPABASE_URL = os.getenv("SUPABASE_URL")
JWKS_URL = f"{SUPABASE_URL}/auth/v1/jwks"

# Cache JWKS
jwks_client = PyJWKClient(JWKS_URL)

def get_signing_key(token: str):
    """Get signing key from JWKS"""
    return jwks_client.get_signing_key_from_jwt(token)

def validate_token(token: str) -> dict:
    """
    Validate Supabase JWT token.

    Returns decoded token claims if valid.
    Raises exception if invalid.
    """
    try:
        signing_key = get_signing_key(token)

        payload = jwt.decode(
            token,
            signing_key.key,
            algorithms=["RS256"],
            audience="authenticated",  # Supabase standard audience
            options={"verify_exp": True}
        )

        return payload

    except jwt.ExpiredSignatureError:
        raise AuthenticationError("Token expired")
    except jwt.InvalidTokenError as e:
        raise AuthenticationError(f"Invalid token: {e}")

def require_auth(func):
    """Decorator to require valid JWT token"""
    @wraps(func)
    async def wrapper(*args, **kwargs):
        # Extract token from Authorization header
        token = request.headers.get("Authorization", "").replace("Bearer ", "")

        if not token:
            raise AuthenticationError("Missing authorization token")

        # Validate and decode
        claims = validate_token(token)

        # Add user_id to kwargs
        kwargs['user_id'] = claims['sub']
        kwargs['user_claims'] = claims

        return await func(*args, **kwargs)

    return wrapper

# Usage in tools
@mcp.tool()
@require_auth
async def analyze_progress(exercise_name: str, user_id: str, **kwargs):
    """Now has authenticated user_id from JWT"""
    # Use user_id for RLS queries
    pass
```

## Environment Variables

```bash
# OAuth Configuration
OAUTH_CLIENT_ID=your-mcp-oauth-client-id
OAUTH_CLIENT_SECRET=your-mcp-oauth-client-secret

# Supabase OAuth App (registered in Supabase dashboard)
SUPABASE_OAUTH_CLIENT_ID=supabase-oauth-app-client-id
SUPABASE_OAUTH_CLIENT_SECRET=supabase-oauth-app-secret

# Server Configuration
MCP_SERVER_URL=http://localhost:8000
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

## OAuth Flow

### Authorization Code Flow with PKCE

```
1. MCP Client (Claude Desktop)
   ↓ (initiates auth)

2. MCP Server /.well-known/oauth-authorization-server
   ← (discovers endpoints)

3. MCP Client → /oauth/authorize
   - client_id
   - redirect_uri
   - scope
   - code_challenge (PKCE)

4. MCP Server → Supabase /auth/v1/authorize
   ← (redirects user)

5. User authenticates with Supabase
   ↓ (enters credentials)

6. Supabase → redirect_uri?code=AUTH_CODE&state=STATE
   ← (authorization code)

7. MCP Client → /oauth/token
   - code
   - code_verifier (PKCE)

8. MCP Server → Supabase /auth/v1/token
   ← (exchanges code)

9. Supabase → access_token, refresh_token
   ← (JWT tokens)

10. MCP Client → MCP Server (with Bearer token)
    - All future requests include: Authorization: Bearer {access_token}

11. MCP Server validates JWT on every request
    - Decodes JWT
    - Verifies signature (JWKS)
    - Checks expiration
    - Extracts user_id from claims
```

## Testing

### 1. Manual OAuth Flow Test

```bash
# Start MCP server
uv run python -m workout_mcp.server --transport http --port 8000

# Test metadata endpoint
curl http://localhost:8000/.well-known/oauth-authorization-server | jq

# Initiate OAuth (in browser)
open "http://localhost:8000/oauth/authorize?\
client_id=YOUR_CLIENT_ID&\
redirect_uri=http://localhost:8000/oauth/callback&\
response_type=code&\
scope=read%20write&\
state=random_state&\
code_challenge=CHALLENGE&\
code_challenge_method=S256"

# After redirect, exchange code for token
curl -X POST http://localhost:8000/oauth/token \
  -d "grant_type=authorization_code" \
  -d "code=AUTH_CODE" \
  -d "redirect_uri=http://localhost:8000/oauth/callback" \
  -d "client_id=YOUR_CLIENT_ID" \
  -d "client_secret=YOUR_SECRET" \
  -d "code_verifier=VERIFIER"
```

### 2. Token Validation Test

```python
# tests/test_auth.py
import pytest
from workout_mcp.auth import validate_token

def test_valid_token():
    """Test JWT validation with valid token"""
    token = get_test_token()  # From Supabase test user
    claims = validate_token(token)

    assert claims['sub']  # User ID present
    assert claims['aud'] == 'authenticated'

def test_expired_token():
    """Test rejection of expired token"""
    expired_token = "..."

    with pytest.raises(AuthenticationError, match="expired"):
        validate_token(expired_token)
```

### 3. Integration Test with Claude Desktop

1. Configure Claude Desktop with MCP server URL
2. Initiate connection
3. Verify OAuth prompt appears
4. Complete authentication
5. Test MCP queries work with authenticated context

## Security Considerations

### 1. PKCE Enforcement

Always require PKCE (code_challenge + code_verifier) for authorization code flow:

```python
if not code_challenge or code_challenge_method != "S256":
    raise AuthenticationError("PKCE required (S256)")
```

### 2. Token Storage

**Never** store tokens in:
- Git repositories
- Logs
- Error messages
- URLs (use POST body or headers only)

**Do** store tokens:
- In memory (MCP client)
- Encrypted at rest (if persistence needed)
- With proper access control

### 3. CORS Configuration

For HTTP transport, configure CORS properly:

```python
from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:*", "https://claude.ai"],
    allow_credentials=True,
    allow_methods=["GET", "POST"],
    allow_headers=["Authorization", "Content-Type"],
)
```

### 4. Rate Limiting (OAuth endpoints)

Prevent brute force attacks:

```python
from slowapi import Limiter
from slowapi.util import get_remote_address

limiter = Limiter(key_func=get_remote_address)

@app.post("/oauth/token")
@limiter.limit("10/minute")  # Max 10 token requests per minute
async def token_exchange(...):
    ...
```

## Acceptance Criteria

- [ ] OAuth app created in Supabase dashboard
- [ ] Authorization server metadata endpoint implemented
- [ ] OAuth authorize endpoint proxies to Supabase
- [ ] Token exchange endpoint validates PKCE
- [ ] JWT validation middleware implemented
- [ ] All MCP tools require authentication
- [ ] Manual OAuth flow test successful
- [ ] Integration test with Claude Desktop successful
- [ ] Security checklist completed
- [ ] Documentation updated

## Migration from Phase 1

Phase 1 uses simple env var JWT token:
```python
# Phase 1 (MVP)
user_token = os.getenv("USER_JWT_TOKEN")
```

Phase 2 extracts from request:
```python
# Phase 2 (OAuth)
@require_auth
async def tool(user_id: str, **kwargs):
    # user_id automatically extracted from JWT
    pass
```

**Migration**:
1. Add OAuth endpoints (don't remove env var support yet)
2. Test OAuth flow
3. Deprecate env var auth
4. Remove env var auth in Phase 3

## Troubleshooting

### Common Issues

**Issue**: "Invalid redirect_uri"
- **Solution**: Ensure callback URL is registered in Supabase OAuth app

**Issue**: "PKCE verification failed"
- **Solution**: code_verifier must match original code_challenge (S256 hash)

**Issue**: "Token validation failed"
- **Solution**: Check JWKS URL is accessible, token not expired

**Issue**: "CORS error"
- **Solution**: Add client origin to CORS allow_origins

## References

- [OAuth 2.1 Specification](https://oauth.net/2.1/)
- [MCP Authorization](https://modelcontextprotocol.io/specification/draft/basic/authorization)
- [Supabase OAuth](https://supabase.com/docs/guides/getting-started/mcp)
- [RFC 8414: OAuth Authorization Server Metadata](https://datatracker.ietf.org/doc/html/rfc8414)
- [RFC 7636: PKCE](https://datatracker.ietf.org/doc/html/rfc7636)

## Related Issues

- Blocks: Phase 2 #XXX - HTTP Transport + OAuth
- Related: EPIC #XXX - MCP Integration
- Related: Phase 1 #XXX - MVP (uses simple auth)
