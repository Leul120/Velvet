export interface PaymentIntentAdminItem {
  id: string;
  userId: string;
  userName: string;
  userPhone: string;
  userRole: string;
  purpose: string; // MEMBERSHIP | BOOKING
  bookingId?: string | null;
  provider: string; // CBE | TELEBIRR
  merchantOrderId: string;
  amountEtb: number;
  currency: string;
  status: 'PENDING' | 'CHECKOUT' | 'PAID' | 'FAILED' | 'CANCELLED' | 'EXPIRED' | 'REFUND_PENDING' | 'REFUNDED';
  receiptUrl?: string | null;
  providerRef?: string | null;
  createdAt: string;
  paidAt?: string | null;
}

export interface MemberSummary {
  userId: string;
  phoneE164: string;
  displayName: string;
  role: string;
  status: string;
  notes?: string | null;
  photoCount: number;
  photoVerified: boolean;
  createdAt: string;
}

export interface PanicAlert {
  id: string;
  userId: string;
  bookingId?: string;
  connectionId?: string;
  status: 'OPEN' | 'ACKNOWLEDGED' | 'RESOLVED';
  note?: string;
  createdAt: string;
}

export interface SafetyReport {
  id: string;
  category: string;
  details: string;
  status: 'OPEN' | 'UNDER_REVIEW' | 'RESOLVED' | 'DISMISSED';
  reporterId: string;
  createdAt: string;
}

export interface VenueAdminResponse {
  id: string;
  name: string;
  neighborhood: string;
  address: string;
  perksNote: string;
  active: boolean;
  partnerUserId?: string | null;
}

export interface InviteResponse {
  id: string;
  code: string;
  recipientName?: string | null;
  recipientPhoneE164?: string | null;
  active: boolean;
  usesCount: number;
  maxUses: number;
  createdAt: string;
}

export interface AuthState {
  accessToken: string | null;
  user: {
    userId: string;
    phoneE164: string;
    role: string;
  } | null;
}
