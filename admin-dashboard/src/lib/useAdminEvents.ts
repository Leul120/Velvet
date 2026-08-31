'use client';

import { useEffect, useState } from 'react';
import { getAuthToken } from './api';

export interface AdminEventData {
  type: string;
  payload: any;
  timestamp: string;
}

export function useAdminEvents(onEvent?: (event: AdminEventData) => void) {
  const [isConnected, setIsConnected] = useState(false);
  const [lastEvent, setLastEvent] = useState<AdminEventData | null>(null);

  const playChime = () => {
    try {
      const audioCtx = new (window.AudioContext || (window as any).webkitAudioContext)();
      const osc = audioCtx.createOscillator();
      const gain = audioCtx.createGain();
      osc.type = 'sine';
      osc.frequency.setValueAtTime(587.33, audioCtx.currentTime); // D5
      osc.frequency.exponentialRampToValueAtTime(880, audioCtx.currentTime + 0.15); // A5
      gain.gain.setValueAtTime(0.15, audioCtx.currentTime);
      gain.gain.exponentialRampToValueAtTime(0.001, audioCtx.currentTime + 0.3);
      osc.connect(gain);
      gain.connect(audioCtx.destination);
      osc.start();
      osc.stop(audioCtx.currentTime + 0.3);
    } catch (_) {}
  };

  useEffect(() => {
    const API_BASE = process.env.NEXT_PUBLIC_API_BASE_URL || 'http://localhost:8080';
    const streamUrl = `${API_BASE}/v1/admin/events/stream`;

    const eventSource = new EventSource(streamUrl);

    eventSource.onopen = () => {
      setIsConnected(true);
    };

    eventSource.onerror = () => {
      setIsConnected(false);
    };

    const handleEvent = (type: string, dataStr: string) => {
      try {
        const payload = JSON.parse(dataStr);
        const eventData: AdminEventData = {
          type,
          payload,
          timestamp: new Date().toISOString(),
        };
        setLastEvent(eventData);
        playChime();
        if (onEvent) onEvent(eventData);
      } catch (_) {}
    };

    eventSource.addEventListener('CONNECTED', (e) => handleEvent('CONNECTED', e.data));
    eventSource.addEventListener('PAYMENT_PROOF_SUBMITTED', (e) => handleEvent('PAYMENT_PROOF_SUBMITTED', e.data));
    eventSource.addEventListener('PANIC_ALERT', (e) => handleEvent('PANIC_ALERT', e.data));
    eventSource.addEventListener('SAFETY_REPORT', (e) => handleEvent('SAFETY_REPORT', e.data));

    return () => {
      eventSource.close();
    };
  }, [onEvent]);

  return { isConnected, lastEvent };
}
