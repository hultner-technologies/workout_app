import { NextResponse } from "next/server";
import { createClient } from "@/lib/supabase/server";

export async function GET(request: Request) {
  const { searchParams, origin } = new URL(request.url);
  const code = searchParams.get("code");
  const type = searchParams.get("type");
  const next = searchParams.get("next") ?? "/profile";

  const site = process.env.NEXT_PUBLIC_SITE_URL;
  const siteOrigin =
    site && site.length > 0 ? new URL(site).origin : undefined;
  const redirectOrigin = siteOrigin ?? origin;

  const redirectUrl = type === "recovery"
    ? `${redirectOrigin}/update-password`
    : `${redirectOrigin}${next}`;

  if (code) {
    const supabase = await createClient();
    const { error } = await supabase.auth.exchangeCodeForSession(code);

    if (!error) {
      return NextResponse.redirect(redirectUrl);
    }
  }

  return NextResponse.redirect(
    `${redirectOrigin}/login?error=Unable to verify email`,
  );
}
