# MCP Integration Planning Documents

This directory contains planning documents for the MCP (Model Context Protocol) integration feature. These markdown files can be used to create GitHub issues for tracking implementation.

## Document Structure

### Epic (Feature Overview)
- **EPIC_mcp_integration.md** - Main feature epic covering the entire MCP integration
  - Overview of MCP integration goals
  - Technology stack decisions
  - Implementation phases
  - Use cases and success metrics
  - Open questions and answers

### Architecture Decisions
- **ADR_mcp_hosting_platform.md** - Hosting platform evaluation and decision
  - Comparison of hosting platforms (Cloudflare Workers, Railway, Fly.io, etc.)
  - Pyodide limitations analysis
  - Cost and performance estimates
  - Vendor lock-in mitigation strategies
  - Final recommendation: Railway (native drivers) for MVP

### Pre-Requisite Issues
These must be completed before main implementation phases:

1. **ISSUE_user_plan_schema.md** - User plan database schema
   - Problem: No user-specific plans currently
   - Solution: Dual-table design (system plans + user plans)
   - Includes full SQL schema, RLS policies, and views
   - Blocks: Phase 3

2. **ISSUE_oauth_setup.md** - Supabase OAuth 2.1 configuration
   - OAuth app setup in Supabase
   - Authorization server metadata endpoints
   - JWT token validation
   - PKCE implementation
   - Blocks: Phase 2

### Implementation Phases

1. **ISSUE_phase1_mvp_readonly.md** - MVP with local STDIO transport
   - Read-only analytics and tools
   - Supabase REST API client (Cloudflare-compatible)
   - Local testing only
   - No deployment, no OAuth
   - ~2-3 weeks effort

2. **Phase 2** (not yet created) - HTTP transport + OAuth 2.1
   - Deploy to Railway/Fly.io
   - Full OAuth flow
   - Rate limiting
   - Production-ready

3. **Phase 3** (not yet created) - User plans + write operations
   - AI can create workout plans
   - Plan management tools
   - Template system

4. **Phase 4** (not yet created) - MCP registry publication
   - PyPI package
   - MCP.io registry listing
   - Public distribution

## Key Decisions Made

### 1. Coaching Intelligence (Epic - Question #1)
**Decision**: Option B - Server returns data, consuming LLM (Claude) analyzes
**Rationale**: Simpler, no LLM costs, leverages Claude's knowledge

### 2. Plan Table Design (Epic - Question #2)
**Decision**: Dual-table design (separate `user_plan` table)
**Rationale**: Clean separation, backwards compatible, clearer security
**See**: ISSUE_user_plan_schema.md

### 3. Hosting Platform (ADR)
**Decision**: Railway for MVP/Beta, with clear migration path
**Rationale**: Native PostgreSQL drivers (5-20ms vs 50-150ms REST API)
**Fallback**: Fly.io (permanent free tier) or Cloudflare Workers (accept REST API trade-off)

### 4. Rate Limiting (Epic - Question #5)
**Decision**: Implement in MCP server code (100 req/hour/user)
**Rationale**: Consistent across platforms, better error messages

### 5. Transport Support (Epic - Question #8)
**Decision**: Same server supports both STDIO (local) and HTTP (remote)
**Rationale**: FastMCP supports both, STDIO for dev, HTTP for production

### 6. Python Library Limitations (ADR)
**Finding**: Pyodide cannot use native PostgreSQL drivers
**Mitigation**: Use Supabase REST API + maintain migration path to native drivers

## Creating GitHub Issues

### Option 1: Manual Creation
Copy content from each markdown file into GitHub issue creation form.

### Option 2: GitHub CLI
```bash
# Install gh CLI if not already installed
# brew install gh  # macOS
# sudo apt install gh  # Ubuntu

# Authenticate
gh auth login

# Create epic
gh issue create \
  --title "Epic: MCP Integration for AI-Powered Workout Assistance" \
  --body-file .github/EPIC_mcp_integration.md \
  --label "epic,mcp,enhancement" \
  --assignee "@me"

# Create pre-requisites
gh issue create \
  --title "Pre-Requisite: Design and Implement User Plan Schema" \
  --body-file .github/ISSUE_user_plan_schema.md \
  --label "database,schema,prerequisite,mcp"

gh issue create \
  --title "Pre-Requisite: Configure Supabase OAuth 2.1 for MCP" \
  --body-file .github/ISSUE_oauth_setup.md \
  --label "auth,oauth,prerequisite,mcp"

# Create phase 1
gh issue create \
  --title "Phase 1: MCP MVP - Read-Only Analytics (Local STDIO)" \
  --body-file .github/ISSUE_phase1_mvp_readonly.md \
  --label "mcp,mvp,phase-1"
```

### Option 3: GitHub Actions (Future)
Create a workflow to auto-generate issues from markdown files.

## Issue Dependencies

