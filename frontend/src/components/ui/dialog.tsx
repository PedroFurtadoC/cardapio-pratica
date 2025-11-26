import { X } from "lucide-react"
import * as React from "react"
import { Button } from "./button"

interface DialogProps {
    open: boolean
    onOpenChange: (open: boolean) => void
    children: React.ReactNode
    title?: string
    description?: string
}

export function Dialog({ open, onOpenChange, children, title, description }: DialogProps) {
    if (!open) return null

    return (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm p-4 animate-in fade-in duration-200">
            <div className="relative w-full max-w-lg overflow-hidden rounded-lg bg-background shadow-lg ring-1 ring-gray-900/5 animate-in zoom-in-95 duration-200 flex flex-col max-h-[90vh]">
                <div className="flex items-center justify-between border-b p-4">
                    <div>
                        {title && <h2 className="text-lg font-semibold">{title}</h2>}
                        {description && <p className="text-sm text-muted-foreground">{description}</p>}
                    </div>
                    <Button
                        variant="ghost"
                        size="icon"
                        className="h-8 w-8"
                        onClick={() => onOpenChange(false)}
                    >
                        <X className="h-4 w-4" />
                        <span className="sr-only">Fechar</span>
                    </Button>
                </div>
                <div className="flex-1 overflow-y-auto p-4">
                    {children}
                </div>
            </div>
        </div>
    )
}
