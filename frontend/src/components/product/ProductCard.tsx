import { formatPrice } from "@/lib/utils";
import { Produto } from "@/types";
import { Plus, Utensils } from "lucide-react";
import { Badge } from "../ui/badge";
import { Button } from "../ui/button";

interface ProductCardProps {
    produto: Produto;
    onSelect?: () => void;
}

export function ProductCard({ produto, onSelect }: ProductCardProps) {
    const handleAdd = () => {
        if (onSelect) {
            onSelect();
        } else {

        }
    };

    return (
        <div className="group relative flex flex-col overflow-hidden rounded-xl border bg-card shadow-sm transition-all hover:shadow-md">
            <div className="aspect-video w-full overflow-hidden bg-muted">
                <img
                    src={produto.imagem_url}
                    alt={produto.nome}
                    className="h-full w-full object-cover transition-transform duration-300 group-hover:scale-105"
                    loading="lazy"
                />
            </div>
            <div className="flex flex-1 flex-col p-4">
                <div className="mb-2 flex flex-wrap gap-1">
                    {produto.tags_dieteticas.map((tag) => (
                        <Badge key={tag} variant="secondary" className="text-[10px]">
                            {tag.replace("_", " ")}
                        </Badge>
                    ))}
                </div>
                <h3 className="text-lg font-semibold leading-tight text-foreground">
                    {produto.nome}
                </h3>
                <p className="mt-2 line-clamp-2 text-sm text-muted-foreground">
                    {produto.descricao}
                </p>
                <div className="mt-auto flex items-center justify-between pt-4">
                    <span className="text-lg font-bold text-primary">
                        {formatPrice(produto.preco_centavos)}
                    </span>
                    <Button onClick={handleAdd} size="sm" className="gap-2">
                        {produto.tipo === "COMPOSTO" ? (
                            <>
                                <Utensils className="h-4 w-4" />
                                Montar
                            </>
                        ) : (
                            <>
                                <Plus className="h-4 w-4" />
                                Adicionar
                            </>
                        )}
                    </Button>
                </div>
            </div>
        </div>
    );
}
