import { createContext, useContext, useState, useEffect, useMemo, type ReactNode } from 'react';
import type { AccessRequirement, Admin, LoginRequest } from '@/types';
import { authApi } from '@/api/auth.api';
import { socketService } from '@/services/socket.service';
import { canAccess, extractUserPermissions } from '@/lib/access-control';

const hasAdminAccessPayload = (user: Admin | null | undefined): boolean => {
    if (!user) return false;
    return (
        typeof user.isSuperAdmin === 'boolean' ||
        typeof user.canAccessWeb === 'boolean' ||
        Array.isArray(user.permissions) ||
        Array.isArray(user.roles) ||
        !!user.role
    );
};

const mergeAccessProfile = (baseUser: Admin, fallbackUser?: Admin | null): Admin => {
    if (!fallbackUser) return baseUser;
    if (hasAdminAccessPayload(baseUser)) return baseUser;

    return {
        ...baseUser,
        isSuperAdmin: fallbackUser.isSuperAdmin,
        canAccessWeb: fallbackUser.canAccessWeb,
        canAccessMobile: fallbackUser.canAccessMobile,
        permissions: fallbackUser.permissions,
        roles: fallbackUser.roles,
        role: fallbackUser.role,
        featureFlags: fallbackUser.featureFlags,
        features: fallbackUser.features,
    };
};

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
                    const cachedUser = JSON.parse(savedUser) as Admin;
                    setUser(cachedUser);
                    setToken(savedToken);
                    // Verify token is still valid (interceptor will handle refresh if needed)
                    const profile = await authApi.getProfile();
                    const mergedProfile = mergeAccessProfile(profile, cachedUser);
                    setUser(mergedProfile);
                    localStorage.setItem('user', JSON.stringify(mergedProfile));
                } catch {
                    // Check if token was refreshed during the request
                    const currentToken = localStorage.getItem('accessToken');
                    if (currentToken && currentToken !== savedToken) {
                        // Token was refreshed, retry getting profile
                        try {
                            const profile = await authApi.getProfile();
                            const cachedUser = savedUser ? (JSON.parse(savedUser) as Admin) : null;
                            const mergedProfile = mergeAccessProfile(profile, cachedUser);
                            setUser(mergedProfile);
                            setToken(currentToken);
                            localStorage.setItem('user', JSON.stringify(mergedProfile));
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
            const mergedProfile = mergeAccessProfile(profile, response.user);
            localStorage.setItem('user', JSON.stringify(mergedProfile));
            setUser(mergedProfile);
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
