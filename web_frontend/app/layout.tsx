import type { Metadata } from "next";

import "./globals.css";

export const metadata: Metadata = {
  title: "GymR8 - Smart Workout Tracking & Progress Analytics",
  description: "Track your workouts, visualize your progress, and crush your personal records with GymR8 - the intelligent fitness platform for serious athletes.",
  keywords: ["workout tracking", "fitness app", "gym log", "exercise tracker", "personal records", "workout analytics", "strength training"],
  authors: [{ name: "GymR8 Team" }],
  creator: "GymR8",
  publisher: "GymR8",
  metadataBase: new URL(process.env.NEXT_PUBLIC_SITE_URL || "https://gymr8.app"),
  openGraph: {
    type: "website",
    locale: "en_US",
    url: "/",
    title: "GymR8 - Smart Workout Tracking & Progress Analytics",
    description: "Track your workouts, visualize your progress, and crush your personal records with GymR8 - the intelligent fitness platform for serious athletes.",
    siteName: "GymR8",
  },
  twitter: {
    card: "summary_large_image",
    title: "GymR8 - Smart Workout Tracking & Progress Analytics",
    description: "Track your workouts, visualize your progress, and crush your personal records with GymR8 - the intelligent fitness platform for serious athletes.",
    creator: "@gymr8app",
  },
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
