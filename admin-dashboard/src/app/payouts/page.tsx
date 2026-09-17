'use client';

import React, { useEffect, useState, useCallback } from 'react';
import { Sidebar } from '@/components/sidebar';
import { Header } from '@/components/header';
import { fetchPayouts, completePayout, rejectPayout } from '@/lib/api';
import { AdminPayoutItem } from '@/lib/types';
import { 
  CheckCircle2, 
  XCircle, 
  Clock, 
  Search, 
  RefreshCw
} from 'lucide-react';

type FilterTab = 'REQUESTED' | 'COMPLETED' | 'REJECTED' | 'ALL';

export default function PayoutsQueuePage() {
  const [payouts, setPayouts] = useState<AdminPayoutItem[]>([]);
  const [activeTab, setActiveTab] = useState<FilterTab>('REQUESTED');
  const [searchTerm, setSearchTerm] = useState('');
  const [loading, setLoading] = useState(true);

  const [decisionItem, setDecisionItem] = useState<AdminPayoutItem | null>(null);
  const [decisionType, setDecisionType] = useState<'COMPLETE' | 'REJECT' | null>(null);
  const [notes, setNotes] = useState('');
  const [submitting, setSubmitting] = useState(false);

  const loadQueue = useCallback(async () => {
    setLoading(true);
    try {
      const data = await fetchPayouts(activeTab === 'ALL' ? undefined : activeTab);
      setPayouts(data);
    } catch (err) {
      console.error('Failed to load payouts:', err);
    } finally {
      setLoading(false);
    }
  }, [activeTab]);

  useEffect(() => {
    loadQueue();
  }, [loadQueue]);

  const handleDecisionConfirm = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!decisionItem || !decisionType) return;
    setSubmitting(true);
    try {
      if (decisionType === 'COMPLETE') {
        await completePayout(decisionItem.id, notes || 'Paid via Bank Transfer');
      } else {
        await rejectPayout(decisionItem.id, notes || 'Rejected by Admin');
      }
      setDecisionItem(null);
      setDecisionType(null);
      setNotes('');
      await loadQueue();
    } catch (err) {
      alert((err as Error).message);
    } finally {
      setSubmitting(false);
    }
  };

  const filteredPayouts = payouts.filter((p) => {
    if (!searchTerm) return true;
    const term = searchTerm.toLowerCase();
    return (
      p.displayName?.toLowerCase().includes(term) ||
      p.phone?.toLowerCase().includes(term) ||
      p.destinationNote?.toLowerCase().includes(term) ||
      p.amountEtb?.toString().includes(term)
    );
  });

  return (
    <div className="flex min-h-screen bg-[#09090b]">
      <Sidebar />

      <main className="flex-1 flex flex-col min-w-0">
        <Header 
          title="Performer Payouts Queue" 
          subtitle="Process bank transfers and CBE mobile money payouts to performers" 
        />

        <div className="p-8 space-y-6 flex-1">
          {/* Filter Tabs & Search Bar */}
          <div className="flex flex-col md:flex-row items-stretch md:items-center justify-between gap-4">
            <div className="flex items-center gap-1.5 p-1.5 rounded-2xl bg-[#121215] border border-zinc-800 overflow-x-auto">
              {(
                [
                  { id: 'REQUESTED' as const, label: 'Pending Payout', countIcon: Clock },
                  { id: 'COMPLETED' as const, label: 'Paid Out', countIcon: CheckCircle2 },
                  { id: 'REJECTED' as const, label: 'Rejected', countIcon: XCircle },
                  { id: 'ALL' as const, label: 'All Requests', countIcon: undefined },
                ]
              ).map((tab) => {
                const isActive = activeTab === tab.id;
                const Icon = tab.countIcon;
                return (
                  <button
                    key={tab.id}
                    onClick={() => setActiveTab(tab.id)}
                    className={`flex items-center gap-2 px-3.5 py-2 rounded-xl text-xs font-semibold whitespace-nowrap transition-all ${
                      isActive
                        ? 'bg-orange-600 text-white shadow-lg shadow-orange-600/20'
                        : 'text-zinc-400 hover:text-zinc-200 hover:bg-zinc-800/40'
                    }`}
                  >
                    {Icon && <Icon className="w-3.5 h-3.5" />}
                    <span>{tab.label}</span>
                  </button>
                );
              })}
            </div>

            <div className="flex items-center gap-3">
              <div className="relative w-full md:w-64">
                <Search className="w-4 h-4 text-zinc-500 absolute left-3.5 top-1/2 -translate-y-1/2" />
                <input
                  type="text"
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                  placeholder="Search performer, account..."
                  className="w-full bg-[#121215] border border-zinc-800 rounded-xl pl-10 pr-4 py-2 text-xs text-zinc-100 placeholder-zinc-500 focus:outline-none focus:border-orange-500/50"
                />
              </div>

              <button
                onClick={loadQueue}
                disabled={loading}
                className="p-2.5 rounded-xl bg-[#121215] border border-zinc-800 text-zinc-400 hover:text-zinc-100 transition-all"
              >
                <RefreshCw className={`w-4 h-4 ${loading ? 'animate-spin' : ''}`} />
              </button>
            </div>
          </div>

          {/* Table */}
          <div className="bg-[#121215] border border-zinc-800 rounded-2xl overflow-hidden">
            <div className="overflow-x-auto">
              <table className="w-full text-left border-collapse">
                <thead>
                  <tr className="border-b border-zinc-800 bg-zinc-900/40 text-[11px] font-semibold text-zinc-400 uppercase tracking-wider">
                    <th className="px-6 py-4">Performer</th>
                    <th className="px-6 py-4">Amount</th>
                    <th className="px-6 py-4">Destination Note</th>
                    <th className="px-6 py-4">Requested</th>
                    <th className="px-6 py-4">Status</th>
                    <th className="px-6 py-4 text-right">Actions</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-zinc-800/60 text-xs">
                  {loading ? (
                    <tr>
                      <td colSpan={6} className="px-6 py-12 text-center text-zinc-500">
                        <RefreshCw className="w-6 h-6 animate-spin mx-auto mb-2 text-orange-500" />
                        Loading payouts queue...
                      </td>
                    </tr>
                  ) : filteredPayouts.length === 0 ? (
                    <tr>
                      <td colSpan={6} className="px-6 py-12 text-center text-zinc-500">
                        No payout requests found in this category.
                      </td>
                    </tr>
                  ) : (
                    filteredPayouts.map((p) => {
                      const isPending = p.status === 'REQUESTED';
                      return (
                        <tr key={p.id} className="hover:bg-zinc-800/20 transition-colors">
                          <td className="px-6 py-4">
                            <div className="font-medium text-zinc-200">{p.displayName || 'Performer'}</div>
                            <div className="text-[11px] text-zinc-500">{p.phone}</div>
                          </td>
                          <td className="px-6 py-4">
                            <span className="font-bold text-zinc-100 text-sm">
                              {Number(p.amountEtb).toLocaleString()} ETB
                            </span>
                          </td>
                          <td className="px-6 py-4">
                            <span className="font-mono text-zinc-300 bg-zinc-800/60 px-2.5 py-1 rounded-lg border border-zinc-700/50 text-[11px]">
                              {p.destinationNote || 'None'}
                            </span>
                            {p.adminNotes && (
                              <div className="text-[11px] text-zinc-500 mt-1 italic">
                                Admin note: {p.adminNotes}
                              </div>
                            )}
                          </td>
                          <td className="px-6 py-4 text-zinc-400">
                            {new Date(p.createdAt).toLocaleDateString()} {new Date(p.createdAt).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                          </td>
                          <td className="px-6 py-4">
                            <span className={`inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-[10px] font-bold border ${
                              p.status === 'COMPLETED'
                                ? 'bg-emerald-500/10 text-emerald-400 border-emerald-500/20'
                                : p.status === 'REJECTED'
                                ? 'bg-red-500/10 text-red-400 border-red-500/20'
                                : 'bg-orange-500/10 text-orange-400 border-orange-500/20'
                            }`}>
                              {p.status}
                            </span>
                          </td>
                          <td className="px-6 py-4 text-right">
                            {isPending ? (
                              <div className="flex items-center justify-end gap-2">
                                <button
                                  onClick={() => {
                                    setDecisionItem(p);
                                    setDecisionType('COMPLETE');
                                    setNotes('');
                                  }}
                                  className="px-3 py-1.5 rounded-lg bg-emerald-600/15 border border-emerald-500/30 text-emerald-400 hover:bg-emerald-600/30 text-xs font-semibold transition-all"
                                >
                                  Mark Paid
                                </button>
                                <button
                                  onClick={() => {
                                    setDecisionItem(p);
                                    setDecisionType('REJECT');
                                    setNotes('');
                                  }}
                                  className="px-3 py-1.5 rounded-lg bg-red-600/15 border border-red-500/30 text-red-400 hover:bg-red-600/30 text-xs font-semibold transition-all"
                                >
                                  Reject
                                </button>
                              </div>
                            ) : (
                              <span className="text-zinc-600 text-xs">—</span>
                            )}
                          </td>
                        </tr>
                      );
                    })
                  )}
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </main>

      {/* Decision Modal */}
      {decisionItem && decisionType && (
        <div className="fixed inset-0 z-50 bg-black/80 backdrop-blur-sm flex items-center justify-center p-4">
          <div className="bg-[#141418] border border-zinc-800 rounded-3xl max-w-md w-full p-6 shadow-2xl">
            <div className="flex items-center justify-between pb-4 border-b border-zinc-800">
              <div>
                <h3 className="font-bold text-zinc-100">
                  {decisionType === 'COMPLETE' ? 'Confirm Payout Transfer' : 'Reject Payout Request'}
                </h3>
                <p className="text-xs text-zinc-400 mt-1">
                  {decisionItem.displayName} • {Number(decisionItem.amountEtb).toLocaleString()} ETB
                </p>
              </div>
            </div>

            <form onSubmit={handleDecisionConfirm} className="mt-4 space-y-4">
              <div>
                <label className="block text-xs font-semibold text-zinc-300 mb-1.5">
                  Transfer Reference / Admin Note
                </label>
                <textarea
                  value={notes}
                  onChange={(e) => setNotes(e.target.value)}
                  placeholder={decisionType === 'COMPLETE' ? 'e.g. CBE Transfer Ref: FT260849201...' : 'Reason for rejection...'}
                  rows={3}
                  className="w-full bg-[#1c1c21] border border-zinc-700/60 rounded-xl p-3 text-xs text-zinc-100 placeholder-zinc-500 focus:outline-none focus:border-orange-500/60"
                />
              </div>

              <div className="flex items-center justify-end gap-3 pt-2">
                <button
                  type="button"
                  onClick={() => {
                    setDecisionItem(null);
                    setDecisionType(null);
                  }}
                  className="px-4 py-2 rounded-xl text-xs font-semibold text-zinc-400 hover:text-zinc-200"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  disabled={submitting}
                  className={`px-5 py-2 rounded-xl text-xs font-bold text-white shadow-lg transition-all ${
                    decisionType === 'COMPLETE'
                      ? 'bg-emerald-600 hover:bg-emerald-500 shadow-emerald-600/20'
                      : 'bg-red-600 hover:bg-red-500 shadow-red-600/20'
                  }`}
                >
                  {submitting ? 'Processing...' : decisionType === 'COMPLETE' ? 'Confirm Paid' : 'Reject Request'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
