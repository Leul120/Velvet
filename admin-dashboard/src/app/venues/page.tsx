'use client';

import React, { useEffect, useState } from 'react';
import { Sidebar } from '@/components/sidebar';
import { Header } from '@/components/header';
import { fetchVenues, fetchInvites, createInvite } from '@/lib/api';
import { VenueAdminResponse, InviteResponse } from '@/lib/types';
import { Building2, Key, RefreshCw, Plus, CheckCircle2, Ticket } from 'lucide-react';

export default function VenuesPage() {
  const [venues, setVenues] = useState<VenueAdminResponse[]>([]);
  const [invites, setInvites] = useState<InviteResponse[]>([]);
  const [loading, setLoading] = useState(true);

  const [newInviteCode, setNewInviteCode] = useState('');
  const [maxUses, setMaxUses] = useState(100);
  const [creatingInvite, setCreatingInvite] = useState(false);

  const loadData = async () => {
    setLoading(true);
    try {
      const [vData, iData] = await Promise.all([
        fetchVenues(),
        fetchInvites(),
      ]);
      setVenues(vData);
      setInvites(iData);
    } catch (err) {
      console.error('Failed to load venues/invites:', err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadData();
  }, []);

  const handleCreateInvite = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!newInviteCode.trim()) return;
    setCreatingInvite(true);
    try {
      await createInvite(newInviteCode.trim(), maxUses);
      setNewInviteCode('');
      await loadData();
    } catch (err) {
      alert((err as Error).message);
    } finally {
      setCreatingInvite(false);
    }
  };

  return (
    <div className="flex min-h-screen bg-[#09090b]">
      <Sidebar />

      <main className="flex-1 flex flex-col min-w-0">
        <Header title="Venues & Invites" subtitle="Manage curated partner venues and VIP invite bootstrap codes" />

        <div className="p-8 space-y-8 flex-1">
          {/* Top Refresh */}
          <div className="flex items-center justify-between">
            <h3 className="text-xl font-black text-zinc-100">Partners & Access Codes</h3>
            <button
              onClick={loadData}
              disabled={loading}
              className="flex items-center gap-2 px-4 py-2 rounded-xl bg-[#121215] border border-zinc-800 text-xs font-semibold text-zinc-300 hover:text-zinc-100 transition-all"
            >
              <RefreshCw className={`w-3.5 h-3.5 ${loading ? 'animate-spin' : ''}`} />
              <span>Refresh</span>
            </button>
          </div>

          {/* Invites Creation & List Section */}
          <div className="bg-[#121215] border border-zinc-800 rounded-3xl p-6 shadow-sm">
            <div className="flex items-center justify-between pb-4 border-b border-zinc-800">
              <div className="flex items-center gap-3">
                <div className="p-2 rounded-xl bg-orange-500/10 border border-orange-500/20 text-orange-400">
                  <Ticket className="w-5 h-5" />
                </div>
                <div>
                  <h4 className="font-bold text-zinc-100">Invite Bootstrap Codes</h4>
                  <p className="text-xs text-zinc-400">Exclusive invite codes for new member registration</p>
                </div>
              </div>
            </div>

            {/* Create Invite Form */}
            <form onSubmit={handleCreateInvite} className="mt-4 flex flex-col sm:flex-row items-center gap-3">
              <input
                type="text"
                value={newInviteCode}
                onChange={(e) => setNewInviteCode(e.target.value.toUpperCase())}
                placeholder="e.g. VELVETVIP2026"
                required
                className="flex-1 bg-zinc-900 border border-zinc-800 rounded-xl px-4 py-2.5 text-xs text-zinc-100 font-mono focus:outline-none focus:border-orange-500/50"
              />
              <input
                type="number"
                value={maxUses}
                onChange={(e) => setMaxUses(parseInt(e.target.value) || 1)}
                placeholder="Max Uses"
                min={1}
                className="w-28 bg-zinc-900 border border-zinc-800 rounded-xl px-3 py-2.5 text-xs text-zinc-100 focus:outline-none"
              />
              <button
                type="submit"
                disabled={creatingInvite}
                className="px-4 py-2.5 rounded-xl bg-orange-600 hover:bg-orange-500 text-white font-bold text-xs shadow-md shadow-orange-600/20 transition-all flex items-center gap-1.5 shrink-0"
              >
                <Plus className="w-4 h-4" />
                <span>{creatingInvite ? 'Creating...' : 'Create Invite'}</span>
              </button>
            </form>

            {/* Invites Grid */}
            <div className="mt-6 grid grid-cols-1 md:grid-cols-3 gap-4">
              {invites.map((inv) => (
                <div key={inv.id} className="p-4 rounded-2xl bg-zinc-900/60 border border-zinc-800">
                  <div className="flex items-center justify-between">
                    <span className="font-mono font-bold text-orange-400 text-sm">{inv.code}</span>
                    <span className={`text-[10px] font-bold px-2 py-0.5 rounded ${inv.active ? 'bg-emerald-500/10 text-emerald-400 border border-emerald-500/20' : 'bg-zinc-800 text-zinc-500'}`}>
                      {inv.active ? 'ACTIVE' : 'INACTIVE'}
                    </span>
                  </div>
                  <div className="mt-2 text-xs text-zinc-400">
                    Uses: <span className="font-bold text-zinc-200">{inv.usesCount} / {inv.maxUses}</span>
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* Venues Section */}
          <div className="bg-[#121215] border border-zinc-800 rounded-3xl p-6 shadow-sm">
            <div className="flex items-center gap-3 pb-4 border-b border-zinc-800">
              <div className="p-2 rounded-xl bg-amber-500/10 border border-amber-500/20 text-amber-400">
                <Building2 className="w-5 h-5" />
              </div>
              <div>
                <h4 className="font-bold text-zinc-100">Curated Partner Venues</h4>
                <p className="text-xs text-zinc-400">Exclusive lounges, clubs, and hotels for member bookings</p>
              </div>
            </div>

            <div className="mt-4 grid grid-cols-1 md:grid-cols-2 gap-4">
              {venues.map((v) => (
                <div key={v.id} className="p-4 rounded-2xl bg-zinc-900/60 border border-zinc-800 flex items-center justify-between">
                  <div>
                    <h5 className="font-bold text-zinc-100 text-sm">{v.name}</h5>
                    <p className="text-xs text-zinc-400 mt-0.5">{v.neighborhood} • {v.address}</p>
                    {v.perksNote && <p className="text-xs text-amber-400/90 italic mt-1">{v.perksNote}</p>}
                  </div>
                  <span className={`text-xs font-bold px-2.5 py-1 rounded-full border ${v.active ? 'bg-emerald-500/15 text-emerald-400 border-emerald-500/30' : 'bg-zinc-800 text-zinc-500 border-zinc-700'}`}>
                    {v.active ? 'Active' : 'Inactive'}
                  </span>
                </div>
              ))}
            </div>
          </div>
        </div>
      </main>
    </div>
  );
}
