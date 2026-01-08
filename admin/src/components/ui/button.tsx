import * as React from "react"
import { Slot } from "@radix-ui/react-slot"
import { cva, type VariantProps } from "class-variance-authority"
import { cn } from "@/lib/utils"

const buttonVariants = cva(
    "inline-flex items-center justify-center gap-2 whitespace-nowrap rounded-lg text-sm font-medium transition-all duration-200 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary-500 focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50 [&_svg]:pointer-events-none [&_svg]:size-4 [&_svg]:shrink-0 cursor-pointer",
    {
        variants: {
            variant: {
                default:
                    "bg-primary-600 text-white hover:bg-primary-700 active:bg-primary-800 shadow-sm",
                destructive:
                    "bg-red-600 text-white hover:bg-red-700 active:bg-red-800 shadow-sm",
                outline:
                    "border-2 border-gray-300 dark:border-slate-600 bg-white dark:bg-slate-800 hover:bg-gray-50 dark:hover:bg-slate-700 hover:border-gray-400 dark:hover:border-slate-500 text-gray-700 dark:text-gray-200",
                secondary:
                    "bg-gray-100 dark:bg-slate-800 text-gray-900 dark:text-gray-100 hover:bg-gray-200 dark:hover:bg-slate-700 active:bg-gray-300 dark:active:bg-slate-600",
                ghost: "hover:bg-gray-100 dark:hover:bg-slate-800 hover:text-gray-900 dark:hover:text-gray-100 text-gray-700 dark:text-gray-300",
                link: "text-primary-600 dark:text-primary-400 underline-offset-4 hover:underline",
            },
            size: {
                default: "h-10 px-4 py-2",
                sm: "h-8 rounded-md px-3 text-xs",
                lg: "h-12 rounded-lg px-6 text-base",
                icon: "h-10 w-10",
            },
        },
        defaultVariants: {
            variant: "default",
            size: "default",
        },
    }
)

export interface ButtonProps
    extends React.ButtonHTMLAttributes<HTMLButtonElement>,
    VariantProps<typeof buttonVariants> {
    asChild?: boolean
}

const Button = React.forwardRef<HTMLButtonElement, ButtonProps>(
    ({ className, variant, size, asChild = false, ...props }, ref) => {
        const Comp = asChild ? Slot : "button"
        return (
            <Comp
                className={cn(buttonVariants({ variant, size, className }))}
                ref={ref}
                {...props}
            />
        )
    }
)
Button.displayName = "Button"

export { Button, buttonVariants }
