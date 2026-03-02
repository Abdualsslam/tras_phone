import { Search } from "lucide-react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";

interface CustomerOption {
  _id: string;
  phone?: string;
  contactName?: string;
  companyName?: string;
}

interface CustomerPickerCardProps {
  customerSearch: string;
  onSearchChange: (value: string) => void;
  customersLoading: boolean;
  customerOptions: CustomerOption[];
  selectedCustomerId: string;
  selectedCustomerName: string;
  onSelectCustomer: (customer: CustomerOption) => void;
  onClearSelection: () => void;
}

export function CustomerPickerCard({
  customerSearch,
  onSearchChange,
  customersLoading,
  customerOptions,
  selectedCustomerId,
  selectedCustomerName,
  onSelectCustomer,
  onClearSelection,
}: CustomerPickerCardProps) {
  return (
    <Card>
      <CardHeader>
        <CardTitle className="flex items-center gap-2">
          <Search className="h-5 w-5" />
          البحث عن عميل
        </CardTitle>
      </CardHeader>
      <CardContent>
        <div className="space-y-3">
          <Input
            placeholder="ابحث بالاسم أو رقم الجوال..."
            value={customerSearch}
            onChange={(e) => onSearchChange(e.target.value)}
          />

          <p className="text-xs text-muted-foreground">
            اختر العميل أولاً، ثم نفذ العمليات من نفس الصفحة لضمان تسجيل الحركة المالية.
          </p>

          {customerSearch.trim().length >= 2 && (
            <div className="rounded-md border p-2 max-h-52 overflow-auto">
              {customersLoading ? (
                <p className="text-sm text-muted-foreground px-2 py-1">جاري البحث...</p>
              ) : customerOptions.length === 0 ? (
                <p className="text-sm text-muted-foreground px-2 py-1">لا يوجد عملاء مطابقون</p>
              ) : (
                <div className="space-y-1">
                  {customerOptions.map((customer) => (
                    <button
                      key={customer._id}
                      type="button"
                      className="w-full text-end px-3 py-2 rounded-md hover:bg-muted transition-colors"
                      onClick={() => onSelectCustomer(customer)}
                    >
                      <div className="text-sm font-medium">
                        {customer.contactName || customer.companyName || "عميل"}
                      </div>
                      <div className="text-xs text-muted-foreground">
                        {customer.phone || "-"} • {customer._id}
                      </div>
                    </button>
                  ))}
                </div>
              )}
            </div>
          )}

          {selectedCustomerId && (
            <div className="flex items-center justify-between gap-3 rounded-md border px-3 py-2">
              <div className="text-xs text-muted-foreground">
                العميل المحدد: <span className="font-medium text-foreground">{selectedCustomerName || selectedCustomerId}</span>
              </div>
              <Button type="button" variant="outline" size="sm" onClick={onClearSelection}>
                إلغاء الاختيار
              </Button>
            </div>
          )}
        </div>
      </CardContent>
    </Card>
  );
}

export default CustomerPickerCard;
