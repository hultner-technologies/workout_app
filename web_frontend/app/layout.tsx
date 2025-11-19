import type { Metadata } from "next";

import "./globals.css";

export const metadata: Metadata = {
  title: "GymR8 - Smart Workout Tracking & Progress Analytics",
  description: "Track your workouts, visualize your progress, and crush your personal records with GymR8 - the intelligent fitness platform for serious athletes.",
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
