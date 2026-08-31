'use client';

import React from 'react';
import { X, ExternalLink, CheckCircle, XCircle, User, Phone, Receipt, Tag, Calendar } from 'lucide-react';
import { PaymentIntentAdminItem } from '@/lib/types';

interface ReceiptModalProps {
  payment: PaymentIntentAdminItem | null;
  onClose: () => void;
  onApprove: (payment: PaymentIntentAdminItem) => void;
  onReject: (payment: PaymentIntentAdminItem) => void;
}

export function ReceiptModal({ payment, onClose, onApprove, onReject }: ReceiptModalProps) {
  if (!payment) return null;

  const API_BASE = process.env.NEXT_PUBLIC_API_BASE_URL || 'http://localhost:8080';
  const rawReceiptUrl = payment.receiptUrl;
  const fullImageUrl = rawReceiptUrl
    ? rawReceiptUrl.startsWith('http')
      ? rawReceiptUrl
      : `${API_BASE}${rawReceiptUrl}`
    : null;

  return (
    <div className="fixed inset-0 z-50 bg-black/80 backdrop-blur-sm flex items-center justify-center p-4">
      <div className="bg-[#141418] border border-zinc-800 rounded-3xl max-w-4xl w-full max-h-[90vh] overflow-hidden flex flex-col md:flex-row shadow-2xl">
        {/* Left Side: Screenshot Viewer */}
        <div className="md:w-3/5 bg-black/60 p-6 flex flex-col items-center justify-center border-b md:border-b-0 md:border-r border-zinc-800 relative min-h-[350px]">
          {fullImageUrl ? (
            <div className="relative w-full h-full flex flex-col items-center justify-center">
              {/* eslint-disable-next-line @next/next/no-img-element */}
              <img
                src={fullImageUrl}
                alt="Uploaded CBE Receipt Screenshot"
                className="max-h-[70vh] w-auto object-contain rounded-xl shadow-2xl border border-zinc-800"
                onError={(e) => {
                  (e.target as HTMLElement).style.display = 'none';
                }}
              />
              <a
                href={fullImageUrl}
                target="_blank"
                rel="noreferrer"
                className="mt-3 inline-flex items-center gap-1.5 text-xs text-orange-400 hover:text-orange-300 font-medium"
              >
                <span>Open original image</span>
                <ExternalLink className="w-3.5 h-3.5" />
              </a>
            </div>
          ) : (
            <div className="text-center p-8 text-zinc-500">
              <Receipt className="w-12 h-12 mx-auto mb-3 opacity-30" />
              <p className="text-sm font-medium">No screenshot uploaded</p>
              <p className="text-xs mt-1 text-zinc-600">Member submitted reference code only.</p>
            </div>
          )}
        </div>

        {/* Right Side: Verification Details & Action Controls */}
        <div className="md:w-2/5 p-6 flex flex-col justify-between overflow-y-auto">
          <div>
            <div className="flex items-center justify-between pb-4 border-b border-zinc-800">
              <div>
                <span className="text-[11px] font-bold uppercase tracking-wider text-orange-400">Payment Verification</span>
                <h3 className="text-lg font-bold text-zinc-100 mt-0.5">{payment.purpose} Order</h3>
              </div>
              <button
                onClick={onClose}
                className="p-1.5 text-zinc-400 hover:text-zinc-100 rounded-lg hover:bg-zinc-800 transition-all"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            {/* Details List */}
            <div className="py-4 space-y-3 text-sm">
              <div className="flex items-center justify-between p-3 rounded-xl bg-zinc-900/60 border border-zinc-800/80">
                <span className="text-zinc-400 text-xs font-medium">Amount Due</span>
                <span className="text-lg font-black text-emerald-400">{payment.amountEtb} ETB</span>
              </div>

              <div className="space-y-2">
                <div className="flex items-center gap-2.5 text-zinc-300">
                  <User className="w-4 h-4 text-zinc-500" />
                  <span className="text-xs font-medium text-zinc-400">Member:</span>
                  <span className="font-semibold text-zinc-100">{payment.userName}</span>
                </div>

                <div className="flex items-center gap-2.5 text-zinc-300">
                  <Phone className="w-4 h-4 text-zinc-500" />
                  <span className="text-xs font-medium text-zinc-400">Phone:</span>
                  <span className="font-mono text-xs text-zinc-200">{payment.userPhone || 'N/A'}</span>
                </div>

                <div className="flex items-center gap-2.5 text-zinc-300">
                  <Tag className="w-4 h-4 text-zinc-500" />
                  <span className="text-xs font-medium text-zinc-400">FT Code:</span>
                  <span className="font-mono font-bold text-orange-400 bg-orange-500/10 px-2 py-0.5 rounded border border-orange-500/20">
                    {payment.providerRef || 'Not provided'}
                  </span>
                </div>

                <div className="flex items-center gap-2.5 text-zinc-300">
                  <Calendar className="w-4 h-4 text-zinc-500" />
                  <span className="text-xs font-medium text-zinc-400">Submitted:</span>
                  <span className="text-xs text-zinc-300">
                    {new Date(payment.createdAt).toLocaleString()}
                  </span>
                </div>
              </div>
            </div>
          </div>

          {/* Action Buttons */}
          <div className="pt-4 border-t border-zinc-800 space-y-2">
            <button
              onClick={() => onApprove(payment)}
              className="w-full py-2.5 px-4 rounded-xl bg-emerald-600 hover:bg-emerald-500 text-white font-bold text-sm flex items-center justify-center gap-2 shadow-lg shadow-emerald-600/20 transition-all"
            >
              <CheckCircle className="w-4 h-4" />
              <span>Approve Payment ({payment.amountEtb} ETB)</span>
            </button>

            <button
              onClick={() => onReject(payment)}
              className="w-full py-2.5 px-4 rounded-xl bg-zinc-800 hover:bg-red-500/20 text-zinc-300 hover:text-red-400 border border-zinc-700 hover:border-red-500/30 font-semibold text-sm flex items-center justify-center gap-2 transition-all"
            >
              <XCircle className="w-4 h-4" />
              <span>Reject Proof</span>
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
