'use client';

import React, { createContext, useContext, useEffect, useState } from 'react';
import { getAuthToken, setAuthToken, removeAuthToken } from './api';
import { useRouter, usePathname } from 'next/navigation';

interface AuthContextType {
  token: string | null;
  isAuthenticated: boolean;
  isLoading: boolean;
  login: (token: string) => void;
  logout: () => void;
}

const AuthContext = createContext<AuthContextType>({
  token: null,
  isAuthenticated: false,
  isLoading: true,
  login: () => {},
  logout: () => {},
});

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [token, setToken] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const router = useRouter();
  const pathname = usePathname();

  useEffect(() => {
    const savedToken = getAuthToken();
    if (savedToken) {
      setToken(savedToken);
    } else if (pathname !== '/login') {
      router.push('/login');
    }
    setIsLoading(false);
  }, [pathname, router]);

  const login = (newToken: string) => {
    setAuthToken(newToken);
    setToken(newToken);
    router.push('/');
  };

  const logout = () => {
    removeAuthToken();
    setToken(null);
    router.push('/login');
  };

  return (
    <AuthContext.Provider
      value={{
        token,
        isAuthenticated: !!token,
        isLoading,
        login,
        logout,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
}

export const useAuth = () => useContext(AuthContext);
