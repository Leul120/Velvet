'use client';

import React, { useEffect, useState, useCallback } from 'react';
import { Sidebar } from '@/components/sidebar';
import { Header } from '@/components/header';
import { fetchPhotoReviewQueue, reviewMemberPhotos } from '@/lib/api';
import { PhotoReviewItem } from '@/lib/types';
import { 
  Camera, 
  CheckCircle2, 
  XCircle, 
  RefreshCw, 
  Search,
  ExternalLink,
  Eye
} from 'lucide-react';

export default function PhotoReviewPage() {
  const [items, setItems] = useState<PhotoReviewItem[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');

  const [activePhoto, setActivePhoto] = useState<string | null>(null);
  const [reviewingItem, setReviewingItem] = useState<PhotoReviewItem | null>(null);
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
      const data = await fetchPhotoReviewQueue();
      setItems(data);
    } catch (err) {
      console.error('Failed to load photo review queue:', err);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    loadQueue();
  }, [loadQueue]);

  const handleReviewConfirm = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!reviewingItem || !reviewType) return;
    setSubmitting(true);
    try {
      await reviewMemberPhotos(
        reviewingItem.userId,
        reviewType === 'APPROVE',
        notes || (reviewType === 'APPROVE' ? 'Approved by admin' : 'Rejected quality standards')
      );
      setReviewingItem(null);
      setReviewType(null);
      setNotes('');
      await loadQueue();
    } catch (err) {
      alert((err as Error).message);
    } finally {
      setSubmitting(false);
    }
  };

  const filteredItems = items.filter((item) => {
    if (!searchTerm) return true;
    return item.displayName?.toLowerCase().includes(searchTerm.toLowerCase());
  });

  return (
    <div className="flex min-h-screen bg-[#09090b]">
      <Sidebar />

      <main className="flex-1 flex flex-col min-w-0">
        <Header 
          title="Performer Photo Review Queue" 
          subtitle="Moderate uploaded gallery and listing photos before they appear publicly" 
        />

        <div className="p-8 space-y-6 flex-1">
          {/* Controls Bar */}
          <div className="flex flex-col sm:flex-row items-stretch sm:items-center justify-between gap-4">
            <div className="relative w-full sm:w-72">
              <Search className="w-4 h-4 text-zinc-500 absolute left-3.5 top-1/2 -translate-y-1/2" />
              <input
                type="text"
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                placeholder="Search member name..."
                className="w-full bg-[#121215] border border-zinc-800 rounded-xl pl-10 pr-4 py-2 text-xs text-zinc-100 placeholder-zinc-500 focus:outline-none focus:border-orange-500/50"
              />
            </div>

            <button
              onClick={loadQueue}
              disabled={loading}
              className="p-2.5 rounded-xl bg-[#121215] border border-zinc-800 text-zinc-400 hover:text-zinc-100 transition-all self-start sm:self-auto"
            >
              <RefreshCw className={`w-4 h-4 ${loading ? 'animate-spin' : ''}`} />
            </button>
          </div>

          {/* Cards Grid */}
          {loading ? (
            <div className="bg-[#121215] border border-zinc-800 rounded-2xl p-16 text-center text-zinc-500">
              <RefreshCw className="w-6 h-6 animate-spin mx-auto mb-2 text-orange-500" />
              Loading photo review queue...
            </div>
          ) : filteredItems.length === 0 ? (
            <div className="bg-[#121215] border border-zinc-800 rounded-2xl p-16 text-center text-zinc-500">
              <CheckCircle2 className="w-8 h-8 text-emerald-500/60 mx-auto mb-3" />
              <p className="text-zinc-300 font-medium">All caught up!</p>
              <p className="text-xs text-zinc-500 mt-1">No performer profiles currently waiting for photo moderation.</p>
            </div>
          ) : (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
              {filteredItems.map((item) => (
                <div key={item.userId} className="bg-[#121215] border border-zinc-800 rounded-2xl p-5 flex flex-col justify-between space-y-4">
                  <div>
                    <div className="flex items-center justify-between mb-3">
                      <div>
                        <h4 className="font-bold text-zinc-100 text-sm">{item.displayName || 'Performer'}</h4>
                        <span className="text-[10px] text-zinc-500">Updated {new Date(item.updatedAt).toLocaleDateString()}</span>
                      </div>
                      <span className="text-[10px] font-bold px-2 py-0.5 rounded-full bg-amber-500/15 text-amber-400 border border-amber-500/30">
                        NEEDS_REVIEW
                      </span>
                    </div>

                    {/* Photos Preview */}
                    <div className="grid grid-cols-3 gap-2">
                      {item.photoUrls && item.photoUrls.length > 0 ? (
                        item.photoUrls.slice(0, 6).map((url, i) => (
                          <div 
                            key={i} 
                            onClick={() => setActivePhoto(formatImageUrl(url))}
                            className="aspect-square rounded-xl bg-zinc-900 border border-zinc-800/80 overflow-hidden relative cursor-pointer group"
                          >
                            <img 
                              src={formatImageUrl(url)} 
                              alt="Photo thumbnail" 
                              className="w-full h-full object-cover transition-transform group-hover:scale-105"
                            />
                            <div className="absolute inset-0 bg-black/40 opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center">
                              <Eye className="w-4 h-4 text-white" />
                            </div>
                          </div>
                        ))
                      ) : (
                        <div className="col-span-3 py-8 text-center text-zinc-600 text-xs">
                          No photos attached
                        </div>
                      )}
                    </div>
                  </div>

                  {/* Actions */}
                  <div className="flex items-center gap-2 pt-2 border-t border-zinc-800/60">
                    <button
                      onClick={() => {
                        setReviewingItem(item);
                        setReviewType('APPROVE');
                        setNotes('');
                      }}
                      className="flex-1 flex items-center justify-center gap-1.5 py-2 rounded-xl bg-emerald-600/15 border border-emerald-500/30 text-emerald-400 hover:bg-emerald-600/30 text-xs font-semibold transition-all"
                    >
                      <CheckCircle2 className="w-3.5 h-3.5" />
                      Approve
                    </button>
                    <button
                      onClick={() => {
                        setReviewingItem(item);
                        setReviewType('REJECT');
                        setNotes('');
                      }}
                      className="flex-1 flex items-center justify-center gap-1.5 py-2 rounded-xl bg-red-600/15 border border-red-500/30 text-red-400 hover:bg-red-600/30 text-xs font-semibold transition-all"
                    >
                      <XCircle className="w-3.5 h-3.5" />
                      Reject
                    </button>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      </main>

      {/* Image Preview Modal */}
      {activePhoto && (
        <div 
          onClick={() => setActivePhoto(null)}
          className="fixed inset-0 z-50 bg-black/90 backdrop-blur-md flex items-center justify-center p-4 cursor-pointer"
        >
          <div className="max-w-3xl max-h-[85vh] rounded-2xl overflow-hidden border border-zinc-800 shadow-2xl">
            <img src={activePhoto} alt="Full preview" className="max-w-full max-h-[85vh] object-contain" />
          </div>
        </div>
      )}

      {/* Review Confirmation Modal */}
      {reviewingItem && reviewType && (
        <div className="fixed inset-0 z-50 bg-black/80 backdrop-blur-sm flex items-center justify-center p-4">
          <div className="bg-[#141418] border border-zinc-800 rounded-3xl max-w-md w-full p-6 shadow-2xl">
            <h3 className="font-bold text-zinc-100">
              {reviewType === 'APPROVE' ? 'Approve Performer Photos' : 'Reject Performer Photos'}
            </h3>
            <p className="text-xs text-zinc-400 mt-1">
              {reviewingItem.displayName} • {reviewingItem.photoUrls?.length || 0} photos
            </p>

            <form onSubmit={handleReviewConfirm} className="mt-4 space-y-4">
              <div>
                <label className="block text-xs font-semibold text-zinc-300 mb-1.5">
                  Moderator Notes
                </label>
                <textarea
                  value={notes}
                  onChange={(e) => setNotes(e.target.value)}
                  placeholder={reviewType === 'APPROVE' ? 'Looks good, compliant with policy.' : 'Explain violation (e.g. blur, underage appearance, non-compliant background)...'}
                  rows={3}
                  className="w-full bg-[#1c1c21] border border-zinc-700/60 rounded-xl p-3 text-xs text-zinc-100 placeholder-zinc-500 focus:outline-none focus:border-orange-500/60"
                />
              </div>

              <div className="flex items-center justify-end gap-3 pt-2">
                <button
                  type="button"
                  onClick={() => {
                    setReviewingItem(null);
                    setReviewType(null);
                  }}
                  className="px-4 py-2 rounded-xl text-xs font-semibold text-zinc-400 hover:text-zinc-200"
                >
                  Cancel
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
                  {submitting ? 'Saving...' : reviewType === 'APPROVE' ? 'Approve Photos' : 'Reject Photos'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
