import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { PRODUTOS_MOCK } from "@/data/mockData";
import { formatPrice } from "@/lib/utils";
import { Edit, Power, PowerOff } from "lucide-react";
import { useState } from "react";
import { toast } from "sonner";

export function AdminMenu() {
    const [produtos, setProdutos] = useState(PRODUTOS_MOCK);

    const toggleStatus = (id: string, currentStatus: boolean) => {
        setProdutos(produtos.map(p =>
            p._id === id ? { ...p, ativo: !p.ativo } : p
        ));
        toast.success(`Produto ${currentStatus ? "desativado" : "ativado"} com sucesso!`);
    };

    return (
        <div>
            <div className="mb-8 flex items-center justify-between">
                <h1 className="text-3xl font-bold">Gerenciar Cardápio</h1>
                <Button>Novo Produto</Button>
            </div>

            <div className="rounded-lg border bg-card shadow-sm">
                <table className="w-full text-left text-sm">
                    <thead className="border-b bg-muted/50 text-muted-foreground">
                        <tr>
                            <th className="p-4 font-medium">Produto</th>
                            <th className="p-4 font-medium">Categoria</th>
                            <th className="p-4 font-medium">Preço</th>
                            <th className="p-4 font-medium">Status</th>
                            <th className="p-4 font-medium text-right">Ações</th>
                        </tr>
                    </thead>
                    <tbody>
                        {produtos.map((produto) => (
                            <tr key={produto._id} className="border-b last:border-0 hover:bg-muted/20">
                                <td className="p-4">
                                    <div className="flex items-center gap-3">
                                        <img
                                            src={produto.imagem_url}
                                            alt=""
                                            className="h-10 w-10 rounded-md object-cover bg-muted"
                                        />
                                        <div>
                                            <p className="font-medium">{produto.nome}</p>
                                            <p className="text-xs text-muted-foreground truncate max-w-[200px]">
                                                {produto.descricao}
                                            </p>
                                        </div>
                                    </div>
                                </td>
                                <td className="p-4">
                                    <Badge variant="outline">{produto.categoria}</Badge>
                                </td>
                                <td className="p-4 font-medium">
                                    {formatPrice(produto.preco_centavos)}
                                </td>
                                <td className="p-4">
                                    <Badge variant={produto.ativo ? "default" : "destructive"}>
                                        {produto.ativo ? "Ativo" : "Inativo"}
                                    </Badge>
                                </td>
                                <td className="p-4 text-right">
                                    <div className="flex justify-end gap-2">
                                        <Button size="icon" variant="ghost">
                                            <Edit className="h-4 w-4" />
                                        </Button>
                                        <Button
                                            size="icon"
                                            variant={produto.ativo ? "ghost" : "outline"}
                                            className={produto.ativo ? "text-destructive hover:text-destructive" : "text-green-600 hover:text-green-600"}
                                            onClick={() => toggleStatus(produto._id, produto.ativo)}
                                        >
                                            {produto.ativo ? <PowerOff className="h-4 w-4" /> : <Power className="h-4 w-4" />}
                                        </Button>
                                    </div>
                                </td>
                            </tr>
                        ))}
                    </tbody>
                </table>
            </div>
        </div>
    );
}
