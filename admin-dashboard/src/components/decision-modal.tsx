'use client';

import React, { useState } from 'react';
import { X, CheckCircle, XCircle } from 'lucide-react';
import { PaymentIntentAdminItem } from '@/lib/types';

interface DecisionModalProps {
  payment: PaymentIntentAdminItem | null;
  type: 'APPROVE' | 'REJECT' | null;
  onClose: () => void;
  onConfirm: (paymentId: string, notes: string) => Promise<void>;
}

export function DecisionModal({ payment, type, onClose, onConfirm }: DecisionModalProps) {
  const [notes, setNotes] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);

  if (!payment || !type) return null;

  const isApprove = type === 'APPROVE';

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsSubmitting(true);
    try {
      await onConfirm(payment.id, notes);
      onClose();
    } catch (e) {
      alert((e as Error).message);
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <div className="fixed inset-0 z-50 bg-black/80 backdrop-blur-sm flex items-center justify-center p-4">
      <div className="bg-[#141418] border border-zinc-800 rounded-3xl max-w-md w-full p-6 shadow-2xl">
        <div className="flex items-center justify-between pb-4 border-b border-zinc-800">
          <div className="flex items-center gap-3">
            <div className={`p-2 rounded-xl border ${isApprove ? 'bg-emerald-500/10 border-emerald-500/20 text-emerald-400' : 'bg-red-500/10 border-red-500/20 text-red-400'}`}>
              {isApprove ? <CheckCircle className="w-5 h-5" /> : <XCircle className="w-5 h-5" />}
            </div>
            <div>
              <h3 className="font-bold text-zinc-100">{isApprove ? 'Approve Payment' : 'Reject Proof'}</h3>
              <p className="text-xs text-zinc-400">{payment.userName} • {payment.amountEtb} ETB</p>
            </div>
          </div>
          <button onClick={onClose} className="text-zinc-400 hover:text-zinc-100 p-1 rounded-lg">
            <X className="w-5 h-5" />
          </button>
        </div>

        <form onSubmit={handleSubmit} className="mt-4 space-y-4">
          <div>
            <label className="block text-xs font-semibold text-zinc-300 mb-1.5">
              Admin Notes / {isApprove ? 'Approval Comment' : 'Rejection Reason'}
            </label>
            <textarea
              value={notes}
              onChange={(e) => setNotes(e.target.value)}
              placeholder={isApprove ? 'e.g. CBE FT code verified on bank statement' : 'e.g. Invalid CBE receipt screenshot provided'}
              className="w-full h-24 bg-zinc-900 border border-zinc-800 rounded-xl p-3 text-sm text-zinc-100 placeholder-zinc-500 focus:outline-none focus:border-orange-500/50"
            />
          </div>

          <div className="flex items-center gap-3 pt-2">
            <button
              type="button"
              onClick={onClose}
              className="w-1/2 py-2.5 rounded-xl border border-zinc-800 text-zinc-300 text-sm font-semibold hover:bg-zinc-800 transition-all"
            >
              Cancel
            </button>
            <button
              type="submit"
              disabled={isSubmitting}
              className={`w-1/2 py-2.5 rounded-xl text-white text-sm font-bold shadow-lg transition-all ${
                isApprove
                  ? 'bg-emerald-600 hover:bg-emerald-500 shadow-emerald-600/20'
                  : 'bg-red-600 hover:bg-red-500 shadow-red-600/20'
              }`}
            >
              {isSubmitting ? 'Saving...' : isApprove ? 'Confirm Approval' : 'Confirm Rejection'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
