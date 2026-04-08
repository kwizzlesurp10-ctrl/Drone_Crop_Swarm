import type { Metadata } from 'next';
import './globals.css';

export const metadata: Metadata = {
  title: 'AetherAg Orbit - Precision Agriculture Dashboard',
  description: 'AI-powered drone swarm management for precision agriculture',
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
