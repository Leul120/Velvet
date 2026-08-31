'use client';

import React, { useEffect, useState } from 'react';
import { Sidebar } from '@/components/sidebar';
import { Header } from '@/components/header';
import { fetchMembers, updateMemberNotes, updateMemberStatus } from '@/lib/api';
import { MemberSummary } from '@/lib/types';
import { Users, Search, RefreshCw, Shield, CheckCircle, Ban, Edit3, Camera } from 'lucide-react';

export default function MembersPage() {
  const [members, setMembers] = useState<MemberSummary[]>([]);
  const [searchTerm, setSearchTerm] = useState('');
  const [roleFilter, setRoleFilter] = useState('');
  const [loading, setLoading] = useState(true);
  const [editingNotesUser, setEditingNotesUser] = useState<MemberSummary | null>(null);
  const [noteText, setNoteText] = useState('');

  const loadMembers = async () => {
    setLoading(true);
    try {
      const data = await fetchMembers(searchTerm || undefined, undefined, roleFilter || undefined);
      setMembers(data);
    } catch (err) {
      console.error('Failed to load members:', err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadMembers();
  }, [roleFilter]);

  const handleSaveNotes = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!editingNotesUser) return;
    try {
      await updateMemberNotes(editingNotesUser.userId, noteText);
      setEditingNotesUser(null);
      await loadMembers();
    } catch (err) {
      alert((err as Error).message);
    }
  };

  const handleToggleStatus = async (member: MemberSummary) => {
    const newStatus = member.status === 'SUSPENDED' ? 'ACTIVE' : 'SUSPENDED';
    if (!confirm(`Are you sure you want to change status of ${member.displayName} to ${newStatus}?`)) return;
    try {
      await updateMemberStatus(member.userId, newStatus, 'Admin status update');
      await loadMembers();
    } catch (err) {
      alert((err as Error).message);
    }
  };

  return (
    <div className="flex min-h-screen bg-[#09090b]">
      <Sidebar />

      <main className="flex-1 flex flex-col min-w-0">
        <Header title="Member Directory" subtitle="Manage members, performers, photo verifications, and staff notes" />

        <div className="p-8 space-y-6 flex-1">
          {/* Controls Bar */}
          <div className="flex flex-col sm:flex-row items-stretch sm:items-center justify-between gap-4">
            <div className="flex items-center gap-3">
              <div className="relative w-64">
                <Search className="w-4 h-4 text-zinc-500 absolute left-3.5 top-1/2 -translate-y-1/2" />
                <input
                  type="text"
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                  onKeyDown={(e) => e.key === 'Enter' && loadMembers()}
                  placeholder="Search name or phone..."
                  className="w-full bg-[#121215] border border-zinc-800 rounded-xl pl-10 pr-4 py-2 text-xs text-zinc-100 placeholder-zinc-500 focus:outline-none focus:border-orange-500/50"
                />
              </div>

              <select
                value={roleFilter}
                onChange={(e) => setRoleFilter(e.target.value)}
                className="bg-[#121215] border border-zinc-800 rounded-xl px-3 py-2 text-xs text-zinc-300 focus:outline-none"
              >
                <option value="">All Roles</option>
                <option value="MEMBER">Member</option>
                <option value="PERFORMER">Performer</option>
                <option value="VENUE_PARTNER">Venue Partner</option>
                <option value="ADMIN">Admin</option>
              </select>
            </div>

            <button
              onClick={loadMembers}
              disabled={loading}
              className="p-2.5 rounded-xl bg-[#121215] border border-zinc-800 text-zinc-400 hover:text-zinc-100 transition-all self-start sm:self-auto"
            >
              <RefreshCw className={`w-4 h-4 ${loading ? 'animate-spin' : ''}`} />
            </button>
          </div>

          {/* Members Table */}
          <div className="bg-[#121215] border border-zinc-800 rounded-3xl overflow-hidden shadow-sm">
            {loading ? (
              <div className="p-12 text-center text-zinc-500 text-sm flex items-center justify-center gap-2">
                <RefreshCw className="w-4 h-4 animate-spin text-orange-500" />
                <span>Loading members...</span>
              </div>
            ) : members.length === 0 ? (
              <div className="p-12 text-center text-zinc-500">
                <Users className="w-10 h-10 mx-auto mb-3 opacity-30 text-zinc-400" />
                <p className="text-sm font-semibold">No members found</p>
              </div>
            ) : (
              <div className="overflow-x-auto">
                <table className="w-full text-left border-collapse">
                  <thead>
                    <tr className="border-b border-zinc-800/80 bg-zinc-900/40 text-[11px] font-bold text-zinc-400 uppercase tracking-wider">
                      <th className="py-4 px-6">Member</th>
                      <th className="py-4 px-6">Role</th>
                      <th className="py-4 px-6">Photo Status</th>
                      <th className="py-4 px-6">Notes</th>
                      <th className="py-4 px-6">Status</th>
                      <th className="py-4 px-6 text-right">Actions</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-zinc-800/60 text-sm">
                    {members.map((m) => (
                      <tr key={m.userId} className="hover:bg-zinc-900/30 transition-all">
                        <td className="py-4 px-6">
                          <div className="font-bold text-zinc-100">{m.displayName || 'Unnamed Member'}</div>
                          <div className="text-xs font-mono text-zinc-400">{m.phoneE164}</div>
                        </td>

                        <td className="py-4 px-6">
                          <span className="text-xs font-semibold px-2.5 py-1 rounded-lg bg-zinc-800 text-zinc-300 border border-zinc-700">
                            {m.role}
                          </span>
                        </td>

                        <td className="py-4 px-6">
                          <div className="flex items-center gap-1.5 text-xs">
                            <Camera className="w-3.5 h-3.5 text-zinc-500" />
                            <span className="text-zinc-300 font-medium">{m.photoCount} Photos</span>
                            {m.photoVerified && (
                              <span className="text-[10px] font-bold text-emerald-400 bg-emerald-500/10 px-2 py-0.5 rounded border border-emerald-500/20">
                                Verified
                              </span>
                            )}
                          </div>
                        </td>

                        <td className="py-4 px-6 max-w-xs truncate">
                          {m.notes ? (
                            <span className="text-xs text-zinc-300 italic">{m.notes}</span>
                          ) : (
                            <span className="text-xs text-zinc-600">No notes</span>
                          )}
                        </td>

                        <td className="py-4 px-6">
                          <span
                            className={`inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-xs font-bold border ${
                              m.status === 'ACTIVE'
                                ? 'bg-emerald-500/15 text-emerald-400 border-emerald-500/30'
                                : 'bg-red-500/15 text-red-400 border-red-500/30'
                            }`}
                          >
                            <span>{m.status}</span>
                          </span>
                        </td>

                        <td className="py-4 px-6 text-right">
                          <div className="flex items-center justify-end gap-2">
                            <button
                              onClick={() => {
                                setEditingNotesUser(m);
                                setNoteText(m.notes || '');
                              }}
                              className="p-1.5 rounded-lg bg-zinc-900 border border-zinc-800 text-zinc-300 hover:text-zinc-100 transition-all text-xs"
                              title="Edit Admin Notes"
                            >
                              <Edit3 className="w-3.5 h-3.5" />
                            </button>

                            <button
                              onClick={() => handleToggleStatus(m)}
                              className={`p-1.5 rounded-lg border text-xs transition-all ${
                                m.status === 'SUSPENDED'
                                  ? 'bg-emerald-500/10 text-emerald-400 border-emerald-500/20'
                                  : 'bg-red-500/10 text-red-400 border-red-500/20'
                              }`}
                              title={m.status === 'SUSPENDED' ? 'Activate Member' : 'Suspend Member'}
                            >
                              {m.status === 'SUSPENDED' ? <CheckCircle className="w-3.5 h-3.5" /> : <Ban className="w-3.5 h-3.5" />}
                            </button>
                          </div>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            )}
          </div>
        </div>
      </main>

      {/* Edit Notes Modal */}
      {editingNotesUser && (
        <div className="fixed inset-0 z-50 bg-black/80 backdrop-blur-sm flex items-center justify-center p-4">
          <div className="bg-[#141418] border border-zinc-800 rounded-3xl max-w-md w-full p-6 shadow-2xl">
            <h3 className="font-bold text-zinc-100">Update Admin Notes</h3>
            <p className="text-xs text-zinc-400 mt-1">{editingNotesUser.displayName} ({editingNotesUser.phoneE164})</p>

            <form onSubmit={handleSaveNotes} className="mt-4 space-y-4">
              <textarea
                value={noteText}
                onChange={(e) => setNoteText(e.target.value)}
                placeholder="Enter admin notes about this member..."
                className="w-full h-24 bg-zinc-900 border border-zinc-800 rounded-xl p-3 text-sm text-zinc-100 focus:outline-none focus:border-orange-500/50"
              />
              <div className="flex items-center gap-3">
                <button
                  type="button"
                  onClick={() => setEditingNotesUser(null)}
                  className="w-1/2 py-2.5 rounded-xl border border-zinc-800 text-zinc-300 text-sm font-semibold hover:bg-zinc-800"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="w-1/2 py-2.5 rounded-xl bg-orange-600 hover:bg-orange-500 text-white font-bold text-sm"
                >
                  Save Notes
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
