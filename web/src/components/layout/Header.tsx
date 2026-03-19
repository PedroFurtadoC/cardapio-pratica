import { useCartStore } from "@/store/cartStore";
import { Menu, ShoppingCart } from "lucide-react";
import { useNavigate } from "react-router-dom";
import { Badge } from "../ui/badge";
import { Button } from "../ui/button";

export function Header() {
    const items = useCartStore((state) => state.items);
    const itemCount = items.reduce((acc, item) => acc + item.quantidade, 0);
    const navigate = useNavigate();

    return (
        <header className="sticky top-0 z-50 w-full border-b bg-white backdrop-blur supports-[backdrop-filter]:bg-white/60">
            <div className="container mx-auto flex h-16 items-center justify-between px-4">
                <div className="flex items-center gap-2">
                    <Button variant="ghost" size="icon" className="md:hidden">
                        <Menu className="h-6 w-6" />
                    </Button>
                    <a href="/" className="flex items-center gap-2">
                        <img src="/logo.png" alt="Coração de Mãe" className="h-12 w-auto object-contain" />
                    </a>
                </div>

                <nav className="hidden md:flex items-center gap-6 text-sm font-medium">
                    <a href="/" className="transition-colors hover:text-primary">Cardápio</a>
                    <a href="/sobre" className="transition-colors hover:text-primary">Sobre Nós</a>
                </nav>

                <div className="flex items-center gap-4">
                    <Button
                        variant="outline"
                        size="icon"
                        className="relative"
                        onClick={() => navigate("/checkout")}
                    >
                        <ShoppingCart className="h-5 w-5" />
                        {itemCount > 0 && (
                            <Badge variant="secondary" className="absolute -right-2 -top-2 h-5 w-5 justify-center rounded-full p-0">
                                {itemCount}
                            </Badge>
                        )}
                    </Button>
                </div>
            </div>
        </header>
    );
}
