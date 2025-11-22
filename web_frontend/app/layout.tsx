import type { Metadata } from "next";

import "./globals.css";

const siteUrl = process.env.NEXT_PUBLIC_SITE_URL || "http://localhost:3000";
const siteName = "GymR8";
const siteDescription = "Track your workouts, visualize your progress, and crush your personal records with GymR8 - the intelligent fitness platform for serious athletes.";

export const metadata: Metadata = {
  title: "GymR8 - Smart Workout Tracking & Progress Analytics",
  description: siteDescription,
  keywords: ["workout tracking", "fitness app", "gym log", "exercise tracker", "personal records", "workout analytics", "strength training"],
  authors: [{ name: "GymR8 Team" }],
  creator: siteName,
  publisher: siteName,
  metadataBase: new URL(siteUrl),
  openGraph: {
    type: "website",
    locale: "en_US",
    url: "/",
    title: "GymR8 - Smart Workout Tracking & Progress Analytics",
    description: siteDescription,
    siteName: siteName,
    // Add images when available:
    // images: [
    //   {
    //     url: '/og-image.png',
    //     width: 1200,
    //     height: 630,
    //     alt: 'GymR8 - Smart Workout Tracking',
    //   },
    // ],
  },
  // Twitter/X Card metadata (optional - configure when social handle is available)
  // twitter: {
  //   card: "summary_large_image",
  //   title: "GymR8 - Smart Workout Tracking & Progress Analytics",
  //   description: siteDescription,
  //   creator: process.env.NEXT_PUBLIC_TWITTER_HANDLE, // e.g., "@gymr8app"
  //   images: ['/og-image.png'],
  // },
  robots: {
    index: true,
    follow: true,
    googleBot: {
      index: true,
      follow: true,
      "max-video-preview": -1,
      "max-image-preview": "large",
      "max-snippet": -1,
    },
  },
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body className="min-h-screen bg-background text-foreground antialiased">
        {children}
      </body>
    </html>
  );
}
