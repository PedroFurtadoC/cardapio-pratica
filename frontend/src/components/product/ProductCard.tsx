import { formatPrice } from "@/lib/utils";
import { Produto } from "@/types";
import { Plus, Utensils } from "lucide-react";
import { Badge } from "../ui/badge";
import { Button } from "../ui/button";
import { useCartStore } from "@/store/cartStore";
import { toast } from "sonner"; // Assumindo que você tem uma lib de toast, se não tiver, remova

interface ProductCardProps {
    produto: Produto;
    onSelect?: () => void;
}

export function ProductCard({ produto, onSelect }: ProductCardProps) {
    const addItem = useCartStore((state) => state.addItem);

    const handleAdd = () => {
        if (produto.tipo === "COMPOSTO" && onSelect) {
            // Abre o modal de montagem
            onSelect();
        } else {
            // Adiciona produto simples diretamente ao carrinho
            addItem({
                produto,
                quantidade: 1,
                totalPrice: produto.preco_centavos
            });
            // Feedback visual (opcional)
            toast.success(`${produto.nome} adicionado ao pedido!`);
        }
    };

    return (
        <div className="bg-white rounded-xl shadow-sm hover:shadow-md transition-shadow overflow-hidden flex flex-col h-full border border-gray-100">
            <div className="relative h-48 bg-gray-100">
                {produto.imagem_url ? (
                    <img 
                        src={produto.imagem_url} 
                        alt={produto.nome} 
                        className="w-full h-full object-cover"
                    />
                ) : (
                    <div className="flex items-center justify-center h-full text-gray-400">
                        <Utensils className="h-12 w-12" />
                    </div>
                )}
            </div>

            <div className="p-4 flex-1 flex flex-col">
                <div className="flex gap-2 flex-wrap mb-2">
                    {produto.tags_dieteticas.map((tag) => (
                        <Badge key={tag} variant="secondary" className="text-[10px] px-1.5 h-5">
                            {tag.replace("_", " ")}
                        </Badge>
                    ))}
                </div>

                <h3 className="font-semibold text-lg text-gray-900 line-clamp-1 mb-1">
                    {produto.nome}
                </h3>

                <p className="text-sm text-gray-500 line-clamp-2 mb-4 flex-1">
                    {produto.descricao}
                </p>

                <div className="flex items-center justify-between mt-auto">
                    <span className="font-bold text-lg text-primary">
                        {formatPrice(produto.preco_centavos)}
                    </span>
                    
                    <Button 
                        size="sm" 
                        onClick={handleAdd}
                        disabled={!produto.ativo}
                        className={!produto.ativo ? "opacity-50 cursor-not-allowed" : ""}
                    >
                        {produto.tipo === "COMPOSTO" ? (
                            <>
                                <Utensils className="mr-2 h-4 w-4" />
                                Montar
                            </>
                        ) : (
                            <>
                                <Plus className="mr-2 h-4 w-4" />
                                Adicionar
                            </>
                        )}
                    </Button>
                </div>
            </div>
        </div>
    );
}
