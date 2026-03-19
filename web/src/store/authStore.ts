import { create } from 'zustand';
import { persist } from 'zustand/middleware';
import { AuthService } from '../services/AuthService';
import { Usuario } from '@/types';

interface AuthState {
    isAuthenticated: boolean;
    user: Usuario | null;
    token: string | null;
    isLoading: boolean;
    error: string | null;
    login: (email: string, password: string) => Promise<void>;
    logout: () => void;
}

export const useAuthStore = create<AuthState>()(
    persist(
        (set) => ({
            isAuthenticated: false,
            user: null,
            token: null,
            isLoading: false,
            error: null,

            login: async (email, password) => {
                set({ isLoading: true, error: null });
                try {
                    const data = await AuthService.login(email, password);
                    set({ 
                        isAuthenticated: true, 
                        user: data.user, 
                        token: data.access_token,
                        isLoading: false 
                    });
                } catch (error: any) {
                    console.error("Erro no login", error);
                    set({ 
                        isAuthenticated: false, 
                        user: null, 
                        token: null,
                        error: "Falha ao realizar login. Verifique suas credenciais.",
                        isLoading: false 
                    });
                    throw error;
                }
            },

            logout: () => {
                AuthService.logout();
                set({ isAuthenticated: false, user: null, token: null });
            },
        }),
        {
            name: 'auth-storage',
            partialize: (state) => ({ 
                isAuthenticated: state.isAuthenticated, 
                user: state.user, 
                token: state.token 
            }), // Persiste apenas dados essenciais
        }
    )
);