```
EPIC_mcp_integration (Epic)
├── Pre-Requisites (parallel)
│   ├── ISSUE_user_plan_schema → Blocks Phase 3
│   └── ISSUE_oauth_setup → Blocks Phase 2
│
├── Phase 1: MVP (Read-only, local)
│   ├── Depends on: None
│   └── Deliverable: Working local MCP server
│
├── Phase 2: HTTP + OAuth
│   ├── Depends on: Phase 1, ISSUE_oauth_setup
│   └── Deliverable: Deployed server with auth
│
├── Phase 3: User Plans
│   ├── Depends on: Phase 2, ISSUE_user_plan_schema
│   └── Deliverable: AI can create plans
│
└── Phase 4: Registry Publication
    ├── Depends on: Phase 3
    └── Deliverable: Public MCP server
```

## Recommended Implementation Order

### Immediate (Week 1-2)
1. Read and review Epic + ADR
2. Create GitHub issues from markdown files
3. Discuss and finalize open questions
4. Begin Phase 1 implementation (can start immediately)

### Short-term (Week 3-4)
1. Complete Phase 1 (local MVP)
2. Test with Claude Desktop locally
3. Start user_plan schema design (parallel)

### Medium-term (Week 5-8)
1. Implement user_plan schema
2. Set up Supabase OAuth
3. Implement Phase 2 (HTTP + OAuth)
4. Deploy to Railway

### Long-term (Week 9-12)
1. Implement Phase 3 (user plans)
2. Test AI plan creation
3. Prepare Phase 4 (registry)

## Cost Estimates

### Development Phase
- **Hosting**: $0 (local development)
- **Supabase**: Free tier (existing)
- **Total**: $0/month

### Beta Phase (10-50 users)
- **Hosting**: Railway $0-10/month (free tier then paid)
- **Supabase**: Free tier (should be sufficient)
- **Total**: $0-10/month

### Production (100-1000 users)
- **Hosting**: Railway $10-20/month OR Cloudflare Workers $15-30/month
- **Supabase**: Free tier → Pro $25/month (if DB exceeds limits)
- **Total**: $10-50/month

## Volume Estimates (Free Tiers)

| Platform | Free Tier | Estimated Users/Day |
|----------|-----------|---------------------|
| Cloudflare Workers | 100k req/day | 150-300 |
| Railway | $5 credit (~1 month) | 30-60 |
| Fly.io | 3 VMs | 50-100 |
| Render | 750 hrs/month | 100-200 |

**Assumptions**: 10-20 MCP requests per user session, 2 DB queries per request

## Performance Targets

| Metric | Target | Measurement |
|--------|--------|-------------|
| MCP request latency (p95) | <2s | From client request to response |
| Database query time | <100ms | Single query execution |
| Cold start (HTTP) | <500ms | First request after idle |
| Token validation | <50ms | JWT decode + verify |

## Questions for Discussion

Before starting implementation, confirm:

1. **Volume Landmarks**: Should we implement Israetel's volume landmarks (MEV/MAV/MRV)?
   - Requires exercise-to-muscle mapping
   - Need per-muscle volume tracking
   - Complexity: Medium
   - Value: High (evidence-based coaching)

2. **User Plan Sharing**: Implement in Phase 3 or defer?
   - Simple: private/public only
   - Complex: sharing with specific users, following system
   - Recommend: Start simple, add later

3. **Rate Limiting Values**: Are these reasonable?
   - 100 requests/hour/user
   - 365 days max history
   - 100 sessions max in one query
   - Adjust based on feedback?

4. **Hosting Decision**: Confirm Railway for MVP?
   - Pro: Native drivers, simple deployment
   - Con: Not free forever (~$10/mo after free tier)
   - Alternative: Fly.io (permanent free tier, more complex setup)

## Success Metrics

We'll know this feature is successful when:

### Technical
- [ ] All phases complete and tested
- [ ] Server handles 100+ req/day reliably
- [ ] p95 latency <2s
- [ ] Zero security incidents
- [ ] Published in MCP registry

### User
- [ ] 10+ active users
- [ ] 100+ AI interactions
- [ ] Positive user feedback
- [ ] Users create plans via AI

### Business
- [ ] Feature differentiation (unique in market)
- [ ] User engagement increases
- [ ] Cost <$50/month at 100 users

## Next Steps

1. **Review**: Read all documents, discuss with team
2. **Create Issues**: Use GitHub CLI or manual creation
3. **Prioritize**: Confirm Phase 1 can start immediately
4. **Begin**: Start Phase 1 implementation

## Maintenance

These planning documents should be:
- Updated as decisions change
- Referenced in PRs
- Kept in sync with actual implementation
- Used for retrospectives after each phase

When a phase completes:
1. Mark issue as closed
2. Update Epic with learnings
3. Adjust future phases based on learnings

## References

- [MCP Specification](https://modelcontextprotocol.io/)
- [FastMCP Documentation](https://gofastmcp.com/)
- [Supabase MCP Guide](https://supabase.com/docs/guides/getting-started/mcp)
- [Cloudflare Workers Docs](https://developers.cloudflare.com/workers/)
- [Volume Landmarks Research](https://rpstrength.com/blogs/articles/training-volume-landmarks-muscle-growth)

## Contact

For questions about these planning documents, refer to the Epic or create a discussion thread.

---

**Last Updated**: 2025-11-15
**Status**: Planning Complete, Ready for Implementation
