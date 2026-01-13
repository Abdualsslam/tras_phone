import { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { rolesApi, type Role, type Permission, type CreateRoleDto } from '@/api/roles.api';
import { toast } from 'sonner';

import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Textarea } from '@/components/ui/textarea';
import { Badge } from '@/components/ui/badge';
import {
    Dialog,
    DialogContent,
    DialogHeader,
    DialogTitle,
    DialogFooter,
} from '@/components/ui/dialog';
import {
    Table,
    TableBody,
    TableCell,
    TableHead,
    TableHeader,
    TableRow,
} from '@/components/ui/table';
import {
    DropdownMenu,
    DropdownMenuContent,
    DropdownMenuItem,
    DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu';
import { Switch } from '@/components/ui/switch';
import {
    Plus,
    MoreHorizontal,
    Pencil,
    Trash2,
    Loader2,
    AlertCircle,
    Shield,
    Lock,
    Key,
    Check,
} from 'lucide-react';

// ══════════════════════════════════════════════════════════════
// Schema
// ══════════════════════════════════════════════════════════════

const roleSchema = z.object({
    name: z.string().min(2, 'اسم الدور مطلوب'),
    nameAr: z.string().optional(),
    description: z.string().optional(),
    isActive: z.boolean().optional(),
});

type RoleFormData = z.infer<typeof roleSchema>;

// ══════════════════════════════════════════════════════════════
// Component
// ══════════════════════════════════════════════════════════════

export function RolesPage() {
    const queryClient = useQueryClient();

    const [isCreateDialogOpen, setIsCreateDialogOpen] = useState(false);
    const [isEditDialogOpen, setIsEditDialogOpen] = useState(false);
    const [isDeleteDialogOpen, setIsDeleteDialogOpen] = useState(false);
    const [isPermissionsDialogOpen, setIsPermissionsDialogOpen] = useState(false);
    const [selectedRole, setSelectedRole] = useState<Role | null>(null);
    const [selectedPermissions, setSelectedPermissions] = useState<string[]>([]);

    // ─────────────────────────────────────────
    // Queries
    // ─────────────────────────────────────────

    const { data: roles = [], isLoading, error } = useQuery({
        queryKey: ['roles'],
        queryFn: () => rolesApi.getAll(),
    });

    const { data: allPermissions = [] } = useQuery({
        queryKey: ['permissions'],
        queryFn: () => rolesApi.getAllPermissions(),
    });

    // Group permissions by module
    const permissionsByModule = allPermissions.reduce((acc, perm) => {
        const module = perm.module || 'general';
        if (!acc[module]) acc[module] = [];
        acc[module].push(perm);
        return acc;
    }, {} as Record<string, Permission[]>);

    // ─────────────────────────────────────────
    // Mutations
    // ─────────────────────────────────────────

    const createMutation = useMutation({
        mutationFn: (data: CreateRoleDto) => rolesApi.create(data),
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['roles'] });
            setIsCreateDialogOpen(false);
            toast.success('تم إنشاء الدور بنجاح');
            createForm.reset();
        },
        onError: () => {
            toast.error('حدث خطأ أثناء إنشاء الدور');
        },
    });

    const updateMutation = useMutation({
        mutationFn: ({ id, data }: { id: string; data: Partial<CreateRoleDto> }) =>
            rolesApi.update(id, data),
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['roles'] });
            setIsEditDialogOpen(false);
            setSelectedRole(null);
            toast.success('تم تحديث الدور بنجاح');
        },
        onError: () => {
            toast.error('حدث خطأ أثناء تحديث الدور');
        },
    });

    const deleteMutation = useMutation({
        mutationFn: (id: string) => rolesApi.delete(id),
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['roles'] });
            setIsDeleteDialogOpen(false);
            setSelectedRole(null);
            toast.success('تم حذف الدور بنجاح');
        },
        onError: () => {
            toast.error('حدث خطأ أثناء حذف الدور');
        },
    });

    const setPermissionsMutation = useMutation({
        mutationFn: ({ roleId, permissions }: { roleId: string; permissions: string[] }) =>
            rolesApi.setPermissions(roleId, permissions),
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['roles'] });
            setIsPermissionsDialogOpen(false);
            setSelectedRole(null);
            toast.success('تم تحديث الصلاحيات بنجاح');
        },
        onError: () => {
            toast.error('حدث خطأ أثناء تحديث الصلاحيات');
        },
    });

    // ─────────────────────────────────────────
    // Forms
    // ─────────────────────────────────────────

    const createForm = useForm<RoleFormData>({
        resolver: zodResolver(roleSchema),
        defaultValues: {
            isActive: true,
        },
    });

    const editForm = useForm<RoleFormData>({
        resolver: zodResolver(roleSchema),
    });

    // ─────────────────────────────────────────
    // Handlers
    // ─────────────────────────────────────────

    const handleEdit = (role: Role) => {
        setSelectedRole(role);
        editForm.reset({
            name: role.name,
            nameAr: role.nameAr || '',
            description: role.description || '',
            isActive: role.isActive,
        });
        setIsEditDialogOpen(true);
    };

    const handleDelete = (role: Role) => {
        setSelectedRole(role);
        setIsDeleteDialogOpen(true);
    };

    const handlePermissions = (role: Role) => {
        setSelectedRole(role);
        // Extract permission IDs (handle undefined permissions)
        const permIds = (role.permissions || []).map(p =>
            typeof p === 'string' ? p : p._id
        );
        setSelectedPermissions(permIds);
        setIsPermissionsDialogOpen(true);
    };

    const togglePermission = (permissionId: string) => {
        setSelectedPermissions(prev =>
            prev.includes(permissionId)
                ? prev.filter(id => id !== permissionId)
                : [...prev, permissionId]
        );
    };

    const toggleModulePermissions = (module: string) => {
        const modulePerms = permissionsByModule[module] || [];
        const modulePermIds = modulePerms.map(p => p._id);
        const allSelected = modulePermIds.every(id => selectedPermissions.includes(id));

        if (allSelected) {
            setSelectedPermissions(prev => prev.filter(id => !modulePermIds.includes(id)));
        } else {
            setSelectedPermissions(prev => [...new Set([...prev, ...modulePermIds])]);
        }
    };

    const onCreateSubmit = (data: RoleFormData) => {
        createMutation.mutate({
            name: data.name,
            nameAr: data.nameAr || undefined,
            description: data.description || undefined,
            isActive: data.isActive,
        });
    };

    const onEditSubmit = (data: RoleFormData) => {
        if (selectedRole) {
            updateMutation.mutate({
                id: selectedRole._id,
                data: {
                    name: data.name,
                    nameAr: data.nameAr || undefined,
                    description: data.description || undefined,
                    isActive: data.isActive,
                },
            });
        }
    };

    const onDeleteConfirm = () => {
        if (selectedRole) {
            deleteMutation.mutate(selectedRole._id);
        }
    };

    const onPermissionsSave = () => {
        if (selectedRole) {
            setPermissionsMutation.mutate({
                roleId: selectedRole._id,
                permissions: selectedPermissions,
            });
        }
    };

    // ─────────────────────────────────────────
    // Module labels
    // ─────────────────────────────────────────

    const moduleLabels: Record<string, string> = {
        admins: 'المشرفين',
        customers: 'العملاء',
        products: 'المنتجات',
        orders: 'الطلبات',
        inventory: 'المخزون',
        suppliers: 'الموردين',
        returns: 'المرتجعات',
        promotions: 'العروض',
        analytics: 'التحليلات',
        settings: 'الإعدادات',
        support: 'الدعم',
        content: 'المحتوى',
        general: 'عام',
    };

    // ─────────────────────────────────────────
    // Render
    // ─────────────────────────────────────────

    if (error) {
        return (
            <div className="flex flex-col items-center justify-center h-[400px] text-muted-foreground">
                <AlertCircle className="h-12 w-12 mb-4 text-destructive" />
                <p>حدث خطأ أثناء تحميل الأدوار</p>
            </div>
        );
    }

    return (
        <div className="space-y-6">
            {/* Header */}
            <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
                <div>
                    <h1 className="text-2xl font-bold">إدارة الأدوار والصلاحيات</h1>
                    <p className="text-muted-foreground text-sm">تحديد صلاحيات الوصول للمشرفين</p>
                </div>
                <Button onClick={() => setIsCreateDialogOpen(true)}>
                    <Plus className="h-4 w-4 ml-2" />
                    إضافة دور جديد
                </Button>
            </div>

            {/* Stats */}
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                <Card>
                    <CardContent className="pt-6">
                        <div className="flex items-center gap-3">
                            <div className="p-2 bg-blue-100 dark:bg-blue-900/30 rounded-lg">
                                <Shield className="h-5 w-5 text-blue-600 dark:text-blue-400" />
                            </div>
                            <div>
                                <p className="text-sm text-muted-foreground">إجمالي الأدوار</p>
                                <p className="text-2xl font-bold">{roles.length}</p>
                            </div>
                        </div>
                    </CardContent>
                </Card>
                <Card>
                    <CardContent className="pt-6">
                        <div className="flex items-center gap-3">
                            <div className="p-2 bg-green-100 dark:bg-green-900/30 rounded-lg">
                                <Key className="h-5 w-5 text-green-600 dark:text-green-400" />
                            </div>
                            <div>
                                <p className="text-sm text-muted-foreground">إجمالي الصلاحيات</p>
                                <p className="text-2xl font-bold">{allPermissions.length}</p>
                            </div>
                        </div>
                    </CardContent>
                </Card>
                <Card>
                    <CardContent className="pt-6">
                        <div className="flex items-center gap-3">
                            <div className="p-2 bg-purple-100 dark:bg-purple-900/30 rounded-lg">
                                <Lock className="h-5 w-5 text-purple-600 dark:text-purple-400" />
                            </div>
                            <div>
                                <p className="text-sm text-muted-foreground">أدوار النظام</p>
                                <p className="text-2xl font-bold">{roles.filter(r => r.isSystem).length}</p>
                            </div>
                        </div>
                    </CardContent>
                </Card>
            </div>

            {/* Roles Table */}
            <Card>
                <CardHeader>
                    <CardTitle className="flex items-center gap-2">
                        <Shield className="h-5 w-5" />
                        قائمة الأدوار
                    </CardTitle>
                </CardHeader>
                <CardContent>
                    {isLoading ? (
                        <div className="flex justify-center items-center h-40">
                            <Loader2 className="h-8 w-8 animate-spin text-primary" />
                        </div>
                    ) : roles.length === 0 ? (
                        <div className="text-center py-12 text-muted-foreground">
                            <Shield className="h-12 w-12 mx-auto mb-4 opacity-50" />
                            <p>لا يوجد أدوار</p>
                        </div>
                    ) : (
                        <div className="overflow-x-auto">
                            <Table>
                                <TableHeader>
                                    <TableRow>
                                        <TableHead>الدور</TableHead>
                                        <TableHead>الوصف</TableHead>
                                        <TableHead>الصلاحيات</TableHead>
                                        <TableHead>الحالة</TableHead>
                                        <TableHead className="w-[50px]"></TableHead>
                                    </TableRow>
                                </TableHeader>
                                <TableBody>
                                    {roles.map((role) => (
                                        <TableRow key={role._id}>
                                            <TableCell>
                                                <div className="flex items-center gap-2">
                                                    {role.isSystem && (
                                                        <Lock className="h-4 w-4 text-muted-foreground" />
                                                    )}
                                                    <div>
                                                        <p className="font-medium">{role.name}</p>
                                                        {role.nameAr && (
                                                            <p className="text-sm text-muted-foreground">{role.nameAr}</p>
                                                        )}
                                                    </div>
                                                </div>
                                            </TableCell>
                                            <TableCell>
                                                <p className="text-sm text-muted-foreground line-clamp-2">
                                                    {role.description || '-'}
                                                </p>
                                            </TableCell>
                                            <TableCell>
                                                <Badge variant="outline">
                                                    {(role.permissions || []).length} صلاحية
                                                </Badge>
                                            </TableCell>
                                            <TableCell>
                                                <Badge variant={role.isActive ? 'success' : 'secondary'}>
                                                    {role.isActive ? 'نشط' : 'غير نشط'}
                                                </Badge>
                                            </TableCell>
                                            <TableCell>
                                                <DropdownMenu>
                                                    <DropdownMenuTrigger asChild>
                                                        <Button variant="ghost" size="icon">
                                                            <MoreHorizontal className="h-4 w-4" />
                                                        </Button>
                                                    </DropdownMenuTrigger>
                                                    <DropdownMenuContent align="end">
                                                        <DropdownMenuItem onClick={() => handlePermissions(role)}>
                                                            <Key className="h-4 w-4 ml-2" />
                                                            إدارة الصلاحيات
                                                        </DropdownMenuItem>
                                                        {!role.isSystem && (
                                                            <>
                                                                <DropdownMenuItem onClick={() => handleEdit(role)}>
                                                                    <Pencil className="h-4 w-4 ml-2" />
                                                                    تعديل
                                                                </DropdownMenuItem>
                                                                <DropdownMenuItem
                                                                    onClick={() => handleDelete(role)}
                                                                    className="text-red-600"
                                                                >
                                                                    <Trash2 className="h-4 w-4 ml-2" />
                                                                    حذف
                                                                </DropdownMenuItem>
                                                            </>
                                                        )}
                                                    </DropdownMenuContent>
                                                </DropdownMenu>
                                            </TableCell>
                                        </TableRow>
                                    ))}
                                </TableBody>
                            </Table>
                        </div>
                    )}
                </CardContent>
            </Card>

            {/* Create Dialog */}
            <Dialog open={isCreateDialogOpen} onOpenChange={setIsCreateDialogOpen}>
                <DialogContent>
                    <DialogHeader>
                        <DialogTitle>إنشاء دور جديد</DialogTitle>
                    </DialogHeader>
                    <form onSubmit={createForm.handleSubmit(onCreateSubmit)} className="space-y-4">
                        <div className="space-y-2">
                            <Label>اسم الدور *</Label>
                            <Input {...createForm.register('name')} placeholder="مثال: مدير المبيعات" />
                            {createForm.formState.errors.name && (
                                <p className="text-sm text-red-500">{createForm.formState.errors.name.message}</p>
                            )}
                        </div>
                        <div className="space-y-2">
                            <Label>الاسم بالعربية</Label>
                            <Input {...createForm.register('nameAr')} placeholder="اسم الدور بالعربية" />
                        </div>
                        <div className="space-y-2">
                            <Label>الوصف</Label>
                            <Textarea {...createForm.register('description')} placeholder="وصف الدور وصلاحياته..." />
                        </div>
                        <div className="flex items-center gap-2">
                            <Switch
                                id="createIsActive"
                                checked={createForm.watch('isActive')}
                                onCheckedChange={(checked: boolean) => createForm.setValue('isActive', checked)}
                            />
                            <Label htmlFor="createIsActive">دور نشط</Label>
                        </div>

                        <DialogFooter>
                            <Button type="button" variant="outline" onClick={() => setIsCreateDialogOpen(false)}>
                                إلغاء
                            </Button>
                            <Button type="submit" disabled={createMutation.isPending}>
                                {createMutation.isPending && <Loader2 className="h-4 w-4 ml-2 animate-spin" />}
                                إنشاء
                            </Button>
                        </DialogFooter>
                    </form>
                </DialogContent>
            </Dialog>

            {/* Edit Dialog */}
            <Dialog open={isEditDialogOpen} onOpenChange={setIsEditDialogOpen}>
                <DialogContent>
                    <DialogHeader>
                        <DialogTitle>تعديل الدور</DialogTitle>
                    </DialogHeader>
                    <form onSubmit={editForm.handleSubmit(onEditSubmit)} className="space-y-4">
                        <div className="space-y-2">
                            <Label>اسم الدور *</Label>
                            <Input {...editForm.register('name')} placeholder="اسم الدور" />
                        </div>
                        <div className="space-y-2">
                            <Label>الاسم بالعربية</Label>
                            <Input {...editForm.register('nameAr')} placeholder="اسم الدور بالعربية" />
                        </div>
                        <div className="space-y-2">
                            <Label>الوصف</Label>
                            <Textarea {...editForm.register('description')} placeholder="وصف الدور..." />
                        </div>
                        <div className="flex items-center gap-2">
                            <Switch
                                id="editIsActive"
                                checked={editForm.watch('isActive')}
                                onCheckedChange={(checked: boolean) => editForm.setValue('isActive', checked)}
                            />
                            <Label htmlFor="editIsActive">دور نشط</Label>
                        </div>

                        <DialogFooter>
                            <Button type="button" variant="outline" onClick={() => setIsEditDialogOpen(false)}>
                                إلغاء
                            </Button>
                            <Button type="submit" disabled={updateMutation.isPending}>
                                {updateMutation.isPending && <Loader2 className="h-4 w-4 ml-2 animate-spin" />}
                                حفظ التغييرات
                            </Button>
                        </DialogFooter>
                    </form>
                </DialogContent>
            </Dialog>

            {/* Delete Confirmation Dialog */}
            <Dialog open={isDeleteDialogOpen} onOpenChange={setIsDeleteDialogOpen}>
                <DialogContent>
                    <DialogHeader>
                        <DialogTitle>تأكيد الحذف</DialogTitle>
                    </DialogHeader>
                    <p className="text-muted-foreground">
                        هل أنت متأكد من حذف الدور "{selectedRole?.name}"؟ هذا الإجراء لا يمكن التراجع عنه.
                    </p>
                    <DialogFooter>
                        <Button variant="outline" onClick={() => setIsDeleteDialogOpen(false)}>
                            إلغاء
                        </Button>
                        <Button variant="destructive" onClick={onDeleteConfirm} disabled={deleteMutation.isPending}>
                            {deleteMutation.isPending && <Loader2 className="h-4 w-4 ml-2 animate-spin" />}
                            حذف
                        </Button>
                    </DialogFooter>
                </DialogContent>
            </Dialog>

            {/* Permissions Dialog */}
            <Dialog open={isPermissionsDialogOpen} onOpenChange={setIsPermissionsDialogOpen}>
                <DialogContent className="max-w-3xl max-h-[90vh] overflow-y-auto">
                    <DialogHeader>
                        <DialogTitle>إدارة صلاحيات: {selectedRole?.name}</DialogTitle>
                    </DialogHeader>
                    <div className="space-y-6">
                        {Object.entries(permissionsByModule).map(([module, permissions]) => (
                            <Card key={module}>
                                <CardHeader className="py-3">
                                    <div className="flex items-center justify-between">
                                        <CardTitle className="text-base">
                                            {moduleLabels[module] || module}
                                        </CardTitle>
                                        <Button
                                            variant="ghost"
                                            size="sm"
                                            onClick={() => toggleModulePermissions(module)}
                                        >
                                            {permissions.every(p => selectedPermissions.includes(p._id))
                                                ? 'إلغاء الكل'
                                                : 'تحديد الكل'
                                            }
                                        </Button>
                                    </div>
                                </CardHeader>
                                <CardContent className="py-0 pb-4">
                                    <div className="grid grid-cols-1 md:grid-cols-2 gap-2">
                                        {permissions.map((perm) => (
                                            <div
                                                key={perm._id}
                                                onClick={() => togglePermission(perm._id)}
                                                className={`
                                                    flex items-center gap-3 p-3 rounded-lg border cursor-pointer transition-colors
                                                    ${selectedPermissions.includes(perm._id)
                                                        ? 'bg-primary/10 border-primary'
                                                        : 'hover:bg-muted'
                                                    }
                                                `}
                                            >
                                                <div className={`
                                                    w-5 h-5 rounded border-2 flex items-center justify-center
                                                    ${selectedPermissions.includes(perm._id)
                                                        ? 'bg-primary border-primary'
                                                        : 'border-gray-300'
                                                    }
                                                `}>
                                                    {selectedPermissions.includes(perm._id) && (
                                                        <Check className="h-3 w-3 text-white" />
                                                    )}
                                                </div>
                                                <div>
                                                    <p className="font-medium text-sm">{perm.name}</p>
                                                    <p className="text-xs text-muted-foreground">{perm.description}</p>
                                                </div>
                                            </div>
                                        ))}
                                    </div>
                                </CardContent>
                            </Card>
                        ))}
                    </div>
                    <DialogFooter>
                        <Button variant="outline" onClick={() => setIsPermissionsDialogOpen(false)}>
                            إلغاء
                        </Button>
                        <Button onClick={onPermissionsSave} disabled={setPermissionsMutation.isPending}>
                            {setPermissionsMutation.isPending && <Loader2 className="h-4 w-4 ml-2 animate-spin" />}
                            حفظ الصلاحيات
                        </Button>
                    </DialogFooter>
                </DialogContent>
            </Dialog>
        </div>
    );
}

export default RolesPage;
