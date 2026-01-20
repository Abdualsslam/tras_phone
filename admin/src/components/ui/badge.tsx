import { cva, type VariantProps } from "class-variance-authority"
import { cn } from "@/lib/utils"

const badgeVariants = cva(
    "inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium transition-colors",
    {
        variants: {
            variant: {
                default: "bg-primary-100 dark:bg-primary-900/30 text-primary-700 dark:text-primary-400",
                secondary: "bg-gray-100 dark:bg-slate-800 text-gray-700 dark:text-gray-300",
                success: "bg-green-100 dark:bg-green-900/30 text-green-700 dark:text-green-400",
                warning: "bg-yellow-100 dark:bg-yellow-900/30 text-yellow-700 dark:text-yellow-400",
                danger: "bg-red-100 dark:bg-red-900/30 text-red-700 dark:text-red-400",
                destructive: "bg-red-100 dark:bg-red-900/30 text-red-700 dark:text-red-400",
                outline: "border border-gray-300 dark:border-slate-600 text-gray-700 dark:text-gray-300",
            },
        },
        defaultVariants: {
            variant: "default",
        },
    }
)

export interface BadgeProps
    extends React.HTMLAttributes<HTMLDivElement>,
    VariantProps<typeof badgeVariants> { }

function Badge({ className, variant, ...props }: BadgeProps) {
    return (
        <div className={cn(badgeVariants({ variant }), className)} {...props} />
    )
}

export { Badge, badgeVariants }
