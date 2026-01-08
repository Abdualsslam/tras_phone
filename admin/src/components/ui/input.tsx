import * as React from "react"
import { cn } from "@/lib/utils"

export interface InputProps extends React.InputHTMLAttributes<HTMLInputElement> {
    error?: boolean
}

const Input = React.forwardRef<HTMLInputElement, InputProps>(
    ({ className, type, error, ...props }, ref) => {
        return (
            <input
                type={type}
                className={cn(
                    "flex h-10 w-full rounded-lg border border-gray-300 dark:border-slate-600 bg-white dark:bg-slate-800 px-3 py-2 text-sm text-gray-900 dark:text-gray-100 transition-colors file:border-0 file:bg-transparent file:text-sm file:font-medium file:text-gray-900 dark:file:text-gray-100 placeholder:text-gray-400 dark:placeholder:text-gray-500 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary-500 focus-visible:border-primary-500 disabled:cursor-not-allowed disabled:opacity-50",
                    error && "border-red-500 focus-visible:ring-red-500 focus-visible:border-red-500",
                    className
                )}
                ref={ref}
                {...props}
            />
        )
    }
)
Input.displayName = "Input"

export { Input }
