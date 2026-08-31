'use client';

import React, { useState } from 'react';
import { Crown, ArrowRight, ShieldCheck, KeyRound, AlertCircle } from 'lucide-react';
import { requestOtp, verifyOtp } from '@/lib/api';
import { useAuth } from '@/lib/auth-context';

export default function LoginPage() {
  const [phone, setPhone] = useState('+251911000000');
  const [otp, setOtp] = useState('');
  const [step, setStep] = useState<'PHONE' | 'OTP'>('PHONE');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [exposedOtp, setExposedOtp] = useState<string | null>(null);
  const { login } = useAuth();

  const handleRequestOtp = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError(null);
    try {
      const res = await requestOtp(phone);
      if (res.codeExposed) {
        setExposedOtp(res.codeExposed);
        setOtp(res.codeExposed);
      }
      setStep('OTP');
    } catch (err) {
      setError((err as Error).message);
    } finally {
      setLoading(false);
    }
  };

  const handleVerifyOtp = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError(null);
    try {
      const res = await verifyOtp(phone, otp);
      login(res.accessToken);
    } catch (err) {
      setError((err as Error).message);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-[#09090b] flex items-center justify-center p-4">
      <div className="w-full max-w-md bg-[#121215] border border-zinc-800 rounded-3xl p-8 shadow-2xl relative overflow-hidden">
        {/* Background Ambient Light */}
        <div className="absolute -top-24 -left-24 w-48 h-48 bg-orange-600/10 rounded-full blur-3xl" />
        <div className="absolute -bottom-24 -right-24 w-48 h-48 bg-amber-600/10 rounded-full blur-3xl" />

        {/* Brand Header */}
        <div className="text-center relative z-10">
          <div className="w-14 h-14 rounded-2xl bg-gradient-to-tr from-orange-600 to-amber-500 mx-auto flex items-center justify-center shadow-xl shadow-orange-500/20 mb-4">
            <Crown className="w-7 h-7 text-white" />
          </div>
          <h1 className="text-2xl font-black text-zinc-100 tracking-wider">VELVET</h1>
          <p className="text-xs text-zinc-400 mt-1 font-medium">Admin & Concierge Command Center</p>
        </div>

        {error && (
          <div className="mt-6 p-3.5 rounded-xl bg-red-500/10 border border-red-500/20 text-red-400 text-xs flex items-center gap-2.5">
            <AlertCircle className="w-4 h-4 shrink-0" />
            <span>{error}</span>
          </div>
        )}

        {step === 'PHONE' ? (
          <form onSubmit={handleRequestOtp} className="mt-6 space-y-4 relative z-10">
            <div>
              <label className="block text-xs font-semibold text-zinc-300 mb-1.5 uppercase tracking-wider">
                Admin Phone Number
              </label>
              <input
                type="text"
                value={phone}
                onChange={(e) => setPhone(e.target.value)}
                placeholder="+251911000000"
                required
                className="w-full bg-zinc-900 border border-zinc-800 rounded-xl px-4 py-3 text-sm text-zinc-100 placeholder-zinc-500 font-mono focus:outline-none focus:border-orange-500/50 transition-all"
              />
              <p className="text-[11px] text-zinc-500 mt-1.5">
                Default Bootstrap Admin: <code className="text-orange-400">+251911000000</code>
              </p>
            </div>

            <button
              type="submit"
              disabled={loading}
              className="w-full py-3 px-4 rounded-xl bg-gradient-to-r from-orange-600 to-amber-600 hover:from-orange-500 hover:to-amber-500 text-white font-bold text-sm flex items-center justify-center gap-2 shadow-lg shadow-orange-500/20 transition-all"
            >
              <span>{loading ? 'Sending OTP...' : 'Continue with Phone'}</span>
              <ArrowRight className="w-4 h-4" />
            </button>
          </form>
        ) : (
          <form onSubmit={handleVerifyOtp} className="mt-6 space-y-4 relative z-10">
            <div>
              <div className="flex items-center justify-between mb-1.5">
                <label className="block text-xs font-semibold text-zinc-300 uppercase tracking-wider">
                  Verification Code (OTP)
                </label>
                <button
                  type="button"
                  onClick={() => setStep('PHONE')}
                  className="text-xs text-orange-400 hover:underline font-medium"
                >
                  Change Phone
                </button>
              </div>

              <input
                type="text"
                value={otp}
                onChange={(e) => setOtp(e.target.value)}
                placeholder="123456"
                maxLength={6}
                required
                className="w-full bg-zinc-900 border border-zinc-800 rounded-xl px-4 py-3 text-center text-lg tracking-widest font-mono text-zinc-100 placeholder-zinc-600 focus:outline-none focus:border-orange-500/50 transition-all"
              />

              {exposedOtp && (
                <div className="mt-2.5 p-2.5 rounded-lg bg-orange-500/10 border border-orange-500/20 text-xs text-orange-300 flex items-center justify-between">
                  <span>Local Dev OTP Exposed:</span>
                  <span className="font-mono font-bold text-orange-400">{exposedOtp}</span>
                </div>
              )}
            </div>

            <button
              type="submit"
              disabled={loading}
              className="w-full py-3 px-4 rounded-xl bg-gradient-to-r from-orange-600 to-amber-600 hover:from-orange-500 hover:to-amber-500 text-white font-bold text-sm flex items-center justify-center gap-2 shadow-lg shadow-orange-500/20 transition-all"
            >
              <ShieldCheck className="w-4 h-4" />
              <span>{loading ? 'Authenticating...' : 'Sign In to Admin Dashboard'}</span>
            </button>
          </form>
        )}

        <div className="mt-8 pt-6 border-t border-zinc-800/80 text-center text-[11px] text-zinc-500 flex items-center justify-center gap-1.5">
          <KeyRound className="w-3.5 h-3.5" />
          <span>Restricted Access • VELVET Staff Only</span>
        </div>
      </div>
    </div>
  );
}
