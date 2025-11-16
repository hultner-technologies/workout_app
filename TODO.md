# GymR8 TODO & Backlog

**Last Updated:** 2025-11-16
**Branch:** `claude/supabase-auth-research-01PkSeSy76eJxXtwayW79bKS`

## Phase 1: Core Authentication (9/11 Complete)

### Remaining Tasks

- [ ] **1.6** Test migrations on local/dev database
  - Requires Supabase project setup
  - Deploy migrations in order: 025, 026, 027, 265
  - Run integration tests in `test_supabase_auth_integration.py`
  - Verify trigger creates app_user on signup
  - Test username generation (auto + custom)

- [ ] **1.11** Deploy to production
  - Follow SUPABASE_SETUP.md deployment guide
  - Configure email confirmation in dashboard
  - Set up custom SMTP (production)
  - Set redirect URLs
  - Run security checklist
  - Verify RLS policies with `debug_rls_performance()`

### Completed ✅

- ✅ 1.1-1.4: All SQL migrations created
- ✅ 1.5: Email confirmation setup documented
- ✅ 1.7-1.8: Integration guides and migration docs
- ✅ 1.9: 23 comprehensive tests written
- ✅ 1.10: README and setup documentation

**Commit Reference:** `5b6d030` - All Phase 1 implementation and docs

---

## Phase 2: Advanced Features (Backlog)

### High Priority

#### 2.2 Admin Impersonation System ⭐
**Status:** Design phase

**Requirements:**
- Session-based user switching (not just RLS bypass)
- Admin can "become" another user from admin UI
- All queries run as target user (RLS enforced)
- Admin can switch back to own session
- Audit logging for all impersonation events
- Security: Restrict to specific admin role
- UI indicator showing impersonation mode
- Session timeout for impersonated sessions

**Design Decisions Needed:**
- [ ] Admin role structure (dedicated table vs app_user flag?)
- [ ] Session management approach (set_config vs custom JWT claims?)
- [ ] Audit log schema
- [ ] Frontend flow and UI/UX
- [ ] Security restrictions and permissions

**References:**
- SUPABASE_AUTH_INTEGRATION_PLAN.md section 2.2
- Supabase session management docs

---

#### 2.6 Username Change Functionality
**Status:** Not started

**Requirements:**
- Self-service username change
- Rate limiting (e.g., once per 30 days)
- Username history for link preservation
- Phase 1: Manual via admin/support
- Phase 2: Self-service with rate limiting

**Implementation:**
- [ ] Add `username_updated_at` timestamp column
- [ ] Create `username_history` table
- [ ] Implement rate limiting logic
- [ ] Create change_username() function
- [ ] Add RLS policies for username changes
- [ ] Frontend UI for username change

---

### Medium Priority

#### 2.1 OAuth Providers
**Status:** Not started

**Providers:**
- ✅ Apple (required for iOS App Store)
- ✅ Google
- ⚠️ GitHub (nice-to-have)

**Tasks:**
- [ ] Create OAuth apps in provider dashboards
- [ ] Configure in Supabase project settings
- [ ] Update handle_new_user() trigger for OAuth metadata
- [ ] Test username generation with OAuth signups
- [ ] Document OAuth setup in SUPABASE_SETUP.md

---

#### 2.7 Custom SMTP for Production
**Status:** Not started

**Options:**
- SendGrid (100 emails/day free)
- Mailgun (5,000 emails/month free)
- AWS SES (62,000 emails/month free)
- Postmark (100 emails/month free)

**Tasks:**
- [ ] Choose SMTP provider
- [ ] Set up account and verify domain
- [ ] Configure in Supabase Dashboard
- [ ] Test email delivery
- [ ] Monitor delivery rates

---

### Low Priority / Future

#### 2.3-2.5 Impersonation Implementation
**Status:** Blocked by 2.2 (design)

Depends on completing admin impersonation design first.

- [ ] 2.3: Implement impersonation backend
- [ ] 2.4: Implement impersonation frontend
- [ ] 2.5: Add audit logging

---

## Technical Debt / Nice-to-Have

### Security Enhancements

- [ ] Add 2FA/MFA support
- [ ] Implement session device tracking
- [ ] Add IP-based rate limiting
- [ ] Implement suspicious login detection
- [ ] Add session revocation endpoint

### Developer Experience

- [ ] Set up local Supabase development environment
- [ ] Create database seeding scripts
- [ ] Add database backup automation
- [ ] Create migration rollback scripts
- [ ] Add pre-commit hooks for SQL linting

### Testing

- [ ] Increase test coverage (currently schema/unit tests only)
- [ ] Add performance benchmarks
- [ ] Create load testing scenarios
- [ ] Add E2E tests with frontend
- [ ] Test concurrent signup scenarios

### Monitoring & Observability

- [ ] Set up error tracking (Sentry/etc)
- [ ] Add custom analytics events
- [ ] Create admin dashboard for user stats
- [ ] Monitor username generation patterns
- [ ] Track auth conversion rates

---

## Known Issues

None currently.

---

## Notes

- Phase 1 implementation complete and ready for deployment
- All code committed to `claude/supabase-auth-research-01PkSeSy76eJxXtwayW79bKS`
- See SUPABASE_SETUP.md for deployment instructions
- See SUPABASE_AUTH_INTEGRATION_PLAN.md for detailed planning and changelog
