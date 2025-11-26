import { AdminLayout } from "@/components/layout/AdminLayout";
import { CartFAB } from "@/components/layout/CartFAB";
import { Header } from "@/components/layout/Header";
import { Checkout } from "@/pages/Checkout";
import { Home } from "@/pages/Home";
import { AdminDashboard } from "@/pages/admin/Dashboard";
import { AdminLogin } from "@/pages/admin/Login";
import { AdminMenu } from "@/pages/admin/Menu";
import { useAuthStore } from "@/store/authStore";
import { Navigate, Outlet, Route, BrowserRouter as Router, Routes } from "react-router-dom";
import { Toaster } from "sonner";

const ProtectedRoute = () => {
    const isAuthenticated = useAuthStore((state) => state.isAuthenticated);
    return isAuthenticated ? <Outlet /> : <Navigate to="/admin/login" replace />;
};


// ... imports

function App() {
    return (
        <Router>
            <Toaster position="top-center" richColors />
            <CartFAB />
            <Routes>
                {/* Public Routes */}
                <Route element={
                    <div className="flex min-h-screen flex-col">
                        <Header />
                        <Outlet />
                    </div>
                }>
                    <Route path="/" element={<Home />} />
                    <Route path="/checkout" element={<Checkout />} />
                    <Route path="/sobre" element={<div className="p-20 text-center">Sobre Nós (Em breve)</div>} />
                </Route>

                {/* Admin Routes */}
                <Route path="/admin/login" element={<AdminLogin />} />

                <Route element={<ProtectedRoute />}>
                    <Route path="/admin" element={<AdminLayout />}>
                        <Route index element={<AdminDashboard />} />
                        <Route path="cardapio" element={<AdminMenu />} />
                    </Route>
                </Route>
            </Routes>
        </Router>
    );
}

export default App;
