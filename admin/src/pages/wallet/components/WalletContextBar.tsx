import { Wallet, Coins, Star, UserCircle2 } from "lucide-react";
import { Card, CardContent } from "@/components/ui/card";
import { formatCurrency } from "@/lib/utils";

interface WalletContextBarProps {
  selectedCustomerId: string;
  selectedCustomerName: string;
  balanceLoading: boolean;
  balance?: number;
  points?: number;
  tier?: string;
}

export function WalletContextBar({
  selectedCustomerId,
  selectedCustomerName,
  balanceLoading,
  balance,
  points,
  tier,
}: WalletContextBarProps) {
  if (!selectedCustomerId) {
    return null;
  }

  return (
    <Card className="sticky top-4 z-10 border-primary/20 bg-gradient-to-r from-primary/5 via-background to-emerald-500/5 backdrop-blur-sm">
      <CardContent className="pt-4">
        <div className="grid grid-cols-1 gap-4 md:grid-cols-4">
          <div className="flex items-center gap-2">
            <UserCircle2 className="h-5 w-5 text-primary" />
            <div>
              <p className="text-xs text-muted-foreground">العميل الحالي</p>
              <p className="font-medium text-sm">{selectedCustomerName || selectedCustomerId}</p>
            </div>
          </div>

          <div className="flex items-center gap-2">
            <Wallet className="h-5 w-5 text-blue-600" />
            <div>
              <p className="text-xs text-muted-foreground">الرصيد الحالي</p>
              <p className="font-semibold">{balanceLoading ? "..." : formatCurrency(balance || 0)}</p>
            </div>
          </div>

          <div className="flex items-center gap-2">
            <Coins className="h-5 w-5 text-yellow-600" />
            <div>
              <p className="text-xs text-muted-foreground">نقاط الولاء</p>
              <p className="font-semibold">{balanceLoading ? "..." : (points || 0).toLocaleString()}</p>
            </div>
          </div>

          <div className="flex items-center gap-2">
            <Star className="h-5 w-5 text-violet-600" />
            <div>
              <p className="text-xs text-muted-foreground">المستوى</p>
              <p className="font-semibold">{balanceLoading ? "..." : tier || "Bronze"}</p>
            </div>
          </div>
        </div>
      </CardContent>
    </Card>
  );
}

export default WalletContextBar;
