'use client';

import React, { useEffect, useState } from 'react';
import { Sidebar } from '@/components/sidebar';
import { Header } from '@/components/header';
import { StatsCard } from '@/components/stats-card';
import { CreditCard, Users, ShieldAlert, DollarSign, ArrowRight, RefreshCw, Clock } from 'lucide-react';
import { fetchPayments, fetchMembers, fetchPanics } from '@/lib/api';
import { PaymentIntentAdminItem } from '@/lib/types';
import Link from 'next/link';

export default function DashboardOverviewPage() {
  const [pendingCount, setPendingCount] = useState<number>(0);
  const [paidCount, setPaidCount] = useState<number>(0);
  const [memberCount, setMemberCount] = useState<number>(0);
  const [panicCount, setPanicCount] = useState<number>(0);
  const [revenueEtb, setRevenueEtb] = useState<number>(0);
  const [recentPending, setRecentPending] = useState<PaymentIntentAdminItem[]>([]);
  const [loading, setLoading] = useState(true);

  const loadDashboard = async () => {
    setLoading(true);
    try {
      const [allPayments, members, panics] = await Promise.all([
        fetchPayments('ALL', 0, 100),
        fetchMembers(),
        fetchPanics(),
      ]);

      const pending = allPayments.filter((p) => p.status === 'CHECKOUT' || p.status === 'PENDING');
      const paid = allPayments.filter((p) => p.status === 'PAID');
      const totalRev = paid.reduce((acc, p) => acc + (p.amountEtb || 0), 0);

      setPendingCount(pending.length);
      setPaidCount(paid.length);
      setRevenueEtb(totalRev);
      setRecentPending(pending.slice(0, 5));
      setMemberCount(members.length);
      setPanicCount(panics.filter((p) => p.status === 'OPEN').length);
    } catch (err) {
      console.error('Failed to load dashboard stats:', err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadDashboard();
  }, []);

  return (
    <div className="flex min-h-screen">
      <Sidebar />

      <main className="flex-1 flex flex-col min-w-0">
        <Header title="Dashboard Overview" subtitle="Real-time payment verification queue & system operations" />

        <div className="p-8 space-y-8 flex-1">
          {/* Top Actions Bar */}
          <div className="flex items-center justify-between">
            <div>
              <h3 className="text-xl font-black text-zinc-100">Welcome to VELVET Operations</h3>
              <p className="text-xs text-zinc-400 mt-1">Review pending CBE receipt screenshots and manage members.</p>
            </div>
            <button
              onClick={loadDashboard}
              disabled={loading}
              className="flex items-center gap-2 px-4 py-2 rounded-xl bg-zinc-900 border border-zinc-800 text-xs font-semibold text-zinc-300 hover:text-zinc-100 hover:border-zinc-700 transition-all"
            >
              <RefreshCw className={`w-3.5 h-3.5 ${loading ? 'animate-spin' : ''}`} />
              <span>Refresh Stats</span>
            </button>
          </div>

          {/* Metric Stats Cards */}
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5">
            <StatsCard
              title="Pending Reviews"
              value={pendingCount}
              subtitle="CBE Receipt Proofs awaiting verification"
              icon={CreditCard}
              color="orange"
            />
            <StatsCard
              title="Total Revenue"
              value={`${revenueEtb.toLocaleString()} ETB`}
              subtitle={`${paidCount} Verified Payments`}
              icon={DollarSign}
              color="emerald"
            />
            <StatsCard
              title="Active Members"
              value={memberCount}
              subtitle="Total onboarded performers & members"
              icon={Users}
              color="amber"
            />
            <StatsCard
              title="Safety Panics"
              value={panicCount}
              subtitle={panicCount > 0 ? "URGENT OPEN ALERTS" : "No open panic alerts"}
              icon={ShieldAlert}
              color={panicCount > 0 ? "red" : "blue"}
            />
          </div>

          {/* Pending Payment Verification Queue Preview Banner */}
          <div className="bg-[#121215] border border-zinc-800 rounded-3xl p-6 shadow-sm">
            <div className="flex items-center justify-between pb-4 border-b border-zinc-800/80">
              <div className="flex items-center gap-3">
                <div className="p-2 rounded-xl bg-orange-500/10 border border-orange-500/20 text-orange-400">
                  <Clock className="w-5 h-5" />
                </div>
                <div>
                  <h4 className="font-bold text-zinc-100">Pending Receipt Verification Queue</h4>
                  <p className="text-xs text-zinc-400">Members uploaded receipts pending admin approval</p>
                </div>
              </div>

              <Link
                href="/payments"
                className="inline-flex items-center gap-1.5 text-xs font-bold text-orange-400 hover:text-orange-300 bg-orange-500/10 px-3.5 py-2 rounded-xl border border-orange-500/20 transition-all"
              >
                <span>View Full Queue ({pendingCount})</span>
                <ArrowRight className="w-3.5 h-3.5" />
              </Link>
            </div>

            <div className="mt-4">
              {recentPending.length === 0 ? (
                <div className="text-center py-8 text-zinc-500 text-sm">
                  No pending payment proofs awaiting review right now.
                </div>
              ) : (
                <div className="divide-y divide-zinc-800/60">
                  {recentPending.map((p) => (
                    <div key={p.id} className="py-3.5 flex items-center justify-between hover:bg-zinc-900/40 px-3 rounded-xl transition-all">
                      <div>
                        <div className="flex items-center gap-2">
                          <span className="font-semibold text-sm text-zinc-200">{p.userName}</span>
                          <span className="text-[10px] font-bold px-2 py-0.5 rounded bg-zinc-800 text-zinc-400 border border-zinc-700">
                            {p.purpose}
                          </span>
                        </div>
                        <p className="text-xs text-zinc-400 mt-0.5">
                          Phone: <span className="font-mono">{p.userPhone || 'N/A'}</span> • FT Code: <span className="font-mono text-orange-400">{p.providerRef || 'Uploaded Image'}</span>
                        </p>
                      </div>

                      <div className="flex items-center gap-4">
                        <span className="text-base font-bold text-emerald-400">{p.amountEtb} ETB</span>
                        <Link
                          href="/payments"
                          className="px-3 py-1.5 rounded-lg bg-orange-600 hover:bg-orange-500 text-white font-semibold text-xs transition-all shadow-md shadow-orange-600/20"
                        >
                          Verify Proof
                        </Link>
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </div>
          </div>
        </div>
      </main>
    </div>
  );
}
