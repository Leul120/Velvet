import { PaymentIntentAdminItem, MemberSummary, PanicAlert, SafetyReport, VenueAdminResponse, InviteResponse } from './types';

const API_BASE = process.env.NEXT_PUBLIC_API_BASE_URL || 'http://localhost:8080';

export function getAuthToken(): string | null {
  if (typeof window === 'undefined') return null;
  return localStorage.getItem('velvet_admin_token');
}

export function setAuthToken(token: string) {
  if (typeof window !== 'undefined') {
    localStorage.setItem('velvet_admin_token', token);
  }
}

export function removeAuthToken() {
  if (typeof window !== 'undefined') {
    localStorage.removeItem('velvet_admin_token');
  }
}

async function request<T>(endpoint: string, options: RequestInit = {}): Promise<T> {
  const token = getAuthToken();
  const headers: Record<string, string> = {
    'Content-Type': 'application/json',
    ...(options.headers as Record<string, string> || {}),
  };

  if (token) {
    headers['Authorization'] = `Bearer ${token}`;
  }


  const url = `${API_BASE}${endpoint}`;
  const response = await fetch(url, {
    ...options,
    headers,
  });

  if (response.status === 401) {
    removeAuthToken();
    if (typeof window !== 'undefined' && window.location.pathname !== '/login') {
      window.location.href = '/login';
    }
    throw new Error('Session expired. Please log in again.');
  }

  if (!response.ok) {
    let errorMsg = `HTTP Error ${response.status}`;
    try {
      const errJson = await response.json();
      if (errJson.message) errorMsg = errJson.message;
      else if (errJson.error) errorMsg = errJson.error;
    } catch (_) {}
    throw new Error(errorMsg);
  }

  if (response.status === 204) {
    return {} as T;
  }

  return response.json();
}

// ── Auth ──────────────────────────────────────────────────────────────────────

export async function requestOtp(phone: string) {
  return request<{ status: string; codeExposed?: string }>('/v1/auth/otp/request', {
    method: 'POST',
    body: JSON.stringify({ phone }),
  });
}

export async function verifyOtp(phone: string, code: string) {
  return request<{ accessToken: string; userId: string; role: string }>('/v1/auth/otp/verify', {
    method: 'POST',
    body: JSON.stringify({ phone, code }),
  });
}

// ── Payments ──────────────────────────────────────────────────────────────────

export async function fetchPayments(status?: string, page = 0, size = 50) {
  const query = new URLSearchParams();
  if (status && status !== 'ALL') query.set('status', status);
  query.set('page', page.toString());
  query.set('size', size.toString());
  return request<PaymentIntentAdminItem[]>(`/v1/admin/payments?${query.toString()}`);
}

export async function approvePayment(id: string, notes?: string) {
  return request<PaymentIntentAdminItem>(`/v1/admin/payments/${id}/approve`, {
    method: 'POST',
    body: JSON.stringify({ notes: notes || 'Approved by Admin' }),
  });
}

export async function rejectPayment(id: string, notes?: string) {
  return request<PaymentIntentAdminItem>(`/v1/admin/payments/${id}/reject`, {
    method: 'POST',
    body: JSON.stringify({ notes: notes || 'Rejected by Admin' }),
  });
}

// ── Members ───────────────────────────────────────────────────────────────────

export async function fetchMembers(q?: string, status?: string, role?: string) {
  const query = new URLSearchParams();
  if (q) query.set('q', q);
  if (status) query.set('status', status);
  if (role) query.set('role', role);
  return request<MemberSummary[]>(`/v1/admin/members?${query.toString()}`);
}

export async function updateMemberNotes(userId: string, notes: string) {
  return request<MemberSummary>(`/v1/admin/members/${userId}/notes`, {
    method: 'PATCH',
    body: JSON.stringify({ notes }),
  });
}

export async function updateMemberStatus(userId: string, status: string, notes?: string) {
  return request<MemberSummary>(`/v1/admin/members/${userId}/status`, {
    method: 'PATCH',
    body: JSON.stringify({ status, notes }),
  });
}

// ── Safety & Panics ───────────────────────────────────────────────────────────

export async function fetchPanics() {
  return request<PanicAlert[]>('/v1/admin/safety/panics');
}

export async function ackPanic(id: string) {
  return request<PanicAlert>(`/v1/admin/safety/panics/${id}/ack`, {
    method: 'POST',
  });
}

export async function fetchReports() {
  return request<SafetyReport[]>('/v1/admin/safety/reports');
}

// ── Venues & Invites ──────────────────────────────────────────────────────────

export async function fetchVenues() {
  return request<VenueAdminResponse[]>('/v1/admin/venues');
}

export async function fetchInvites() {
  return request<InviteResponse[]>('/v1/admin/invites');
}

export async function createInvite(code: string, maxUses = 100) {
  return request<InviteResponse>('/v1/admin/invites', {
    method: 'POST',
    body: JSON.stringify({ code, maxUses }),
  });
}
