# Phase 4: MCP Registry Publication

**Status**: Planning
**Priority**: Low (after Phase 3)
**Effort**: Small (1 week)
**Labels**: `mcp`, `registry`, `distribution`, `phase-4`
**Epic**: EPIC_mcp_integration.md
**Depends On**: Phase 3 #XXX

## Goal

Publish the workout MCP server to the official MCP registry (mcp.io), making it discoverable and installable by other users.

## Success Criteria

- Server listed in MCP registry under "Fitness" category
- Users can install via `mcp install workout-coach`
- Documentation published and accessible
- Demo video available
- At least 10 external users try the server

## Scope

### In Scope
- ✅ Package for PyPI distribution
- ✅ Create `server.json` metadata
- ✅ Publish to PyPI via UV
- ✅ Register with MCP.io registry
- ✅ Create comprehensive documentation
- ✅ Create demo video
- ✅ Add usage examples
- ✅ Set up basic support channel (GitHub Discussions)

### Out of Scope
- ❌ Hosted service for other users (they deploy their own)
- ❌ Premium features / monetization
- ❌ Multi-tenant hosting
- ❌ Customer support beyond GitHub issues

## Implementation

### 1. Package Metadata (`pyproject.toml`)

Update for PyPI publication:

```toml
[project]
name = "workout-mcp"
version = "1.0.0"
description = "MCP server for AI-powered workout tracking and coaching"
authors = [
    {name = "Your Name", email = "your.email@example.com"}
]
readme = "README.md"
license = {text = "MIT"}
requires-python = ">=3.10"
keywords = ["mcp", "fitness", "workout", "ai", "claude"]
classifiers = [
    "Development Status :: 4 - Beta",
    "Intended Audience :: Developers",
    "Intended Audience :: End Users/Desktop",
    "License :: OSI Approved :: MIT License",
    "Programming Language :: Python :: 3.10",
    "Programming Language :: Python :: 3.11",
    "Programming Language :: Python :: 3.12",
    "Topic :: Health & Fitness",
]

dependencies = [
    "fastmcp>=2.0.0",
    "httpx>=0.27.0",
    "python-dateutil>=2.8.2",
    "pyjwt[crypto]>=2.8.0",
    "fastapi>=0.104.0",
    "uvicorn>=0.24.0"
]

[project.urls]
Homepage = "https://github.com/yourusername/workout-mcp"
Documentation = "https://github.com/yourusername/workout-mcp#readme"
Repository = "https://github.com/yourusername/workout-mcp"
Issues = "https://github.com/yourusername/workout-mcp/issues"

[project.scripts]
workout-mcp = "workout_mcp.server:main"

[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"
```

### 2. MCP Server Metadata (`server.json`)

Create MCP registry metadata:

```json
{
  "name": "workout-coach-mcp",
  "namespace": "io.github.yourusername",
  "version": "1.0.0",
  "description": "AI-powered workout tracking and coaching via Model Context Protocol",
  "category": "fitness",
  "author": "Your Name",
  "homepage": "https://github.com/yourusername/workout-mcp",
  "repository": "https://github.com/yourusername/workout-mcp",
  "license": "MIT",
  "packages": {
    "pypi": "workout-mcp"
  },
  "capabilities": {
    "resources": [
      "workout://exercises/catalog",
      "workout://performance/history/{exercise}"
    ],
    "tools": [
      "analyze_progress",
      "suggest_next_weight",
      "calculate_weekly_volume",
      "suggest_deload",
      "create_workout_plan",
      "modify_user_plan"
    ],
    "prompts": [
      "suggest_deload",
      "plateau_breaker"
    ]
  },
  "requirements": {
    "supabase_account": true,
    "oauth_setup": true
  },
  "tags": ["fitness", "workout", "bodybuilding", "strength-training", "ai-coaching"],
  "screenshots": [
    "https://your-cdn.com/screenshots/claude-workout-1.png",
    "https://your-cdn.com/screenshots/volume-analysis.png"
  ],
  "demo_video": "https://www.youtube.com/watch?v=your-demo-video"
}
```

### 3. Comprehensive Documentation

#### README.md

Update with complete documentation:

