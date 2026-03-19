import { Produto } from '@/types';
import { create } from 'zustand';
import { persist } from 'zustand/middleware';

export interface CartItem {
    id: string; // Unique ID for the cart item (timestamp based)
    produto: Produto;
    quantidade: number;
    selections?: { [componentId: string]: number }; // For composite products
    totalPrice: number; // Unit price with extras
}

interface CartState {
    items: CartItem[];
    addItem: (item: Omit<CartItem, 'id'>) => void;
    removeItem: (id: string) => void;
    updateQuantity: (id: string, delta: number) => void;
    clearCart: () => void;
    totalCartPrice: () => number;
}

export const useCartStore = create<CartState>()(
    persist(
        (set, get) => ({
            items: [],
            addItem: (newItem) => {
                set((state) => {
                    // Check if identical item exists (same product and same selections)
                    const existingItemIndex = state.items.findIndex(
                        (item) =>
                            item.produto._id === newItem.produto._id &&
                            JSON.stringify(item.selections) === JSON.stringify(newItem.selections)
                    );

                    if (existingItemIndex > -1) {
                        const newItems = [...state.items];
                        newItems[existingItemIndex].quantidade += newItem.quantidade;
                        return { items: newItems };
                    }

                    return {
                        items: [...state.items, { ...newItem, id: Date.now().toString() }],
                    };
                });
            },
            removeItem: (id) =>
                set((state) => ({
                    items: state.items.filter((item) => item.id !== id),
                })),
            updateQuantity: (id, delta) =>
                set((state) => ({
                    items: state.items
                        .map((item) => {
                            if (item.id === id) {
                                const newQty = item.quantidade + delta;
                                return newQty > 0 ? { ...item, quantidade: newQty } : item;
                            }
                            return item;
                        })
                    // Optional: Remove if qty becomes 0? Usually better to have explicit remove button.
                    // Keeping min 1 for now.
                })),
            clearCart: () => set({ items: [] }),
            totalCartPrice: () => {
                const { items } = get();
                return items.reduce((total, item) => total + item.totalPrice * item.quantidade, 0);
            },
        }),
        {
            name: 'cart-storage',
        }
    )
);
