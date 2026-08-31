'use client';

import React, { useEffect, useState, useCallback } from 'react';
import { Sidebar } from '@/components/sidebar';
import { Header } from '@/components/header';
import { fetchPayments, approvePayment, rejectPayment } from '@/lib/api';
import { PaymentIntentAdminItem } from '@/lib/types';
import { ReceiptModal } from '@/components/receipt-modal';
import { DecisionModal } from '@/components/decision-modal';
import { 
  CreditCard, 
  CheckCircle2, 
  XCircle, 
  Clock, 
  Search, 
  Eye, 
  Filter, 
  RefreshCw,
  Image as ImageIcon
} from 'lucide-react';

type FilterTab = 'CHECKOUT' | 'PAID' | 'FAILED' | 'REFUND_PENDING' | 'ALL';

export default function PaymentQueuePage() {
  const [payments, setPayments] = useState<PaymentIntentAdminItem[]>([]);
  const [activeTab, setActiveTab] = useState<FilterTab>('CHECKOUT');
  const [searchTerm, setSearchTerm] = useState('');
  const [loading, setLoading] = useState(true);

  const [selectedReceipt, setSelectedReceipt] = useState<PaymentIntentAdminItem | null>(null);
  const [decisionPayment, setDecisionPayment] = useState<PaymentIntentAdminItem | null>(null);
  const [decisionType, setDecisionType] = useState<'APPROVE' | 'REJECT' | null>(null);

  const API_BASE = process.env.NEXT_PUBLIC_API_BASE_URL || 'http://localhost:8080';

  const loadQueue = useCallback(async () => {
    setLoading(true);
    try {
      const data = await fetchPayments(activeTab === 'ALL' ? undefined : activeTab);
      setPayments(data);
    } catch (err) {
      console.error('Failed to load payment queue:', err);
    } finally {
      setLoading(false);
    }
  }, [activeTab]);

  useEffect(() => {
    loadQueue();
  }, [loadQueue]);

  const handleDecisionConfirm = async (paymentId: string, notes: string) => {
    if (decisionType === 'APPROVE') {
      await approvePayment(paymentId, notes);
    } else if (decisionType === 'REJECT') {
      await rejectPayment(paymentId, notes);
    }
    setSelectedReceipt(null);
    setDecisionPayment(null);
    setDecisionType(null);
    await loadQueue();
  };

  const filteredPayments = payments.filter((p) => {
    if (!searchTerm) return true;
    const term = searchTerm.toLowerCase();
    return (
      p.userName?.toLowerCase().includes(term) ||
      p.userPhone?.toLowerCase().includes(term) ||
      p.providerRef?.toLowerCase().includes(term) ||
      p.merchantOrderId?.toLowerCase().includes(term) ||
      p.amountEtb?.toString().includes(term)
    );
  });

  return (
    <div className="flex min-h-screen bg-[#09090b]">
      <Sidebar />

      <main className="flex-1 flex flex-col min-w-0">
        <Header 
          title="Payment Verification Queue" 
          subtitle="Review uploaded CBE receipt screenshots and approve/reject transactions" 
        />

        <div className="p-8 space-y-6 flex-1">
          {/* Filter Tabs & Search Bar */}
          <div className="flex flex-col md:flex-row items-stretch md:items-center justify-between gap-4">
            {/* Status Tabs */}
            <div className="flex items-center gap-1.5 p-1.5 rounded-2xl bg-[#121215] border border-zinc-800 overflow-x-auto">
              {(
                [
                  { id: 'CHECKOUT', label: 'Pending Review', countIcon: Clock },
                  { id: 'PAID', label: 'Approved', countIcon: CheckCircle2 },
                  { id: 'FAILED', label: 'Rejected', countIcon: XCircle },
                  { id: 'REFUND_PENDING', label: 'Refunds' },
                  { id: 'ALL', label: 'All Orders' },
                ] as const
              ).map((tab) => {
                const isActive = activeTab === tab.id;
                return (
                  <button
                    key={tab.id}
                    onClick={() => setActiveTab(tab.id as FilterTab)}
                    className={`px-4 py-2 rounded-xl text-xs font-bold transition-all whitespace-nowrap flex items-center gap-2 ${
                      isActive
                        ? 'bg-orange-600 text-white shadow-lg shadow-orange-600/20'
                        : 'text-zinc-400 hover:text-zinc-200 hover:bg-zinc-800/50'
                    }`}
                  >
                    <span>{tab.label}</span>
                  </button>
                );
              })}
            </div>

            {/* Search Input & Refresh */}
            <div className="flex items-center gap-3">
              <div className="relative flex-1 md:w-64">
                <Search className="w-4 h-4 text-zinc-500 absolute left-3.5 top-1/2 -translate-y-1/2" />
                <input
                  type="text"
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                  placeholder="Search member, phone, FT code..."
                  className="w-full bg-[#121215] border border-zinc-800 rounded-xl pl-10 pr-4 py-2 text-xs text-zinc-100 placeholder-zinc-500 focus:outline-none focus:border-orange-500/50 transition-all"
                />
              </div>

              <button
                onClick={loadQueue}
                disabled={loading}
                className="p-2.5 rounded-xl bg-[#121215] border border-zinc-800 text-zinc-400 hover:text-zinc-100 transition-all"
                title="Refresh Queue"
              >
                <RefreshCw className={`w-4 h-4 ${loading ? 'animate-spin' : ''}`} />
              </button>
            </div>
          </div>

          {/* Payment List Table / Cards */}
          <div className="bg-[#121215] border border-zinc-800 rounded-3xl overflow-hidden shadow-sm">
            {loading ? (
              <div className="p-12 text-center text-zinc-500 text-sm flex items-center justify-center gap-2">
                <RefreshCw className="w-4 h-4 animate-spin text-orange-500" />
                <span>Loading verification queue...</span>
              </div>
            ) : filteredPayments.length === 0 ? (
              <div className="p-12 text-center text-zinc-500">
                <CreditCard className="w-10 h-10 mx-auto mb-3 opacity-30 text-zinc-400" />
                <p className="text-sm font-semibold">No payments found</p>
                <p className="text-xs text-zinc-600 mt-1">There are no payment proofs matching this filter.</p>
              </div>
            ) : (
              <div className="overflow-x-auto">
                <table className="w-full text-left border-collapse">
                  <thead>
                    <tr className="border-b border-zinc-800/80 bg-zinc-900/40 text-[11px] font-bold text-zinc-400 uppercase tracking-wider">
                      <th className="py-4 px-6">Member</th>
                      <th className="py-4 px-6">Purpose / Amount</th>
                      <th className="py-4 px-6">CBE FT Code</th>
                      <th className="py-4 px-6">Receipt Screenshot</th>
                      <th className="py-4 px-6">Status</th>
                      <th className="py-4 px-6 text-right">Actions</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-zinc-800/60 text-sm">
                    {filteredPayments.map((p) => {
                      const fullImageUrl = p.receiptUrl
                        ? p.receiptUrl.startsWith('http')
                          ? p.receiptUrl
                          : `${API_BASE}${p.receiptUrl}`
                        : null;

                      return (
                        <tr key={p.id} className="hover:bg-zinc-900/30 transition-all">
                          {/* Member info */}
                          <td className="py-4 px-6">
                            <div className="font-bold text-zinc-100">{p.userName}</div>
                            <div className="text-xs font-mono text-zinc-400">{p.userPhone || 'N/A'}</div>
                          </td>

                          {/* Purpose & Amount */}
                          <td className="py-4 px-6">
                            <div className="font-extrabold text-emerald-400 text-base">{p.amountEtb} ETB</div>
                            <div className="text-[11px] text-zinc-400 font-medium">
                              {p.purpose} • <span className="font-mono text-zinc-500">{p.merchantOrderId}</span>
                            </div>
                          </td>

                          {/* FT Reference */}
                          <td className="py-4 px-6">
                            {p.providerRef ? (
                              <span className="font-mono font-bold text-orange-400 bg-orange-500/10 px-2.5 py-1 rounded-lg border border-orange-500/20 text-xs">
                                {p.providerRef}
                              </span>
                            ) : (
                              <span className="text-xs text-zinc-500 italic">No code typed</span>
                            )}
                          </td>

                          {/* Screenshot preview */}
                          <td className="py-4 px-6">
                            {fullImageUrl ? (
                              <button
                                onClick={() => setSelectedReceipt(p)}
                                className="group relative w-16 h-12 rounded-xl bg-black overflow-hidden border border-zinc-700 hover:border-orange-500 transition-all flex items-center justify-center"
                              >
                                {/* eslint-disable-next-line @next/next/no-img-element */}
                                <img
                                  src={fullImageUrl}
                                  alt="Receipt Screenshot"
                                  className="w-full h-full object-cover group-hover:scale-105 transition-transform"
                                />
                                <div className="absolute inset-0 bg-black/40 group-hover:bg-black/20 flex items-center justify-center transition-all">
                                  <Eye className="w-4 h-4 text-white opacity-80 group-hover:opacity-100" />
                                </div>
                              </button>
                            ) : (
                              <div className="text-xs text-zinc-500 flex items-center gap-1.5">
                                <ImageIcon className="w-3.5 h-3.5 opacity-50" />
                                <span>No screenshot</span>
                              </div>
                            )}
                          </td>

                          {/* Status Badge */}
                          <td className="py-4 px-6">
                            <span
                              className={`inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-bold border ${
                                p.status === 'PAID'
                                  ? 'bg-emerald-500/15 text-emerald-400 border-emerald-500/30'
                                  : p.status === 'CHECKOUT' || p.status === 'PENDING'
                                  ? 'bg-orange-500/15 text-orange-400 border-orange-500/30'
                                  : p.status === 'FAILED'
                                  ? 'bg-red-500/15 text-red-400 border-red-500/30'
                                  : 'bg-zinc-800 text-zinc-300 border-zinc-700'
                              }`}
                            >
                              <span>
                                {p.status === 'CHECKOUT' || p.status === 'PENDING'
                                  ? 'Awaiting Review'
                                  : p.status}
                              </span>
                            </span>
                          </td>

                          {/* Actions */}
                          <td className="py-4 px-6 text-right">
                            <div className="flex items-center justify-end gap-2">
                              {fullImageUrl && (
                                <button
                                  onClick={() => setSelectedReceipt(p)}
                                  className="p-2 rounded-xl bg-zinc-900 border border-zinc-800 text-zinc-300 hover:text-zinc-100 hover:border-zinc-700 transition-all text-xs font-semibold flex items-center gap-1.5"
                                  title="Inspect Screenshot"
                                >
                                  <Eye className="w-3.5 h-3.5" />
                                  <span className="hidden lg:inline">Inspect</span>
                                </button>
                              )}

                              {p.status !== 'PAID' && (
                                <button
                                  onClick={() => {
                                    setDecisionPayment(p);
                                    setDecisionType('APPROVE');
                                  }}
                                  className="px-3 py-1.5 rounded-xl bg-emerald-600 hover:bg-emerald-500 text-white font-bold text-xs shadow-md shadow-emerald-600/20 transition-all flex items-center gap-1"
                                >
                                  <CheckCircle2 className="w-3.5 h-3.5" />
                                  <span>Approve</span>
                                </button>
                              )}

                              {p.status !== 'FAILED' && p.status !== 'PAID' && (
                                <button
                                  onClick={() => {
                                    setDecisionPayment(p);
                                    setDecisionType('REJECT');
                                  }}
                                  className="px-3 py-1.5 rounded-xl bg-zinc-800 hover:bg-red-500/20 text-zinc-300 hover:text-red-400 border border-zinc-700 hover:border-red-500/30 font-semibold text-xs transition-all flex items-center gap-1"
                                >
                                  <XCircle className="w-3.5 h-3.5" />
                                  <span>Reject</span>
                                </button>
                              )}
                            </div>
                          </td>
                        </tr>
                      );
                    })}
                  </tbody>
                </table>
              </div>
            )}
          </div>
        </div>
      </main>

      {/* Full-resolution Receipt Screenshot Inspector Modal */}
      <ReceiptModal
        payment={selectedReceipt}
        onClose={() => setSelectedReceipt(null)}
        onApprove={(p) => {
          setSelectedReceipt(null);
          setDecisionPayment(p);
          setDecisionType('APPROVE');
        }}
        onReject={(p) => {
          setSelectedReceipt(null);
          setDecisionPayment(p);
          setDecisionType('REJECT');
        }}
      />

      {/* Decision Modal for Notes / Approval / Rejection */}
      <DecisionModal
        payment={decisionPayment}
        type={decisionType}
        onClose={() => {
          setDecisionPayment(null);
          setDecisionType(null);
        }}
        onConfirm={handleDecisionConfirm}
      />
    </div>
  );
}
