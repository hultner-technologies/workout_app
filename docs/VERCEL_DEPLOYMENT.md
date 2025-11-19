# Vercel Deployment Guide

## Overview

This guide explains how to deploy the Next.js web frontend to Vercel with CI/CD integration.

---

## Prerequisites

1. **Vercel Account** - Sign up at https://vercel.com
2. **GitHub Repository** - Code must be in a GitHub repo
3. **Supabase Project** - Production Supabase instance ready
4. **Environment Variables** - Supabase URL and Anon Key

---

## Manual Deployment (Quick Start)

### 1. Connect Repository to Vercel

1. Visit https://vercel.com/new
2. Import your Git repository
3. Select the `web_frontend` directory as the root
4. Configure project settings:
   - **Framework Preset:** Next.js
   - **Root Directory:** `web_frontend`
   - **Build Command:** `npm run build`
   - **Output Directory:** `.next`
   - **Install Command:** `npm install`

### 2. Configure Environment Variables

In Vercel project settings → Environment Variables, add:

| Variable | Value | Environment |
|----------|-------|-------------|
| `NEXT_PUBLIC_SUPABASE_URL` | `https://your-project.supabase.co` | Production, Preview, Development |
| `NEXT_PUBLIC_SUPABASE_ANON_KEY` | `your-anon-key` | Production, Preview, Development |
| `NEXT_PUBLIC_SITE_URL` | `https://your-app.vercel.app` | Production |
| `NEXT_PUBLIC_SITE_URL` | `https://your-app-git-*.vercel.app` | Preview |

**Note:** Use different Supabase projects for production vs. preview if needed.

### 3. Deploy

Click **Deploy** and Vercel will:
1. Install dependencies
2. Run build
3. Deploy to global CDN
4. Provide deployment URL

---

## Automated CI/CD (Recommended)

### GitHub Actions Integration

The repository includes a GitHub Actions workflow (`.github/workflows/vercel-deploy.yml`) that automatically:

- ✅ Runs TypeScript type checking
- ✅ Runs ESLint
- ✅ Builds the project
- ✅ Deploys to Vercel Preview (on pull requests)
- ✅ Deploys to Vercel Production (on merges to main)
- ✅ Comments on PRs with deployment URLs

### Setup Instructions

#### 1. Get Vercel Credentials

```bash
# Install Vercel CLI globally
npm install -g vercel

# Login to Vercel
vercel login

# Link your project
cd web_frontend
vercel link

# This creates a .vercel directory with project info
```

After running `vercel link`, you'll find:
- **Org ID:** In `.vercel/project.json` as `orgId`
- **Project ID:** In `.vercel/project.json` as `projectId`

#### 2. Get Vercel Token

