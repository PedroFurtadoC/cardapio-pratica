import { Button } from "@/components/ui/button";
import { formatPrice } from "@/lib/utils";
import { useCartStore } from "@/store/cartStore";
import { ShoppingCart } from "lucide-react";
import { useLocation, useNavigate } from "react-router-dom";

export function CartFAB() {
    const { items, totalCartPrice } = useCartStore();
    const navigate = useNavigate();
    const location = useLocation();

    // Don't show on checkout or admin pages
    if (location.pathname === "/checkout" || location.pathname.startsWith("/admin")) {
        return null;
    }

    if (items.length === 0) return null;

    const total = totalCartPrice();
    const itemCount = items.reduce((acc, item) => acc + item.quantidade, 0);

    return (
        <div className="fixed bottom-4 right-4 z-50 md:hidden">
            <Button
                onClick={() => navigate("/checkout")}
                className="h-14 rounded-full px-6 shadow-lg animate-in slide-in-from-bottom-4"
            >
                <div className="flex items-center gap-3">
                    <div className="relative">
                        <ShoppingCart className="h-6 w-6" />
                        <span className="absolute -right-2 -top-2 flex h-5 w-5 items-center justify-center rounded-full bg-white text-xs font-bold text-primary">
                            {itemCount}
                        </span>
                    </div>
                    <div className="flex flex-col items-start text-sm">
                        <span className="font-semibold">Ver Carrinho</span>
                        <span className="font-bold">{formatPrice(total)}</span>
                    </div>
                </div>
            </Button>
        </div>
    );
}
