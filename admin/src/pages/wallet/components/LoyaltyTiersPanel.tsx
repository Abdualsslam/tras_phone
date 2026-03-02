import { Crown, Loader2, Pencil, Plus, Trash2 } from "lucide-react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import type { LoyaltyTier } from "@/api/wallet.api";

interface LoyaltyTiersPanelProps {
  tiers: LoyaltyTier[];
  loading: boolean;
  canManageTiers: boolean;
  onCreateTier: () => void;
  onEditTier: (tier: LoyaltyTier) => void;
  onDeleteTier: (tier: LoyaltyTier) => void;
}

export function LoyaltyTiersPanel({
  tiers,
  loading,
  canManageTiers,
  onCreateTier,
  onEditTier,
  onDeleteTier,
}: LoyaltyTiersPanelProps) {
  return (
    <Card>
      <CardHeader>
        <div className="flex items-center justify-between gap-3">
          <CardTitle className="flex items-center gap-2">
            <Crown className="h-5 w-5" />
            إدارة مستويات الولاء
          </CardTitle>
          {canManageTiers && (
            <Button onClick={onCreateTier} className="bg-green-600 hover:bg-green-700">
              <Plus className="h-4 w-4 ms-2" />
              إضافة مستوى جديد
            </Button>
          )}
        </div>
      </CardHeader>
      <CardContent>
        {loading ? (
          <div className="flex justify-center items-center h-40">
            <Loader2 className="h-8 w-8 animate-spin text-primary" />
          </div>
        ) : tiers.length === 0 ? (
          <div className="text-center py-12 text-muted-foreground">
            <Crown className="h-12 w-12 mx-auto mb-4 opacity-50" />
            <p>لا توجد مستويات</p>
          </div>
        ) : (
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>الاسم</TableHead>
                <TableHead>الكود</TableHead>
                <TableHead>الحد الأدنى</TableHead>
                <TableHead>المضاعف</TableHead>
                <TableHead>الخصم</TableHead>
                <TableHead>المزايا</TableHead>
                <TableHead>الحالة</TableHead>
                <TableHead>الإجراءات</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {tiers.map((tier) => (
                <TableRow key={tier._id}>
                  <TableCell>
                    <div>
                      <p className="font-medium">{tier.name}</p>
                      <p className="text-sm text-muted-foreground">{tier.nameAr}</p>
                    </div>
                  </TableCell>
                  <TableCell>
                    <Badge variant="outline">{tier.code}</Badge>
                  </TableCell>
                  <TableCell>{tier.minPoints.toLocaleString()} نقطة</TableCell>
                  <TableCell>x{tier.pointsMultiplier}</TableCell>
                  <TableCell>{tier.discountPercentage}%</TableCell>
                  <TableCell>
                    <div className="flex flex-wrap gap-1">
                      {tier.freeShipping && (
                        <Badge variant="success" className="text-xs">
                          شحن مجاني
                        </Badge>
                      )}
                      {tier.prioritySupport && (
                        <Badge variant="success" className="text-xs">
                          دعم أولوية
                        </Badge>
                      )}
                      {tier.earlyAccess && (
                        <Badge variant="success" className="text-xs">
                          وصول مبكر
                        </Badge>
                      )}
                    </div>
                  </TableCell>
                  <TableCell>
                    <Badge variant={tier.isActive ? "success" : "danger"}>
                      {tier.isActive ? "نشط" : "غير نشط"}
                    </Badge>
                  </TableCell>
                  <TableCell>
                    {canManageTiers && (
                      <div className="flex gap-2">
                        <Button variant="outline" size="sm" onClick={() => onEditTier(tier)}>
                          <Pencil className="h-4 w-4" />
                        </Button>
                        <Button variant="destructive" size="sm" onClick={() => onDeleteTier(tier)}>
                          <Trash2 className="h-4 w-4" />
                        </Button>
                      </div>
                    )}
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        )}
      </CardContent>
    </Card>
  );
}

export default LoyaltyTiersPanel;
