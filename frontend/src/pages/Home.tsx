import { Hero } from "@/components/home/Hero";
import { ModalMontagemMarmita } from "@/components/marmita/ModalMontagemMarmita";
import { ProductCard } from "@/components/product/ProductCard";
import { Button } from "@/components/ui/button";
import { COMPONENTES_MOCK, PRODUTOS_MOCK } from "@/data/mockData";
import { useCartStore } from "@/store/cartStore";
import { Produto } from "@/types";
import { useState } from "react";
import { toast } from "sonner";

export function Home() {
    const [selectedCategory, setSelectedCategory] = useState<string>("TODOS");
    const [selectedProduct, setSelectedProduct] = useState<Produto | null>(null);
    const [isModalOpen, setIsModalOpen] = useState(false);

    const addItem = useCartStore((state) => state.addItem);

    const categories = [
        { id: "TODOS", label: "Todos" },
        { id: "MARMITAS", label: "Marmitas" },
        { id: "SALGADOS", label: "Salgados" },
        { id: "BEBIDAS", label: "Bebidas" },
        { id: "SOBREMESAS", label: "Sobremesas" },
    ];

    const filteredProducts = selectedCategory === "TODOS"
        ? PRODUTOS_MOCK
        : PRODUTOS_MOCK.filter((p) => p.categoria === selectedCategory);

    const handleProductClick = (produto: Produto) => {
        if (produto.tipo === "COMPOSTO") {
            setSelectedProduct(produto);
            setIsModalOpen(true);
        } else {
            addItem({
                produto,
                quantidade: 1,
                totalPrice: produto.preco_centavos,
            });
            toast.success(`${produto.nome} adicionado ao carrinho!`);
        }
    };

    const handleAddToCart = (item: { produto: Produto; selections?: { [key: string]: number }; totalPrice: number }) => {
        addItem({
            produto: item.produto,
            quantidade: 1,
            selections: item.selections,
            totalPrice: item.totalPrice,
        });
        toast.success(`${item.produto.nome} montada e adicionada!`);
    };

    return (
        <main className="min-h-screen bg-background pb-20">
            <Hero />

            <section className="container mx-auto px-4 py-12">
                <div className="mb-8 flex flex-wrap items-center justify-center gap-2">
                    {categories.map((cat) => (
                        <Button
                            key={cat.id}
                            variant={selectedCategory === cat.id ? "default" : "outline"}
                            onClick={() => setSelectedCategory(cat.id)}
                            className="rounded-full"
                        >
                            {cat.label}
                        </Button>
                    ))}
                </div>

                <div className="grid gap-6 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4">
                    {filteredProducts.map((produto) => (
                        <ProductCard
                            key={produto._id}
                            produto={produto}
                            onSelect={() => handleProductClick(produto)}
                        />
                    ))}
                </div>

                {filteredProducts.length === 0 && (
                    <div className="py-20 text-center text-muted-foreground">
                        Nenhum produto encontrado nesta categoria.
                    </div>
                )}
            </section>

            {selectedProduct && (
                <ModalMontagemMarmita
                    isOpen={isModalOpen}
                    onClose={() => setIsModalOpen(false)}
                    produto={selectedProduct}
                    componentes={COMPONENTES_MOCK}
                    onAddToCart={handleAddToCart}
                />
            )}
        </main>
    );
}