```markdown
# Workout Coach MCP Server

AI-powered workout tracking and coaching via Model Context Protocol.

## Features

- 📊 **Performance Analysis**: Track progress with volume, 1RM calculations
- 🏋️ **Smart Coaching**: Evidence-based volume landmarks (MEV/MAV/MRV)
- 📝 **AI Plan Creation**: Generate personalized workout plans via conversation
- 🔐 **Secure**: OAuth 2.1 authentication via Supabase
- 🆓 **Free Hosting**: Deploy on Fly.io free tier

## Quick Start

### Prerequisites

- Python 3.10+
- Supabase account (free tier)
- Claude Desktop or other MCP client

### Installation

```bash
# Install via uv
uv pip install workout-mcp

# Or via pip
pip install workout-mcp
```

### Setup

1. **Create Supabase Project**
   - Go to https://supabase.com
   - Create new project
   - Run database migrations from `/database` folder

2. **Configure OAuth** (for remote access)
   - Create OAuth app in Supabase dashboard
   - Note client ID and secret

3. **Deploy to Fly.io** (optional, for remote access)
   ```bash
   flyctl launch
   flyctl secrets set SUPABASE_URL=... SUPABASE_ANON_KEY=...
   flyctl deploy
   ```

4. **Configure Claude Desktop**

   For local (STDIO):
   ```json
   {
     "mcpServers": {
       "workout": {
         "command": "uv",
         "args": ["run", "workout-mcp"],
         "env": {
           "SUPABASE_URL": "https://your-project.supabase.co",
           "SUPABASE_ANON_KEY": "your-anon-key"
         }
       }
     }
   }
   ```

   For remote (HTTP):
   ```json
   {
     "mcpServers": {
       "workout": {
         "url": "https://your-app.fly.dev/mcp",
         "transport": "http"
       }
     }
   }
   ```

## Usage Examples

### Progress Analysis

> "How's my bench press progress over the last 2 months?"

AI queries your performance history and provides data-driven analysis.

### Weight Suggestions

> "What weight should I use for squats today?"

AI suggests weight based on recent performance and progression scheme.

### Volume Check

> "Am I doing too much chest volume?"

AI compares your current volume to evidence-based landmarks (MEV/MAV/MRV).

### Plan Creation

> "Create me a 4-day upper/lower split for muscle growth"

AI generates a complete workout plan with volume validation.

### Deload Detection

> "Should I take a deload week?"

AI analyzes your recent training and recommends deload if needed.

## Documentation

- [Setup Guide](docs/setup.md)
- [Volume Landmarks](docs/volume_landmarks.md)
- [Creating Plans](docs/creating_plans.md)
- [API Reference](docs/api.md)
- [FAQ](docs/faq.md)

## Architecture

- **Backend**: Supabase (PostgreSQL + Auth)
- **MCP Server**: FastMCP (Python)
- **Hosting**: Fly.io (free tier)
- **Client**: Claude Desktop or any MCP-compatible client

## Contributing

Contributions welcome! See [CONTRIBUTING.md](CONTRIBUTING.md)

## License

MIT License - see [LICENSE](LICENSE)

## Support

- [GitHub Discussions](https://github.com/yourusername/workout-mcp/discussions)
- [Issue Tracker](https://github.com/yourusername/workout-mcp/issues)

## Credits

- Volume landmarks based on Dr. Mike Israetel's research (Renaissance Periodization)
- Built with [FastMCP](https://github.com/jlowin/fastmcp)
- Database hosted on [Supabase](https://supabase.com)
```

### 4. Demo Video

Create 5-10 minute demo video showing:

1. Installation process
2. Supabase setup
3. Claude Desktop configuration
4. Example conversations:
   - Progress analysis
   - Volume check
   - Plan creation
   - Deload suggestion
5. How to deploy to Fly.io

Upload to YouTube and embed in README.

### 5. Screenshots

Create professional screenshots:
- Claude Desktop with workout conversation
- Volume analysis output
- Generated workout plan
- Performance charts

### 6. Publishing Process

#### PyPI Publication

```bash
# Build package
uv build

# Test on PyPI test server first
uv publish --repository testpypi

# Publish to PyPI
uv publish
```

#### MCP Registry Registration

