import { Button } from "@/components/ui/button";
import { useAuthStore } from "@/store/authStore";
import { Lock } from "lucide-react";
import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { toast } from "sonner";

export function AdminLogin() {
    const [email, setEmail] = useState("");
    const [password, setPassword] = useState("");
    const login = useAuthStore((state) => state.login);
    const navigate = useNavigate();

    const handleLogin = (e: React.FormEvent) => {
        e.preventDefault();
        if (email === "admin@coracaodemae.com" && password === "123") {
            login(email);
            navigate("/admin");
            toast.success("Bem-vindo de volta!");
        } else {
            toast.error("Credenciais inválidas!");
        }
    };

    return (
        <div className="flex min-h-screen items-center justify-center bg-muted/20">
            <div className="w-full max-w-md rounded-lg border bg-background p-8 shadow-lg">
                <div className="mb-8 text-center">
                    <div className="mx-auto mb-4 flex h-12 w-12 items-center justify-center rounded-full bg-primary/10">
                        <Lock className="h-6 w-6 text-primary" />
                    </div>
                    <h1 className="text-2xl font-bold">Área Restrita</h1>
                    <p className="text-sm text-muted-foreground">Acesso exclusivo para administração</p>
                </div>

                <form onSubmit={handleLogin} className="space-y-4">
                    <div>
                        <label className="mb-2 block text-sm font-medium">Email</label>
                        <input
                            type="email"
                            className="w-full rounded-md border p-2"
                            value={email}
                            onChange={(e) => setEmail(e.target.value)}
                            placeholder="admin@coracaodemae.com"
                        />
                    </div>
                    <div>
                        <label className="mb-2 block text-sm font-medium">Senha</label>
                        <input
                            type="password"
                            className="w-full rounded-md border p-2"
                            value={password}
                            onChange={(e) => setPassword(e.target.value)}
                            placeholder="123"
                        />
                    </div>
                    <Button type="submit" className="w-full">
                        Entrar
                    </Button>
                </form>
            </div>
        </div>
    );
}
