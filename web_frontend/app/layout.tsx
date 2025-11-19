import type { Metadata } from "next";

import "./globals.css";

export const metadata: Metadata = {
  title: "Workout App - Track Your Fitness",
  description: "Track your workouts and monitor your progress",
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
