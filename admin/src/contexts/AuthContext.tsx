import { createContext, useContext, useState, useEffect, useMemo, type ReactNode } from 'react';
import type { AccessRequirement, Admin, LoginRequest } from '@/types';
import { authApi } from '@/api/auth.api';
import { socketService } from '@/services/socket.service';
import { canAccess, extractUserPermissions } from '@/lib/access-control';

interface AuthContextType {
    user: Admin | null;
    token: string | null;
    permissions: string[];
    isAuthenticated: boolean;
    isLoading: boolean;
    hasAccess: (requirement?: AccessRequirement, requiredFeatureFlags?: string[]) => boolean;
    login: (credentials: LoginRequest) => Promise<void>;
    logout: () => Promise<void>;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export function AuthProvider({ children }: { children: ReactNode }) {
    const [user, setUser] = useState<Admin | null>(null);
    const [token, setToken] = useState<string | null>(null);
    const [isLoading, setIsLoading] = useState(true);

    useEffect(() => {
        // Check for existing auth on mount
        const initAuth = async () => {
            const savedToken = localStorage.getItem('accessToken');
            const savedUser = localStorage.getItem('user');

            if (savedToken && savedUser) {
                try {
                    // Set user from localStorage first for immediate UI
                    setUser(JSON.parse(savedUser));
                    setToken(savedToken);
                    // Verify token is still valid (interceptor will handle refresh if needed)
                    const profile = await authApi.getProfile();
                    setUser(profile);
                    localStorage.setItem('user', JSON.stringify(profile));
                } catch {
                    // Check if token was refreshed during the request
                    const currentToken = localStorage.getItem('accessToken');
                    if (currentToken && currentToken !== savedToken) {
                        // Token was refreshed, retry getting profile
                        try {
                            const profile = await authApi.getProfile();
                            setUser(profile);
                            setToken(currentToken);
                            localStorage.setItem('user', JSON.stringify(profile));
                        } catch {
                            // Still failed, clear storage
                            localStorage.removeItem('accessToken');
                            localStorage.removeItem('refreshToken');
                            localStorage.removeItem('user');
                            setUser(null);
                            setToken(null);
                        }
                    } else {
                        // Token not refreshed or still invalid, clear storage
                        localStorage.removeItem('accessToken');
                        localStorage.removeItem('refreshToken');
                        localStorage.removeItem('user');
                        setUser(null);
                        setToken(null);
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
        setToken(response.accessToken);

        try {
            const profile = await authApi.getProfile();
            localStorage.setItem('user', JSON.stringify(profile));
            setUser(profile);
        } catch {
            localStorage.setItem('user', JSON.stringify(response.user));
            setUser(response.user);
        }
    };

    const logout = async () => {
        try {
            await authApi.logout();
        } catch {
            // Ignore logout errors
        } finally {
            socketService.disconnect();
            localStorage.removeItem('accessToken');
            localStorage.removeItem('refreshToken');
            localStorage.removeItem('user');
            setUser(null);
            setToken(null);
        }
    };

    const permissions = useMemo(() => extractUserPermissions(user), [user]);

    const hasAccessTo = (requirement?: AccessRequirement, requiredFeatureFlags?: string[]) =>
        canAccess(user, requirement, requiredFeatureFlags);

    return (
        <AuthContext.Provider
            value={{
                user,
                token,
                permissions,
                isAuthenticated: !!user,
                isLoading,
                hasAccess: hasAccessTo,
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
