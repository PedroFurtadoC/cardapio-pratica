import { Button } from "@/components/ui/button";
import { COMPONENTES_MOCK } from "@/data/mockData";
import { formatPrice } from "@/lib/utils";
import { useCartStore } from "@/store/cartStore";
import { ArrowLeft, Bike, Send, Store, Trash2 } from "lucide-react";
import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { toast } from "sonner";

export function Checkout() {
    const { items, removeItem, updateQuantity, totalCartPrice } = useCartStore();
    const navigate = useNavigate();

    const [modalidade, setModalidade] = useState<"DELIVERY" | "RETIRADA">("DELIVERY");
    const [nome, setNome] = useState("");
    const [telefone, setTelefone] = useState("");
    const [endereco, setEndereco] = useState({
        cep: "",
        rua: "",
        numero: "",
        bairro: "",
        complemento: ""
    });

    const subtotal = totalCartPrice();
    const taxaEntrega = modalidade === "DELIVERY" ? 500 : 0;
    const total = subtotal + taxaEntrega;

    const handleWhatsApp = () => {
        if (!nome || !telefone) {
            toast.error("Por favor, preencha seu nome e telefone.");
            return;
        }
        if (modalidade === "DELIVERY" && (!endereco.rua || !endereco.numero || !endereco.bairro)) {
            toast.error("Por favor, preencha o endereço de entrega.");
            return;
        }

        let message = `*NOVO PEDIDO - Coração de Mãe*\n\n`;
        message += `*Cliente:* ${nome}\n`;
        message += `*Telefone:* ${telefone}\n`;
        message += `*Modalidade:* ${modalidade === "DELIVERY" ? "🛵 Entrega" : "🏪 Retirada"}\n\n`;

        message += `*ITENS DO PEDIDO:*\n`;
        items.forEach((item) => {
            message += `- ${item.quantidade}x ${item.produto.nome} (${formatPrice(item.totalPrice)})\n`;
            if (item.selections) {
                const componentes = Object.entries(item.selections)
                    .map(([id, qty]) => {
                        const comp = COMPONENTES_MOCK.find((c) => c._id === id);
                        return comp ? `${qty}x ${comp.nome}` : "";
                    })
                    .filter(Boolean)
                    .join(", ");
                message += `  _(${componentes})_\n`;
            }
        });

        message += `\n*RESUMO FINANCEIRO:*\n`;
        message += `Subtotal: ${formatPrice(subtotal)}\n`;
        message += `Taxa de Entrega: ${formatPrice(taxaEntrega)}\n`;
        message += `*TOTAL: ${formatPrice(total)}*\n\n`;

        if (modalidade === "DELIVERY") {
            message += `*ENDEREÇO DE ENTREGA:*\n`;
            message += `${endereco.rua}, ${endereco.numero} - ${endereco.bairro}\n`;
            if (endereco.complemento) message += `Complemento: ${endereco.complemento}\n`;
        }

        const encodedMessage = encodeURIComponent(message);
        window.open(`https://wa.me/5516999999999?text=${encodedMessage}`, "_blank");
    };

    if (items.length === 0) {
        return (
            <div className="flex min-h-screen flex-col items-center justify-center p-4 text-center">
                <h2 className="mb-4 text-2xl font-bold">Seu carrinho está vazio</h2>
                <p className="mb-8 text-muted-foreground">Adicione algumas delícias para continuar.</p>
                <Button onClick={() => navigate("/")}>Voltar ao Cardápio</Button>
            </div>
        );
    }

    return (
        <div className="container mx-auto max-w-2xl px-4 py-8 pb-24">
            <Button variant="ghost" onClick={() => navigate("/")} className="mb-6 pl-0">
                <ArrowLeft className="mr-2 h-4 w-4" />
                Continuar Comprando
            </Button>

            <h1 className="mb-8 text-3xl font-bold">Finalizar Pedido</h1>

            {/* Lista de Itens */}
            <section className="mb-8 space-y-4">
                <h2 className="text-xl font-semibold">Seus Itens</h2>
                {items.map((item) => (
                    <div key={item.id} className="flex items-start justify-between rounded-lg border p-4">
                        <div className="flex-1">
                            <h3 className="font-medium">{item.produto.nome}</h3>
                            {item.selections && (
                                <p className="mt-1 text-sm text-muted-foreground">
                                    {Object.entries(item.selections)
                                        .map(([id, qty]) => {
                                            const comp = COMPONENTES_MOCK.find((c) => c._id === id);
                                            return comp ? `${qty}x ${comp.nome}` : "";
                                        })
                                        .join(", ")}
                                </p>
                            )}
                            <div className="mt-2 text-sm font-semibold text-primary">
                                {formatPrice(item.totalPrice)}
                            </div>
                        </div>

                        <div className="flex flex-col items-end gap-2">
                            <div className="flex items-center gap-2 rounded-md border bg-background">
                                <button
                                    className="px-2 py-1 hover:bg-accent"
                                    onClick={() => updateQuantity(item.id, -1)}
                                >
                                    -
                                </button>
                                <span className="w-4 text-center text-sm">{item.quantidade}</span>
                                <button
                                    className="px-2 py-1 hover:bg-accent"
                                    onClick={() => updateQuantity(item.id, 1)}
                                >
                                    +
                                </button>
                            </div>
                            <Button
                                variant="ghost"
                                size="icon"
                                className="h-8 w-8 text-destructive hover:text-destructive/90"
                                onClick={() => removeItem(item.id)}
                            >
                                <Trash2 className="h-4 w-4" />
                            </Button>
                        </div>
                    </div>
                ))}
            </section>

            {/* Modalidade */}
            <section className="mb-8">
                <h2 className="mb-4 text-xl font-semibold">Como deseja receber?</h2>
                <div className="grid grid-cols-2 gap-4">
                    <div
                        className={`cursor-pointer rounded-xl border-2 p-4 text-center transition-all ${modalidade === "DELIVERY"
                            ? "border-primary bg-primary/5"
                            : "border-transparent bg-secondary/10 hover:bg-secondary/20"
                            }`}
                        onClick={() => setModalidade("DELIVERY")}
                    >
                        <Bike className={`mx-auto mb-2 h-8 w-8 ${modalidade === "DELIVERY" ? "text-primary" : "text-muted-foreground"}`} />
                        <span className="font-semibold">Entrega</span>
                        <p className="text-xs text-muted-foreground">+ R$ 5,00</p>
                    </div>
                    <div
                        className={`cursor-pointer rounded-xl border-2 p-4 text-center transition-all ${modalidade === "RETIRADA"
                            ? "border-primary bg-primary/5"
                            : "border-transparent bg-secondary/10 hover:bg-secondary/20"
                            }`}
                        onClick={() => setModalidade("RETIRADA")}
                    >
                        <Store className={`mx-auto mb-2 h-8 w-8 ${modalidade === "RETIRADA" ? "text-primary" : "text-muted-foreground"}`} />
                        <span className="font-semibold">Retirada</span>
                        <p className="text-xs text-muted-foreground">Grátis</p>
                    </div>
                </div>
            </section>

            {/* Dados do Cliente */}
            <section className="mb-8 space-y-4">
                <h2 className="text-xl font-semibold">Seus Dados</h2>
                <div className="grid gap-4 sm:grid-cols-2">
                    <input
                        type="text"
                        placeholder="Seu Nome"
                        className="w-full rounded-md border p-2"
                        value={nome}
                        onChange={(e) => setNome(e.target.value)}
                    />
                    <input
                        type="tel"
                        placeholder="Seu WhatsApp (com DDD)"
                        className="w-full rounded-md border p-2"
                        value={telefone}
                        onChange={(e) => setTelefone(e.target.value)}
                    />
                </div>
            </section>

            {/* Endereço (Condicional) */}
            {modalidade === "DELIVERY" && (
                <section className="mb-8 space-y-4 animate-in slide-in-from-top-4 duration-300">
                    <h2 className="text-xl font-semibold">Endereço de Entrega</h2>
                    <div className="grid gap-4">
                        <div className="grid grid-cols-3 gap-4">
                            <input
                                type="text"
                                placeholder="CEP"
                                className="col-span-1 w-full rounded-md border p-2"
                                value={endereco.cep}
                                onChange={(e) => setEndereco({ ...endereco, cep: e.target.value })}
                            />
                            <input
                                type="text"
                                placeholder="Bairro"
                                className="col-span-2 w-full rounded-md border p-2"
                                value={endereco.bairro}
                                onChange={(e) => setEndereco({ ...endereco, bairro: e.target.value })}
                            />
                        </div>
                        <div className="grid grid-cols-4 gap-4">
                            <input
                                type="text"
                                placeholder="Rua / Avenida"
                                className="col-span-3 w-full rounded-md border p-2"
                                value={endereco.rua}
                                onChange={(e) => setEndereco({ ...endereco, rua: e.target.value })}
                            />
                            <input
                                type="text"
                                placeholder="Nº"
                                className="col-span-1 w-full rounded-md border p-2"
                                value={endereco.numero}
                                onChange={(e) => setEndereco({ ...endereco, numero: e.target.value })}
                            />
                        </div>
                        <input
                            type="text"
                            placeholder="Complemento (Opcional)"
                            className="w-full rounded-md border p-2"
                            value={endereco.complemento}
                            onChange={(e) => setEndereco({ ...endereco, complemento: e.target.value })}
                        />
                    </div>
                </section>
            )}

            <Button className="w-full py-6 text-lg" onClick={handleWhatsApp}>
                <Send className="mr-2 h-5 w-5" />
                Enviar Pedido no WhatsApp
            </Button>
        </div>
    );
}
