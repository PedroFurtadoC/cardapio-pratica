import { create } from 'zustand';
import { persist } from 'zustand/middleware';

interface AuthState {
    isAuthenticated: boolean;
    user: { email: string; name: string } | null;
    login: (email: string) => void;
    logout: () => void;
}

export const useAuthStore = create<AuthState>()(
    persist(
        (set) => ({
            isAuthenticated: false,
            user: null,
            login: (email) => set({ isAuthenticated: true, user: { email, name: 'Admin' } }),
            logout: () => set({ isAuthenticated: false, user: null }),
        }),
        {
            name: 'auth-storage',
        }
    )
);
