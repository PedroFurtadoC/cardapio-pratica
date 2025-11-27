import { useAuthStore } from "@/store/authStore";
import { LayoutDashboard, LogOut, UtensilsCrossed } from "lucide-react";
import { Link, Outlet, useNavigate } from "react-router-dom";
import { Button } from "../ui/button";

export function AdminLayout() {
    const logout = useAuthStore((state) => state.logout);
    const user = useAuthStore((state) => state.user);
    const navigate = useNavigate();

    const handleLogout = () => {
        logout();
        navigate("/admin/login");
    };

    return (
        <div className="flex h-screen bg-gray-100">
            {/* Sidebar */}
            <aside className="w-64 bg-white shadow-md flex flex-col">
                <div className="p-6 border-b">
                    <h1 className="text-xl font-bold text-primary">Admin Panel</h1>
                    <p className="text-sm text-gray-500">Olá, {user?.nome || 'Admin'}</p>
                </div>

                <nav className="flex-1 p-4 space-y-2">
                    <Link to="/admin">
                        <Button variant="ghost" className="w-full justify-start gap-2">
                            <LayoutDashboard className="h-4 w-4" />
                            Pedidos
                        </Button>
                    </Link>
                    <Link to="/admin/cardapio">
                        <Button variant="ghost" className="w-full justify-start gap-2">
                            <UtensilsCrossed className="h-4 w-4" />
                            Cardápio
                        </Button>
                    </Link>
                </nav>

                <div className="p-4 border-t">
                    <Button 
                        variant="outline" 
                        className="w-full justify-start gap-2 text-red-600 hover:text-red-700 hover:bg-red-50"
                        onClick={handleLogout}
                    >
                        <LogOut className="h-4 w-4" />
                        Sair
                    </Button>
                </div>
            </aside>

            {/* Main Content */}
            <main className="flex-1 overflow-auto p-8">
                <Outlet />
            </main>
        </div>
    );
}
