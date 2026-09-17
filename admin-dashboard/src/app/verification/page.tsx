'use client';

import React, { useEffect, useState, useCallback } from 'react';
import { Sidebar } from '@/components/sidebar';
import { Header } from '@/components/header';
import { fetchVerificationQueue, reviewVerificationCase } from '@/lib/api';
import { VerificationCaseItem } from '@/lib/types';
import { 
  BadgeCheck, 
  CheckCircle2, 
  XCircle, 
  RefreshCw, 
  Eye,
  FileText,
  UserCheck
} from 'lucide-react';

export default function VerificationQueuePage() {
  const [cases, setCases] = useState<VerificationCaseItem[]>([]);
  const [loading, setLoading] = useState(true);

  const [activeCase, setActiveCase] = useState<VerificationCaseItem | null>(null);
  const [reviewType, setReviewType] = useState<'APPROVE' | 'REJECT' | null>(null);
  const [notes, setNotes] = useState('');
  const [submitting, setSubmitting] = useState(false);

  const API_BASE = process.env.NEXT_PUBLIC_API_BASE_URL || 'http://localhost:8080';

  const formatImageUrl = (url: string) => {
    if (!url) return '';
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    return `${API_BASE}${url.startsWith('/') ? '' : '/'}${url}`;
  };

  const loadQueue = useCallback(async () => {
    setLoading(true);
    try {
      const data = await fetchVerificationQueue();
      setCases(data);
    } catch (err) {
      console.error('Failed to load verification queue:', err);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    loadQueue();
  }, [loadQueue]);

  const handleReviewConfirm = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!activeCase || !reviewType) return;
    setSubmitting(true);
    try {
      await reviewVerificationCase(
        activeCase.id,
        reviewType === 'APPROVE',
        notes || (reviewType === 'APPROVE' ? 'Identity verified' : 'ID did not match selfie')
      );
      setActiveCase(null);
      setReviewType(null);
      setNotes('');
      await loadQueue();
    } catch (err) {
      alert((err as Error).message);
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <div className="flex min-h-screen bg-[#09090b]">
      <Sidebar />

      <main className="flex-1 flex flex-col min-w-0">
        <Header 
          title="Identity Verification Queue" 
          subtitle="Compare official Government IDs with live selfies to verify performer & member authenticity" 
        />

        <div className="p-8 space-y-6 flex-1">
          <div className="flex items-center justify-between">
            <p className="text-xs text-zinc-400">
              Showing pending identity verification requests requiring manual review
            </p>
            <button
              onClick={loadQueue}
              disabled={loading}
              className="p-2.5 rounded-xl bg-[#121215] border border-zinc-800 text-zinc-400 hover:text-zinc-100 transition-all"
            >
              <RefreshCw className={`w-4 h-4 ${loading ? 'animate-spin' : ''}`} />
            </button>
          </div>

          {loading ? (
            <div className="bg-[#121215] border border-zinc-800 rounded-2xl p-16 text-center text-zinc-500">
              <RefreshCw className="w-6 h-6 animate-spin mx-auto mb-2 text-orange-500" />
              Loading verification cases...
            </div>
          ) : cases.length === 0 ? (
            <div className="bg-[#121215] border border-zinc-800 rounded-2xl p-16 text-center text-zinc-500">
              <CheckCircle2 className="w-8 h-8 text-emerald-500/60 mx-auto mb-3" />
              <p className="text-zinc-300 font-medium">No pending verification cases</p>
              <p className="text-xs text-zinc-500 mt-1">All user IDs and verification selfies have been reviewed.</p>
            </div>
          ) : (
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              {cases.map((c) => (
                <div key={c.id} className="bg-[#121215] border border-zinc-800 rounded-2xl p-6 flex flex-col justify-between space-y-5">
                  <div>
                    <div className="flex items-center justify-between mb-4">
                      <div>
                        <div className="text-xs font-mono text-zinc-400">User ID: {c.userId.substring(0, 8)}...</div>
                        <div className="text-[11px] text-zinc-500">Submitted {new Date(c.createdAt).toLocaleDateString()} {new Date(c.createdAt).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}</div>
                      </div>
                      <span className="text-[10px] font-bold px-2.5 py-1 rounded-full bg-orange-500/10 text-orange-400 border border-orange-500/20">
                        {c.status}
                      </span>
                    </div>

                    {/* Document vs Selfie Comparison */}
                    <div className="grid grid-cols-2 gap-4">
                      <div>
                        <div className="flex items-center gap-1.5 text-xs font-medium text-zinc-400 mb-2">
                          <FileText className="w-3.5 h-3.5 text-orange-400" />
                          <span>Government ID</span>
                        </div>
                        <div 
                          onClick={() => setActiveCase(c)}
                          className="aspect-[4/3] rounded-xl bg-zinc-900 border border-zinc-800 overflow-hidden cursor-pointer relative group"
                        >
                          <img 
                            src={formatImageUrl(c.idDocumentUrl)} 
                            alt="Government ID" 
                            className="w-full h-full object-cover transition-transform group-hover:scale-105"
                          />
                          <div className="absolute inset-0 bg-black/40 opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center">
                            <Eye className="w-5 h-5 text-white" />
                          </div>
                        </div>
                      </div>

                      <div>
                        <div className="flex items-center gap-1.5 text-xs font-medium text-zinc-400 mb-2">
                          <UserCheck className="w-3.5 h-3.5 text-orange-400" />
                          <span>Live Selfie</span>
                        </div>
                        <div 
                          onClick={() => setActiveCase(c)}
                          className="aspect-[4/3] rounded-xl bg-zinc-900 border border-zinc-800 overflow-hidden cursor-pointer relative group"
                        >
                          <img 
                            src={formatImageUrl(c.selfieUrl)} 
                            alt="Live Selfie" 
                            className="w-full h-full object-cover transition-transform group-hover:scale-105"
                          />
                          <div className="absolute inset-0 bg-black/40 opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center">
                            <Eye className="w-5 h-5 text-white" />
                          </div>
                        </div>
                      </div>
                    </div>

                    {c.notes && (
                      <div className="text-xs text-zinc-400 mt-3 p-2.5 rounded-xl bg-zinc-900/60 border border-zinc-800">
                        <span className="font-semibold text-zinc-300">Notes:</span> {c.notes}
                      </div>
                    )}
                  </div>

                  {/* Actions */}
                  <div className="flex items-center gap-3 pt-3 border-t border-zinc-800/60">
                    <button
                      onClick={() => {
                        setActiveCase(c);
                        setReviewType('APPROVE');
                        setNotes('');
                      }}
                      className="flex-1 flex items-center justify-center gap-2 py-2.5 rounded-xl bg-emerald-600/15 border border-emerald-500/30 text-emerald-400 hover:bg-emerald-600/30 text-xs font-semibold transition-all"
                    >
                      <CheckCircle2 className="w-4 h-4" />
                      Approve Identity
                    </button>
                    <button
                      onClick={() => {
                        setActiveCase(c);
                        setReviewType('REJECT');
                        setNotes('');
                      }}
                      className="flex-1 flex items-center justify-center gap-2 py-2.5 rounded-xl bg-red-600/15 border border-red-500/30 text-red-400 hover:bg-red-600/30 text-xs font-semibold transition-all"
                    >
                      <XCircle className="w-4 h-4" />
                      Reject Case
                    </button>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      </main>

      {/* Comparison & Decision Modal */}
      {activeCase && (
        <div className="fixed inset-0 z-50 bg-black/85 backdrop-blur-md flex items-center justify-center p-4">
          <div className="bg-[#141418] border border-zinc-800 rounded-3xl max-w-3xl w-full p-6 shadow-2xl flex flex-col max-h-[90vh]">
            <div className="flex items-center justify-between pb-4 border-b border-zinc-800">
              <div>
                <h3 className="font-bold text-zinc-100">Compare Identity Documents</h3>
                <p className="text-xs text-zinc-400 mt-0.5">User ID: {activeCase.userId}</p>
              </div>
              <button 
                onClick={() => {
                  setActiveCase(null);
                  setReviewType(null);
                }}
                className="text-zinc-400 hover:text-zinc-200 text-sm font-semibold"
              >
                Close
              </button>
            </div>

            {/* Side by side large view */}
            <div className="grid grid-cols-2 gap-4 my-4 overflow-y-auto max-h-[50vh]">
              <div>
                <span className="block text-xs font-semibold text-zinc-400 mb-1.5">Government ID Document</span>
                <div className="rounded-xl overflow-hidden border border-zinc-800 bg-zinc-900">
                  <img src={formatImageUrl(activeCase.idDocumentUrl)} alt="ID Document Large" className="w-full object-contain" />
                </div>
              </div>
              <div>
                <span className="block text-xs font-semibold text-zinc-400 mb-1.5">Live Verification Selfie</span>
                <div className="rounded-xl overflow-hidden border border-zinc-800 bg-zinc-900">
                  <img src={formatImageUrl(activeCase.selfieUrl)} alt="Selfie Large" className="w-full object-contain" />
                </div>
              </div>
            </div>

            {reviewType ? (
              <form onSubmit={handleReviewConfirm} className="space-y-4 pt-4 border-t border-zinc-800">
                <div>
                  <label className="block text-xs font-semibold text-zinc-300 mb-1.5">
                    {reviewType === 'APPROVE' ? 'Approval Notes (Optional)' : 'Rejection Reason'}
                  </label>
                  <textarea
                    value={notes}
                    onChange={(e) => setNotes(e.target.value)}
                    placeholder={reviewType === 'APPROVE' ? 'Name and face match government record.' : 'Explain mismatch or defect (e.g. blurred photo, expired ID, selfie does not match ID)...'}
                    rows={2}
                    className="w-full bg-[#1c1c21] border border-zinc-700/60 rounded-xl p-3 text-xs text-zinc-100 placeholder-zinc-500 focus:outline-none focus:border-orange-500/60"
                  />
                </div>
                <div className="flex items-center justify-end gap-3">
                  <button
                    type="button"
                    onClick={() => setReviewType(null)}
                    className="px-4 py-2 rounded-xl text-xs font-semibold text-zinc-400 hover:text-zinc-200"
                  >
                    Back
                  </button>
                  <button
                    type="submit"
                    disabled={submitting}
                    className={`px-5 py-2 rounded-xl text-xs font-bold text-white shadow-lg transition-all ${
                      reviewType === 'APPROVE'
                        ? 'bg-emerald-600 hover:bg-emerald-500 shadow-emerald-600/20'
                        : 'bg-red-600 hover:bg-red-500 shadow-red-600/20'
                    }`}
                  >
                    {submitting ? 'Submitting...' : reviewType === 'APPROVE' ? 'Confirm Approval' : 'Confirm Rejection'}
                  </button>
                </div>
              </form>
            ) : (
              <div className="flex items-center justify-end gap-3 pt-4 border-t border-zinc-800">
                <button
                  type="button"
                  onClick={() => setReviewType('REJECT')}
                  className="px-5 py-2.5 rounded-xl text-xs font-bold bg-red-600/15 border border-red-500/30 text-red-400 hover:bg-red-600/30 transition-all"
                >
                  Reject Case
                </button>
                <button
                  type="button"
                  onClick={() => setReviewType('APPROVE')}
                  className="px-5 py-2.5 rounded-xl text-xs font-bold bg-emerald-600 hover:bg-emerald-500 text-white shadow-lg shadow-emerald-600/20 transition-all"
                >
                  Approve Verification
                </button>
              </div>
            )}
          </div>
        </div>
      )}
    </div>
  );
}
