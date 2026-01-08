import { type ClassValue, clsx } from "clsx"
import { twMerge } from "tailwind-merge"

export function cn(...inputs: ClassValue[]) {
    return twMerge(clsx(inputs))
}

export function formatDate(date: string | Date, _locale: string = 'ar-SA') {
    // Always use Gregorian calendar with English numerals
    return new Intl.DateTimeFormat('en-US', {
        year: 'numeric',
        month: 'long',
        day: 'numeric',
        calendar: 'gregory',
    }).format(new Date(date))
}

export function formatCurrency(amount: number, currency: string = 'SAR', _locale: string = 'ar-SA') {
    // Always use English numerals for currency
    return new Intl.NumberFormat('en-US', {
        style: 'currency',
        currency,
        minimumFractionDigits: 2,
        maximumFractionDigits: 2,
    }).format(amount)
}

export function formatNumber(num: number, _locale: string = 'ar-SA') {
    // Always use English numerals
    return new Intl.NumberFormat('en-US').format(num)
}

export function getInitials(name: string): string {
    return name
        .split(' ')
        .map(word => word[0])
        .join('')
        .toUpperCase()
        .slice(0, 2)
}

export function debounce<T extends (...args: unknown[]) => unknown>(
    func: T,
    wait: number
): (...args: Parameters<T>) => void {
    let timeout: ReturnType<typeof setTimeout>
    return (...args: Parameters<T>) => {
        clearTimeout(timeout)
        timeout = setTimeout(() => func(...args), wait)
    }
}
