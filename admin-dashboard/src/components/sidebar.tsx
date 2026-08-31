'use client';

import React from 'react';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { 
  LayoutDashboard, 
  CreditCard, 
  Users, 
  ShieldAlert, 
  Building2, 
  LogOut, 
  Crown
} from 'lucide-react';
import { useAuth } from '@/lib/auth-context';

const navigation = [
  { name: 'Overview', href: '/', icon: LayoutDashboard },
  { name: 'Payment Queue', href: '/payments', icon: CreditCard, badge: 'CBE Review' },
  { name: 'Members', href: '/members', icon: Users },
  { name: 'Safety & Panics', href: '/safety', icon: ShieldAlert },
  { name: 'Venues & Invites', href: '/venues', icon: Building2 },
];

export function Sidebar() {
  const pathname = usePathname();
  const { logout } = useAuth();

  return (
    <aside className="w-64 bg-[#0e0e11] border-r border-zinc-800 flex flex-col justify-between h-screen sticky top-0">
      <div>
        {/* Brand Header */}
        <div className="p-6 border-b border-zinc-800 flex items-center gap-3">
          <div className="w-9 h-9 rounded-xl bg-gradient-to-tr from-orange-600 to-amber-500 flex items-center justify-center shadow-lg shadow-orange-500/20">
            <Crown className="w-5 h-5 text-white" />
          </div>
          <div>
            <h1 className="font-bold text-lg text-zinc-100 tracking-wider">VELVET</h1>
            <p className="text-xs text-zinc-400 font-medium">Admin Control Center</p>
          </div>
        </div>

        {/* Navigation Links */}
        <nav className="p-4 space-y-1.5">
          {navigation.map((item) => {
            const isActive = pathname === item.href;
            const Icon = item.icon;
            return (
              <Link
                key={item.name}
                href={item.href}
                className={`flex items-center justify-between px-3.5 py-2.5 rounded-xl text-sm font-medium transition-all ${
                  isActive
                    ? 'bg-orange-600/15 text-orange-400 border border-orange-500/30'
                    : 'text-zinc-400 hover:text-zinc-200 hover:bg-zinc-800/60'
                }`}
              >
                <div className="flex items-center gap-3">
                  <Icon className={`w-4 h-4 ${isActive ? 'text-orange-400' : 'text-zinc-400'}`} />
                  <span>{item.name}</span>
                </div>
                {item.badge && (
                  <span className="text-[10px] font-bold px-2 py-0.5 rounded-full bg-orange-500/20 text-orange-400 border border-orange-500/30">
                    {item.badge}
                  </span>
                )}
              </Link>
            );
          })}
        </nav>
      </div>

      {/* Footer / Logout */}
      <div className="p-4 border-t border-zinc-800">
        <button
          onClick={logout}
          className="w-full flex items-center gap-3 px-3.5 py-2.5 rounded-xl text-sm font-medium text-zinc-400 hover:text-red-400 hover:bg-red-500/10 transition-all border border-transparent hover:border-red-500/20"
        >
          <LogOut className="w-4 h-4" />
          <span>Sign Out</span>
        </button>
      </div>
    </aside>
  );
}
