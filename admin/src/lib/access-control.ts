import type { SidebarSectionConfig } from '@/config/navigation';
import type { AccessRequirement, Admin } from '@/types';

type UnknownRecord = Record<string, unknown>;

const hasOwn = (value: UnknownRecord, key: string): boolean =>
    Object.prototype.hasOwnProperty.call(value, key);

const normalize = (value: string): string => value.trim().toLowerCase();

const collectPermissionNames = (value: unknown): string[] => {
    if (typeof value === 'string') {
        return [normalize(value)];
    }

    if (Array.isArray(value)) {
        return value.flatMap((entry) => collectPermissionNames(entry));
    }

    if (!value || typeof value !== 'object') {
        return [];
    }

    const record = value as UnknownRecord;
    const result: string[] = [];

    if (typeof record.name === 'string') {
        result.push(normalize(record.name));
    }

    if (typeof record.permission === 'string') {
        result.push(normalize(record.permission));
    }

    if (typeof record.module === 'string' && typeof record.action === 'string') {
        result.push(normalize(`${record.module}.${record.action}`));
    }

    if (hasOwn(record, 'permissions')) {
        result.push(...collectPermissionNames(record.permissions));
    }

    return result;
};

const collectFeatureFlags = (user: Admin | null): string[] => {
    if (!user) {
        return [];
    }

    const featureFlags = [
        ...(Array.isArray(user.featureFlags) ? user.featureFlags : []),
        ...(Array.isArray(user.features) ? user.features : []),
    ];

    return featureFlags
        .filter((flag): flag is string => typeof flag === 'string' && flag.trim().length > 0)
        .map((flag) => flag.trim());
};

export const hasPermissionPayload = (user: Admin | null): boolean => {
    if (!user) {
        return false;
    }

    const record = user as unknown as UnknownRecord;
    return hasOwn(record, 'permissions') || hasOwn(record, 'roles') || hasOwn(record, 'role');
};

export const extractUserPermissions = (user: Admin | null): string[] => {
    if (!user) {
        return [];
    }

    const permissions = [
        ...collectPermissionNames(user.permissions),
        ...collectPermissionNames(user.role),
        ...collectPermissionNames(user.roles),
    ];

    return Array.from(new Set(permissions));
};

export const canAccess = (
    user: Admin | null,
    requirement?: AccessRequirement,
    requiredFeatureFlags?: string[],
): boolean => {
    if (!user) {
        return false;
    }

    if (user.canAccessWeb === false) {
        return false;
    }

    if (user.isSuperAdmin) {
        return true;
    }

    if (requiredFeatureFlags && requiredFeatureFlags.length > 0) {
        const userFlags = collectFeatureFlags(user);
        const userRecord = user as unknown as UnknownRecord;
        const hasFeaturePayload = userFlags.length > 0 ||
            hasOwn(userRecord, 'featureFlags') ||
            hasOwn(userRecord, 'features');

        if (hasFeaturePayload) {
            const flagSet = new Set(userFlags);
            const hasRequiredFlag = requiredFeatureFlags.some((flag) => flagSet.has(flag));
            if (!hasRequiredFlag) {
                return false;
            }
        }
    }

    const anyOf = requirement?.anyOf?.map(normalize) ?? [];
    const allOf = requirement?.allOf?.map(normalize) ?? [];

    if (anyOf.length === 0 && allOf.length === 0) {
        return true;
    }

    if (!hasPermissionPayload(user)) {
        return false;
    }

    const permissionSet = new Set(extractUserPermissions(user));

    if (allOf.length > 0 && !allOf.every((permission) => permissionSet.has(permission))) {
        return false;
    }

    if (anyOf.length > 0 && !anyOf.some((permission) => permissionSet.has(permission))) {
        return false;
    }

    return true;
};

export const filterSidebarSectionsByAccess = (
    sections: SidebarSectionConfig[],
    user: Admin | null,
): SidebarSectionConfig[] => sections
    .map((section) => ({
        ...section,
        items: section.items.filter((item) => canAccess(user, item.access, item.featureFlags)),
    }))
    .filter((section) => section.items.length > 0);
