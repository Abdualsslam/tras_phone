import { createContext, useContext, useState, useEffect, type ReactNode } from 'react';
import type { Admin, LoginRequest } from '@/types';
import { authApi } from '@/api/auth.api';

interface AuthContextType {
    user: Admin | null;
    isAuthenticated: boolean;
    isLoading: boolean;
    login: (credentials: LoginRequest) => Promise<void>;
    logout: () => Promise<void>;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export function AuthProvider({ children }: { children: ReactNode }) {
    const [user, setUser] = useState<Admin | null>(null);
    const [isLoading, setIsLoading] = useState(true);

    useEffect(() => {
        // Check for existing auth on mount
        const initAuth = async () => {
            const token = localStorage.getItem('accessToken');
            const savedUser = localStorage.getItem('user');

            if (token && savedUser) {
                try {
                    // Set user from localStorage first for immediate UI
                    setUser(JSON.parse(savedUser));
                    // Verify token is still valid (interceptor will handle refresh if needed)
                    const profile = await authApi.getProfile();
                    setUser(profile);
                    localStorage.setItem('user', JSON.stringify(profile));
                } catch {
                    // Check if token was refreshed during the request
                    const currentToken = localStorage.getItem('accessToken');
                    if (currentToken && currentToken !== token) {
                        // Token was refreshed, retry getting profile
                        try {
                            const profile = await authApi.getProfile();
                            setUser(profile);
                            localStorage.setItem('user', JSON.stringify(profile));
                        } catch {
                            // Still failed, clear storage
                            localStorage.removeItem('accessToken');
                            localStorage.removeItem('refreshToken');
                            localStorage.removeItem('user');
                            setUser(null);
                        }
                    } else {
                        // Token not refreshed or still invalid, clear storage
                        localStorage.removeItem('accessToken');
                        localStorage.removeItem('refreshToken');
                        localStorage.removeItem('user');
                        setUser(null);
                    }
                }
            }
            setIsLoading(false);
        };

        initAuth();
    }, []);

    const login = async (credentials: LoginRequest) => {
        const response = await authApi.login(credentials);
        localStorage.setItem('accessToken', response.accessToken);
        localStorage.setItem('refreshToken', response.refreshToken);
        localStorage.setItem('user', JSON.stringify(response.user));
        setUser(response.user);
    };

    const logout = async () => {
        try {
            await authApi.logout();
        } catch {
            // Ignore logout errors
        } finally {
            localStorage.removeItem('accessToken');
            localStorage.removeItem('refreshToken');
            localStorage.removeItem('user');
            setUser(null);
        }
    };

    return (
        <AuthContext.Provider
            value={{
                user,
                isAuthenticated: !!user,
                isLoading,
                login,
                logout,
            }}
        >
            {children}
        </AuthContext.Provider>
    );
}

export function useAuth() {
    const context = useContext(AuthContext);
    if (context === undefined) {
        throw new Error('useAuth must be used within an AuthProvider');
    }
    return context;
}
