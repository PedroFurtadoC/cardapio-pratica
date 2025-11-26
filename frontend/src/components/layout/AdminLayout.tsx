import { useAuthStore } from "@/store/authStore";
import { LayoutDashboard, LogOut, UtensilsCrossed } from "lucide-react";
import { Link, Outlet, useNavigate } from "react-router-dom";
import { Button } from "../ui/button";

export function AdminLayout() {
    const logout = useAuthStore((state) => state.logout);
    const navigate = useNavigate();

    const handleLogout = () => {
        logout();
        navigate("/admin/login");
    };

    return (
        <div className="flex min-h-screen bg-muted/20">
            {/* Sidebar */}
            <aside className="fixed left-0 top-0 z-40 h-screen w-64 border-r bg-slate-900 text-slate-50">
                <div className="flex h-16 items-center border-b border-slate-800 px-6">
                    <span className="text-lg font-bold">Admin Panel</span>
                </div>
                <nav className="space-y-1 p-4">
                    <Link
                        to="/admin"
                        className="flex items-center gap-3 rounded-md px-3 py-2 text-sm font-medium transition-colors hover:bg-slate-800"
                    >
                        <LayoutDashboard className="h-4 w-4" />
                        Pedidos
                    </Link>
                    <Link
                        to="/admin/cardapio"
                        className="flex items-center gap-3 rounded-md px-3 py-2 text-sm font-medium transition-colors hover:bg-slate-800"
                    >
                        <UtensilsCrossed className="h-4 w-4" />
                        Cardápio
                    </Link>
                </nav>
                <div className="absolute bottom-4 left-0 w-full px-4">
                    <Button
                        variant="destructive"
                        className="w-full justify-start gap-3"
                        onClick={handleLogout}
                    >
                        <LogOut className="h-4 w-4" />
                        Sair
                    </Button>
                </div>
            </aside>

            {/* Main Content */}
            <main className="ml-64 flex-1 p-8">
                <Outlet />
            </main>
        </div>
    );
}
