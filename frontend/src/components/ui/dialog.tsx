"use client"

import * as React from "react"
import { X } from "lucide-react"

interface DialogRootProps {
  open: boolean
  onOpenChange: (open: boolean) => void
  children: React.ReactNode
}

export function Dialog({ open, onOpenChange, children }: DialogRootProps) {
  if (!open) return null

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm p-4 animate-in fade-in duration-150">
      <div className="relative w-full max-w-lg rounded-lg bg-background shadow-lg ring-1 ring-black/10 animate-in zoom-in-95 duration-150 max-h-[90vh] flex flex-col overflow-hidden">
        {children}
        {/* Botão global de fechar (fallback) */}
        <button
          onClick={() => onOpenChange(false)}
          className="absolute right-3 top-3 p-2 rounded-md hover:bg-accent transition"
        >
          <X className="h-4 w-4" />
        </button>
      </div>
    </div>
  )
}

/* -------------------------------------------------------
   Conteúdo interno
-------------------------------------------------------- */

export function DialogContent({ children }: { children: React.ReactNode }) {
  return <div className="p-4 overflow-y-auto flex-1">{children}</div>
}

export function DialogHeader({ children }: { children: React.ReactNode }) {
  return (
    <div className="border-b p-4 pb-3 flex flex-col gap-1">
      {children}
    </div>
  )
}

export function DialogTitle({ children }: { children: React.ReactNode }) {
  return <h2 className="text-lg font-semibold leading-none">{children}</h2>
}

export function DialogDescription({ children }: { children: React.ReactNode }) {
  return <p className="text-sm text-muted-foreground">{children}</p>
}

export function DialogFooter({ children }: { children: React.ReactNode }) {
  return (
    <div className="border-t p-4 pt-3 flex justify-end gap-2 bg-background/50">
      {children}
    </div>
  )
}

/* opcional: compatível com <DialogTrigger> */
export function DialogTrigger({ children, onClick }: { children: React.ReactNode, onClick?: () => void }) {
  return (
    <div onClick={onClick} className="inline-block">
      {children}
    </div>
  )
}

