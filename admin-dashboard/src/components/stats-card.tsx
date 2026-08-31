import React from 'react';

interface StatsCardProps {
  title: string;
  value: string | number;
  subtitle?: string;
  icon: React.ComponentType<{ className?: string }>;
  color?: 'orange' | 'emerald' | 'amber' | 'red' | 'blue';
}


export function StatsCard({ title, value, subtitle, icon: Icon, color = 'orange' }: StatsCardProps) {
  const colorStyles = {
    orange: 'bg-orange-500/10 text-orange-400 border-orange-500/20',
    emerald: 'bg-emerald-500/10 text-emerald-400 border-emerald-500/20',
    amber: 'bg-amber-500/10 text-amber-400 border-amber-500/20',
    red: 'bg-red-500/10 text-red-400 border-red-500/20',
    blue: 'bg-blue-500/10 text-blue-400 border-blue-500/20',
  };

  return (
    <div className="bg-[#121215] border border-zinc-800 rounded-2xl p-5 shadow-sm hover:border-zinc-700 transition-all">
      <div className="flex items-center justify-between">
        <span className="text-xs font-semibold text-zinc-400 uppercase tracking-wider">{title}</span>
        <div className={`p-2 rounded-xl border ${colorStyles[color]}`}>
          <Icon className="w-4 h-4" />
        </div>
      </div>
      <div className="mt-4">
        <div className="text-2xl font-black text-zinc-100 tracking-tight">{value}</div>
        {subtitle && <p className="text-xs text-zinc-400 mt-1">{subtitle}</p>}
      </div>
    </div>
  );
}
