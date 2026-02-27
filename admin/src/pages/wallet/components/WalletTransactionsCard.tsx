import { Loader2, Wallet } from "lucide-react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { formatCurrency, formatDate } from "@/lib/utils";
import type { WalletTransaction } from "@/api/wallet.api";

interface WalletTransactionsCardProps {
  title: string;
  canViewTransactions: boolean;
  transactions: WalletTransaction[];
  loading: boolean;
  errorMessage?: string;
  showCustomer?: boolean;
}

export function WalletTransactionsCard({
  title,
  canViewTransactions,
  transactions,
  loading,
  errorMessage,
  showCustomer = false,
}: WalletTransactionsCardProps) {
  return (
    <Card>
      <CardHeader>
        <CardTitle>{title}</CardTitle>
      </CardHeader>
      <CardContent>
        {!canViewTransactions ? (
          <div className="text-sm text-muted-foreground">ليس لديك صلاحية عرض سجل المعاملات.</div>
        ) : errorMessage ? (
          <div className="text-sm text-red-700 dark:text-red-300">{errorMessage}</div>
        ) : loading ? (
          <div className="flex justify-center items-center h-32">
            <Loader2 className="h-8 w-8 animate-spin text-primary" />
          </div>
        ) : transactions.length === 0 ? (
          <div className="text-center py-10 text-muted-foreground">
            <Wallet className="h-10 w-10 mx-auto mb-3 opacity-50" />
            <p>لا توجد معاملات</p>
          </div>
        ) : (
          <Table>
            <TableHeader>
              <TableRow>
                {showCustomer && <TableHead>العميل</TableHead>}
                <TableHead>النوع</TableHead>
                <TableHead>تصنيف العملية</TableHead>
                <TableHead>المبلغ</TableHead>
                <TableHead>قبل</TableHead>
                <TableHead>بعد</TableHead>
                <TableHead>المرجع</TableHead>
                <TableHead>التاريخ</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {transactions.map((tx) => (
                <TableRow key={tx._id}>
                  {showCustomer && <TableCell>{tx.customerName || tx.customerId || "-"}</TableCell>}
                  <TableCell>
                    <Badge variant={tx.type === "credit" ? "success" : "danger"}>
                      {tx.type === "credit" ? "إضافة" : "خصم"}
                    </Badge>
                  </TableCell>
                  <TableCell className="font-mono text-xs">{tx.transactionType || "-"}</TableCell>
                  <TableCell className={tx.type === "credit" ? "text-green-600 font-medium" : "text-red-600 font-medium"}>
                    {tx.type === "credit" ? "+" : "-"}
                    {formatCurrency(tx.amount)}
                  </TableCell>
                  <TableCell className="text-muted-foreground">{formatCurrency(tx.balanceBefore)}</TableCell>
                  <TableCell className="font-medium">{formatCurrency(tx.balanceAfter)}</TableCell>
                  <TableCell className="font-mono text-xs">{tx.referenceNumber || tx.reference || "-"}</TableCell>
                  <TableCell className="text-muted-foreground text-sm">{formatDate(tx.createdAt)}</TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        )}
      </CardContent>
    </Card>
  );
}

export default WalletTransactionsCard;