```bash
# Install mcp-publisher CLI
curl -sSL https://registry.mcp.io/install.sh | sh

# Login with GitHub
mcp-publisher login

# Publish server
mcp-publisher publish server.json
```

### 7. Support Infrastructure

#### GitHub Discussions

Enable and set up categories:
- Q&A (for questions)
- Show and Tell (user success stories)
- Ideas (feature requests)
- General

#### Issue Templates

Create `.github/ISSUE_TEMPLATE/`:

**bug_report.md**:
```markdown
---
name: Bug Report
about: Report a bug
---

**Describe the bug**
A clear description of the bug.

**To Reproduce**
Steps to reproduce:
1. ...

**Expected behavior**
What you expected to happen.

**Environment**
- Python version:
- FastMCP version:
- Supabase:
- Client (Claude Desktop/other):

**Additional context**
Logs, screenshots, etc.
```

**feature_request.md**:
```markdown
---
name: Feature Request
about: Suggest a new feature
---

**Feature description**
What feature would you like?

**Use case**
Why is this useful?

**Alternatives considered**
What alternatives have you considered?
```

## Testing Before Publication

### 1. Fresh Install Test

Test complete setup from scratch:
1. New Supabase project
2. Install from TestPyPI
3. Configure OAuth
4. Deploy to Fly.io
5. Test all features

### 2. Documentation Review

- [ ] All setup steps work
- [ ] No broken links
- [ ] Code examples are correct
- [ ] Screenshots are up to date
- [ ] Video is accessible

### 3. External Beta Testing

Invite 5-10 users to test:
- Provide beta access
- Collect feedback
- Fix critical issues
- Update documentation

## Acceptance Criteria

- [ ] PyPI package published successfully
- [ ] MCP registry listing approved and live
- [ ] README comprehensive and clear
- [ ] Demo video published and embedded
- [ ] At least 5 screenshots
- [ ] All documentation links working
- [ ] GitHub Discussions enabled
- [ ] Issue templates created
- [ ] Beta tested by 5+ external users
- [ ] Critical bugs fixed
- [ ] Server installable via `mcp install`

## Marketing & Outreach

### Announcement Plan

1. **Hacker News** - "Show HN: AI Workout Coach via MCP"
2. **Reddit** - r/fitness, r/bodybuilding, r/leangains, r/ClaudeAI
3. **Twitter/X** - Thread with demo video
4. **Dev.to** - Blog post about building MCP servers
5. **MCP Discord** - Announce in #showcase channel

### Blog Post

Write detailed post:
- "Building an AI Workout Coach with Model Context Protocol"
- Technical architecture
- Challenges and solutions
- Volume landmarks implementation
- Lessons learned

## Maintenance Plan

### Post-Launch

- Monitor GitHub issues daily (first week)
- Respond to discussions within 48h
- Update documentation based on common questions
- Fix critical bugs within 24h
- Monthly releases with improvements

### Versioning

Follow semantic versioning:
- 1.0.0 - Initial release
- 1.0.x - Bug fixes
- 1.x.0 - New features
- 2.0.0 - Breaking changes

## Cost Estimate

- **PyPI**: Free
- **MCP Registry**: Free
- **Documentation hosting** (GitHub Pages): Free
- **Video hosting** (YouTube): Free
- **Total**: $0

## Success Metrics

Track after 3 months:
- [ ] PyPI downloads > 100
- [ ] GitHub stars > 50
- [ ] Active users > 10
- [ ] Issues closed > 20
- [ ] Positive feedback from community

## Future Enhancements

After successful launch:
- Blog integration (progress tracking)
- Strava integration
- Advanced analytics
- Community-contributed plan templates
- Mobile app with MCP integration

## References

- [MCP Registry Documentation](https://github.com/modelcontextprotocol/registry)
- [PyPI Packaging Guide](https://packaging.python.org/en/latest/)
- [FastMCP Examples](https://github.com/jlowin/fastmcp/tree/main/examples)
- Phase 3: ISSUE_phase3_user_plans_volume.md
- Epic: EPIC_mcp_integration.md

## Related Issues

- Depends on: Phase 3 #XXX
- Related: EPIC #XXX
