'use client';

import React, { useEffect, useState } from 'react';
import { Sidebar } from '@/components/sidebar';
import { Header } from '@/components/header';
import { fetchPanics, ackPanic, fetchReports } from '@/lib/api';
import { PanicAlert, SafetyReport } from '@/lib/types';
import { ShieldAlert, RefreshCw, CheckCircle2, AlertTriangle, FileText } from 'lucide-react';

import { useAdminEvents } from '@/lib/useAdminEvents';

export default function SafetyPage() {
  const [panics, setPanics] = useState<PanicAlert[]>([]);
  const [reports, setReports] = useState<SafetyReport[]>([]);
  const [loading, setLoading] = useState(true);

  useAdminEvents((event) => {
    if (event.type === 'PANIC_ALERT' || event.type === 'SAFETY_ALARM' || event.type === 'SAFETY_REPORT') {
      loadSafety();
    }
  });


  const loadSafety = async () => {
    setLoading(true);
    try {
      const [panicsData, reportsData] = await Promise.all([
        fetchPanics(),
        fetchReports(),
      ]);
      setPanics(panicsData);
      setReports(reportsData);
    } catch (err) {
      console.error('Failed to load safety alerts:', err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadSafety();
  }, []);

  const handleAckPanic = async (id: string) => {
    try {
      await ackPanic(id);
      await loadSafety();
    } catch (err) {
      alert((err as Error).message);
    }
  };

  return (
    <div className="flex min-h-screen bg-[#09090b]">
      <Sidebar />

      <main className="flex-1 flex flex-col min-w-0">
        <Header title="Safety & Panics" subtitle="Real-time emergency panic alerts and safety incident queue" />

        <div className="p-8 space-y-8 flex-1">
          {/* Refresh Top Action */}
          <div className="flex items-center justify-between">
            <h3 className="text-xl font-black text-zinc-100">Live Safety Dispatch</h3>
            <button
              onClick={loadSafety}
              disabled={loading}
              className="flex items-center gap-2 px-4 py-2 rounded-xl bg-[#121215] border border-zinc-800 text-xs font-semibold text-zinc-300 hover:text-zinc-100 transition-all"
            >
              <RefreshCw className={`w-3.5 h-3.5 ${loading ? 'animate-spin' : ''}`} />
              <span>Refresh Alerts</span>
            </button>
          </div>

          {/* Urgent Panic Alerts Queue */}
          <div className="bg-[#121215] border border-zinc-800 rounded-3xl p-6 shadow-sm">
            <div className="flex items-center gap-3 pb-4 border-b border-zinc-800">
              <div className="p-2 rounded-xl bg-red-500/10 border border-red-500/20 text-red-400">
                <AlertTriangle className="w-5 h-5" />
              </div>
              <div>
                <h4 className="font-bold text-zinc-100">Open Panic Alerts</h4>
                <p className="text-xs text-zinc-400">High-priority emergency alerts triggered by members</p>
              </div>
            </div>

            <div className="mt-4">
              {panics.length === 0 ? (
                <div className="text-center py-8 text-zinc-500 text-sm">
                  No active panic alerts. All clear!
                </div>
              ) : (
                <div className="space-y-3">
                  {panics.map((p) => (
                    <div
                      key={p.id}
                      className="p-4 rounded-2xl bg-red-500/5 border border-red-500/20 flex items-center justify-between"
                    >
                      <div>
                        <div className="flex items-center gap-2">
                          <span className="font-bold text-red-400 text-sm">PANIC ALERT</span>
                          <span className="text-xs font-mono text-zinc-400">User ID: {p.userId}</span>
                        </div>
                        <p className="text-xs text-zinc-300 mt-1">Note: {p.note || 'None'}</p>
                        <p className="text-[11px] text-zinc-500 mt-0.5">{new Date(p.createdAt).toLocaleString()}</p>
                      </div>

                      {p.status === 'OPEN' ? (
                        <button
                          onClick={() => handleAckPanic(p.id)}
                          className="px-4 py-2 rounded-xl bg-red-600 hover:bg-red-500 text-white font-bold text-xs shadow-lg shadow-red-600/20 transition-all flex items-center gap-1.5"
                        >
                          <CheckCircle2 className="w-4 h-4" />
                          <span>Acknowledge Panic</span>
                        </button>
                      ) : (
                        <span className="text-xs font-bold text-emerald-400 bg-emerald-500/10 px-3 py-1 rounded-full border border-emerald-500/20">
                          {p.status}
                        </span>
                      )}
                    </div>
                  ))}
                </div>
              )}
            </div>
          </div>

          {/* Safety Reports Queue */}
          <div className="bg-[#121215] border border-zinc-800 rounded-3xl p-6 shadow-sm">
            <div className="flex items-center gap-3 pb-4 border-b border-zinc-800">
              <div className="p-2 rounded-xl bg-amber-500/10 border border-amber-500/20 text-amber-400">
                <FileText className="w-5 h-5" />
              </div>
              <div>
                <h4 className="font-bold text-zinc-100">Safety Incident Reports</h4>
                <p className="text-xs text-zinc-400">Behavioral and safety reports submitted by members</p>
              </div>
            </div>

            <div className="mt-4">
              {reports.length === 0 ? (
                <div className="text-center py-8 text-zinc-500 text-sm">
                  No open safety reports in queue.
                </div>
              ) : (
                <div className="divide-y divide-zinc-800/60">
                  {reports.map((r) => (
                    <div key={r.id} className="py-3.5 flex items-center justify-between">
                      <div>
                        <div className="flex items-center gap-2">
                          <span className="font-semibold text-sm text-zinc-200">{r.category}</span>
                          <span className="text-[10px] font-bold px-2 py-0.5 rounded bg-zinc-800 text-zinc-400 border border-zinc-700">
                            {r.status}
                          </span>
                        </div>
                        <p className="text-xs text-zinc-400 mt-1">{r.details}</p>
                      </div>
                      <span className="text-xs text-zinc-500">{new Date(r.createdAt).toLocaleDateString()}</span>
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
