import type { Metadata } from 'next';
import './globals.css';
import { AuthProvider } from '@/lib/auth-context';

export const metadata: Metadata = {
  title: 'VELVET Admin Dashboard',
  description: 'Payment Verification & Concierge Operations Center',
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" className="dark">
      <body className="bg-[#09090b] text-zinc-100 antialiased selection:bg-orange-500/30 selection:text-orange-200">
        <AuthProvider>{children}</AuthProvider>
      </body>
    </html>
  );
}
