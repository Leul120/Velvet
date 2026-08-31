'use client';

import React from 'react';
import { Server, Activity } from 'lucide-react';
import { useAdminEvents } from '@/lib/useAdminEvents';


interface HeaderProps {
  title: string;
  subtitle?: string;
}

export function Header({ title, subtitle }: HeaderProps) {
  const { isConnected } = useAdminEvents();

  return (
    <header className="h-16 bg-[#0e0e11]/80 backdrop-blur-md border-b border-zinc-800 px-8 flex items-center justify-between sticky top-0 z-30">
      <div>
        <h2 className="text-lg font-bold text-zinc-100">{title}</h2>
        {subtitle && <p className="text-xs text-zinc-400">{subtitle}</p>}
      </div>

      <div className="flex items-center gap-3">
        {/* SSE Live Stream Status */}
        <div className="flex items-center gap-2 px-3 py-1.5 rounded-full bg-zinc-900 border border-zinc-800 text-xs font-medium text-zinc-300">
          <Activity className={`w-3.5 h-3.5 ${isConnected ? 'text-emerald-400' : 'text-zinc-500'}`} />
          <span>{isConnected ? 'SSE Live Stream Active' : 'Connecting Stream...'}</span>
          <div className={`w-2 h-2 rounded-full ml-1 ${isConnected ? 'bg-emerald-500 animate-pulse' : 'bg-zinc-600'}`} />
        </div>

        {/* Backend status indicator */}
        <div className="flex items-center gap-2 px-3 py-1.5 rounded-full bg-zinc-900 border border-zinc-800 text-xs font-medium text-zinc-300">
          <Server className="w-3.5 h-3.5 text-orange-400" />
          <span>Spring Boot API</span>
        </div>
      </div>
    </header>
  );
}

