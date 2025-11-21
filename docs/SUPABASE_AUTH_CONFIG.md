# Supabase Auth Dashboard Configuration

## Overview

This document outlines required Auth configuration changes in the Supabase Dashboard that cannot be applied via SQL migrations.

**Status**: Manual configuration required
**Priority**: WARN level (Security enhancement)
**Reference**: Supabase Security Linter

---

## Configuration Changes Required

### 1. Enable Leaked Password Protection

**What**: Integration with HaveIBeenPwned to prevent use of compromised passwords

**Why**: Protects users from using passwords known to be compromised in data breaches

**How to Configure**:
1. Open Supabase Dashboard
2. Navigate to **Authentication** → **Settings**
3. Scroll to **Password Settings** section
4. Enable **"Check for leaked passwords"**
5. Save changes

**Impact**: Users will not be able to use passwords that appear in known breach databases

---

### 2. Enable Additional MFA Options

**What**: Multi-factor authentication options beyond the currently enabled methods

**Why**: Provides users with more security options and meets security best practices

**How to Configure**:
1. Open Supabase Dashboard
2. Navigate to **Authentication** → **Settings**
3. Scroll to **Multi-Factor Authentication** section
4. Review currently enabled methods
5. Enable additional recommended methods:
   - **Time-based One-Time Password (TOTP)** - Authenticator apps
   - **SMS** - If SMS provider configured
6. Save changes

**Impact**: Users will have access to additional MFA options for enhanced security

---

## Verification

After applying these changes:

1. **Test Leaked Password Protection**:
   - Try signing up with a known weak password (e.g., "password123")
   - Should be rejected with appropriate error message

2. **Test MFA Options**:
   - Check that MFA enrollment options appear for users
   - Verify users can enable MFA with newly enabled methods

---

## Notes

- These settings apply to all users in the project
- Existing users are not forced to change passwords or enable MFA
- Consider communicating changes to users before enabling

---

## Security Linter References

These configurations address warnings from the Supabase security linter:

- **Leaked Password Protection**: Prevents use of compromised passwords
- **MFA Options**: Ensures sufficient authentication factor options

---

## Related Documentation

- [Supabase Auth Documentation](https://supabase.com/docs/guides/auth)
- [Password Security Best Practices](https://supabase.com/docs/guides/auth/passwords)
- [Multi-Factor Authentication](https://supabase.com/docs/guides/auth/auth-mfa)
