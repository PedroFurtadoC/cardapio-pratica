import { Hero } from "@/components/home/Hero";
import { ProductCard } from "@/components/product/ProductCard";
import { Button } from "@/components/ui/button";
import { PRODUTOS_MOCK } from "@/data/mockData";
import { useState } from "react";

export function Home() {
    const [selectedCategory, setSelectedCategory] = useState<string>("TODOS");

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
                        <ProductCard key={produto._id} produto={produto} />
                    ))}
                </div>

                {filteredProducts.length === 0 && (
                    <div className="py-20 text-center text-muted-foreground">
                        Nenhum produto encontrado nesta categoria.
                    </div>
                )}
            </section>
        </main>
    );
}