1. Visit https://vercel.com/account/tokens
2. Create new token
3. Give it a descriptive name (e.g., "GitHub Actions - Workout App")
4. Copy the token (you'll only see it once!)

#### 3. Add GitHub Secrets

Go to your GitHub repository → Settings → Secrets and variables → Actions

Add these secrets:

| Secret Name | Value | How to Get It |
|-------------|-------|---------------|
| `VERCEL_TOKEN` | `your-token` | From step 2 above |
| `VERCEL_ORG_ID` | `team_xxx` or `user_xxx` | From `.vercel/project.json` |
| `VERCEL_PROJECT_ID` | `prj_xxx` | From `.vercel/project.json` |
| `NEXT_PUBLIC_SUPABASE_URL` | `https://xxx.supabase.co` | Supabase dashboard |
| `NEXT_PUBLIC_SUPABASE_ANON_KEY` | `eyJ...` | Supabase dashboard |

#### 4. Trigger Deployment

Deployments trigger automatically on:
- **Pull Requests:** Creates preview deployment
- **Merges to main/master:** Creates production deployment

Manual trigger:
```bash
# Push to main branch
git checkout main
git pull
git push origin main
```

---

## Vercel Configuration

### vercel.json

The project includes a `vercel.json` file with:

```json
{
  "buildCommand": "npm run build",
  "framework": "nextjs",
  "regions": ["iad1"],
  "headers": [
    {
      "source": "/(.*)",
      "headers": [
        { "key": "X-Frame-Options", "value": "DENY" },
        { "key": "X-Content-Type-Options", "value": "nosniff" },
        { "key": "Referrer-Policy", "value": "strict-origin-when-cross-origin" },
        { "key": "X-XSS-Protection", "value": "1; mode=block" },
        { "key": "Permissions-Policy", "value": "camera=(), microphone=(), geolocation=()" }
      ]
    }
  ]
}
```

**Security Headers Explained:**
- **X-Frame-Options:** Prevents clickjacking
- **X-Content-Type-Options:** Prevents MIME sniffing
- **Referrer-Policy:** Controls referrer information
- **X-XSS-Protection:** Enables browser XSS filter
- **Permissions-Policy:** Disables unused browser features

### Regions

Currently set to `iad1` (US East). Update based on user location:
- `iad1` - Washington, D.C., USA
- `sfo1` - San Francisco, USA
- `lhr1` - London, UK
- `fra1` - Frankfurt, Germany
- `hnd1` - Tokyo, Japan
- `sin1` - Singapore

---

## Environment-Specific Configuration

### Production

**URL:** `https://your-app.vercel.app`

Environment variables:
```
NEXT_PUBLIC_SUPABASE_URL=https://production.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=production_key
NEXT_PUBLIC_SITE_URL=https://your-app.vercel.app
```

### Preview (Staging)

**URL:** `https://your-app-git-branch-name-team.vercel.app`

Environment variables:
```
NEXT_PUBLIC_SUPABASE_URL=https://staging.supabase.co (optional: use same as prod)
NEXT_PUBLIC_SUPABASE_ANON_KEY=staging_key
NEXT_PUBLIC_SITE_URL=https://your-app-git-*.vercel.app
```

### Development

**URL:** `http://localhost:3000`

Environment variables (`.env.local`):
```
NEXT_PUBLIC_SUPABASE_URL=http://127.0.0.1:54321
NEXT_PUBLIC_SUPABASE_ANON_KEY=local_key
NEXT_PUBLIC_SITE_URL=http://localhost:3000
```

---

## Deployment Workflow

### Pull Request Flow

1. Developer creates PR
2. GitHub Actions triggered
3. Code is type-checked and linted
4. Project is built
5. Deployed to Vercel Preview
6. PR comment added with preview URL
7. Team reviews on preview URL
8. PR approved and merged

### Production Deployment Flow

1. PR merged to main
2. GitHub Actions triggered
3. Code is type-checked, linted, and built
4. Deployed to Vercel Production with `--prod` flag
5. Production URL updated automatically
6. Zero-downtime deployment

---

## Vercel Dashboard

Access your project dashboard at:
```
https://vercel.com/your-team/your-project
```

### Key Sections

**Deployments Tab:**
- View all deployments (production and preview)
- Inspect build logs
- Rollback to previous versions
- Download build outputs

**Analytics Tab:**
- Page views and unique visitors
- Performance metrics (Core Web Vitals)
- Top pages and referrers

**Settings Tab:**
- Environment variables
- Domain configuration
- Build & Development settings
- Git integration

**Logs Tab:**
- Real-time function logs
- Error tracking
- Performance monitoring

---

## Custom Domains

### Add Custom Domain

1. Go to Vercel Dashboard → Settings → Domains
2. Add your domain (e.g., `app.example.com`)
3. Configure DNS:

**Option A: Vercel Nameservers (Recommended)**
```
ns1.vercel-dns.com
ns2.vercel-dns.com
```

**Option B: CNAME Record**
```
CNAME  app  cname.vercel-dns.com
```

4. Wait for DNS propagation (usually < 5 minutes)
5. Vercel automatically provisions SSL certificate

### Update Environment Variables

After adding custom domain:
```
NEXT_PUBLIC_SITE_URL=https://app.example.com
```

Update Supabase auth redirect URLs:
1. Supabase Dashboard → Authentication → URL Configuration
2. Add: `https://app.example.com/auth/callback`

---

## Monitoring and Debugging

### View Build Logs

```bash
# Via Vercel CLI
vercel logs your-deployment-url

# Or in Vercel Dashboard → Deployments → [deployment] → Build Logs
```

### View Runtime Logs

```bash
# Stream logs in real-time
vercel logs --follow your-deployment-url
```

### Common Issues

#### 1. Build Fails - Environment Variables

**Error:** `NEXT_PUBLIC_SUPABASE_URL is undefined`

**Fix:** Add environment variables in Vercel dashboard for all environments (Production, Preview, Development)

#### 2. Build Fails - Type Errors

**Error:** `Type error: Property 'X' does not exist`

**Fix:** Run `npm run type-check` locally first. Fix all TypeScript errors before pushing.

#### 3. Runtime Error - Supabase Connection

**Error:** `Error fetching data from Supabase`

**Fix:**
- Verify environment variables are correct
- Check Supabase project is running
- Verify RLS policies allow access

#### 4. Auth Callback Fails

**Error:** `Invalid redirect URL`

**Fix:**
- Add your Vercel URL to Supabase allowed redirect URLs
- Format: `https://your-app.vercel.app/auth/callback`

---

## Performance Optimization

### Vercel Analytics

Enable Vercel Analytics for performance insights:

1. Vercel Dashboard → Analytics → Enable
2. Monitors Core Web Vitals:
   - **LCP** (Largest Contentful Paint)
   - **FID** (First Input Delay)
   - **CLS** (Cumulative Layout Shift)

### Vercel Speed Insights

```bash
npm install @vercel/speed-insights
```

Add to layout:
```tsx
import { SpeedInsights } from "@vercel/speed-insights/next"

export default function RootLayout({ children }) {
  return (
    <html>
      <body>
        {children}
        <SpeedInsights />
      </body>
    </html>
  )
}
```

### Edge Caching

Next.js automatically caches static assets. For dynamic routes:

```tsx
export const revalidate = 60 // Revalidate every 60 seconds
```

---

## Security Checklist

Before going live:

- [ ] All environment variables set in Vercel
- [ ] Custom domain configured with HTTPS
- [ ] Supabase redirect URLs updated
- [ ] Security headers configured (already in vercel.json)
- [ ] RLS policies enabled in Supabase
- [ ] Email templates configured in Supabase
- [ ] Password reset flow tested end-to-end
- [ ] Error monitoring set up (e.g., Sentry)
- [ ] Rate limiting implemented (future)

---

## Rollback Strategy

### Automatic Rollback

If deployment fails during build:
- Previous deployment remains active
- No downtime

### Manual Rollback

1. Vercel Dashboard → Deployments
2. Find previous successful deployment
3. Click "⋯" → Promote to Production

Or via CLI:
```bash
vercel rollback
```

---

## Cost Optimization

### Free Tier Limits (Hobby Plan)

- 100 GB bandwidth/month
- 6,000 minutes build time/month
- 100 GB-hours serverless function execution
- Unlimited deployments

### Pro Plan ($20/month per member)

- 1 TB bandwidth/month
- 24,000 minutes build time/month
- 1,000 GB-hours serverless function execution
- Advanced analytics
- Password protection for previews

**Recommendation:** Start with Hobby plan, upgrade to Pro if needed.

---

## Support and Resources

- **Vercel Documentation:** https://vercel.com/docs
- **Next.js Documentation:** https://nextjs.org/docs
- **Supabase Documentation:** https://supabase.com/docs
- **Vercel Status:** https://vercel-status.com
- **Vercel Community:** https://github.com/vercel/next.js/discussions

---

## Troubleshooting

### Clear Build Cache

```bash
# Via CLI
vercel --force

# Or in Vercel Dashboard
Settings → General → Clear Build Cache
```

### Redeploy Latest Commit

```bash
# Trigger new deployment without code changes
vercel --prod --force
```

### Check Deployment Status

```bash
vercel ls
```

---

**Last Updated:** 2025-11-19
**Maintained By:** Workout App Team
