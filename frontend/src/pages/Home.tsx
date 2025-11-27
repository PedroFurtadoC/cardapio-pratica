import { ModalMontagemMarmita } from "@/components/marmita/ModalMontagemMarmita";
import { ProductCard } from "@/components/product/ProductCard";
import { Badge } from "@/components/ui/badge";
import { ComponenteService } from "../services/ComponenteService";
import { ProdutoService } from "../services/ProdutoService";
import { useCartStore } from "@/store/cartStore";
import { Componente, Produto } from "@/types";
import { Loader2 } from "lucide-react";
import { useEffect, useState } from "react";
import { toast } from "sonner";

export function Home() {
    const [selectedCategory, setSelectedCategory] = useState("TODOS");
    const [selectedProduct, setSelectedProduct] = useState<Produto | null>(null);
    const [isModalOpen, setIsModalOpen] = useState(false);
    
    // Estados de Dados da API
    const [products, setProducts] = useState<Produto[]>([]);
    const [components, setComponents] = useState<Componente[]>([]);
    const [loading, setLoading] = useState(true);

    const addItem = useCartStore((state) => state.addItem);

    // Carregar dados iniciais
    useEffect(() => {
        const fetchData = async () => {
            try {
                const [prodsData, compsData] = await Promise.all([
                    ProdutoService.getAll(),
                    ComponenteService.getAll()
                ]);
                setProducts(prodsData);
                setComponents(compsData);
            } catch (error) {
                console.error("Erro ao carregar dados:", error);
                toast.error("Erro ao carregar cardápio. Tente novamente.");
            } finally {
                setLoading(false);
            }
        };
        fetchData();
    }, []);

    const categories = [
        { id: "TODOS", label: "Todos" },
        { id: "MARMITAS", label: "Marmitas" },
        { id: "SALGADOS", label: "Salgados" },
        { id: "BEBIDAS", label: "Bebidas" },
        { id: "SOBREMESAS", label: "Sobremesas" },
        { id: "PRATOS_PRONTOS", label: "Pratos Prontos" },
    ];

    const filteredProducts = selectedCategory === "TODOS"
        ? products
        : products.filter((p) => p.categoria === selectedCategory);

    const handleProductClick = (produto: Produto) => {
        if (produto.tipo === "COMPOSTO") {
            setSelectedProduct(produto);
            setIsModalOpen(true);
        } else {
            // Para produtos simples, adiciona direto
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

    if (loading) {
        return (
            <div className="flex h-screen items-center justify-center">
                <Loader2 className="h-8 w-8 animate-spin text-primary" />
            </div>
        );
    }

    return (
        <div className="container mx-auto pb-20 px-4 pt-6">
            <h1 className="mb-6 text-2xl font-bold">Nosso Cardápio</h1>

            {/* Categorias */}
            <div className="scrollbar-hide mb-8 flex gap-3 overflow-x-auto pb-2">
                {categories.map((cat) => (
                    <Badge
                        key={cat.id}
                        variant={selectedCategory === cat.id ? "default" : "outline"}
                        onClick={() => setSelectedCategory(cat.id)}
                        className="cursor-pointer whitespace-nowrap px-4 py-2 text-sm hover:bg-primary/90 hover:text-white"
                    >
                        {cat.label}
                    </Badge>
                ))}
            </div>

            {/* Grid de Produtos */}
            <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4">
                {filteredProducts.map((produto) => (
                    <ProductCard
                        key={produto._id}
                        produto={produto}
                        onSelect={() => handleProductClick(produto)}
                    />
                ))}
            </div>

            {/* Empty State */}
            {filteredProducts.length === 0 && (
                <div className="py-12 text-center text-gray-500">
                    <p>Nenhum produto encontrado nesta categoria.</p>
                </div>
            )}

            {/* Modal de Montagem */}
            {selectedProduct && (
                <ModalMontagemMarmita
                    isOpen={isModalOpen}
                    onClose={() => setIsModalOpen(false)}
                    produto={selectedProduct}
                    componentes={components} // Passando componentes reais da API
                    onAddToCart={handleAddToCart}
                />
            )}
        </div>
    );
}
