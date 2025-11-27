import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { formatPrice } from "@/lib/utils";
import { ComponenteService } from "../services/ComponenteService";
import { PedidoService } from "../services/PedidoService";
import { useCartStore } from "@/store/cartStore";
import { Componente, PedidoCreate } from "@/types";
import { ArrowLeft, Loader2, Trash2 } from "lucide-react";
import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import { toast } from "sonner";

export function Checkout() {
    const { items, removeItem, updateQuantity, totalCartPrice, clearCart } = useCartStore();
    const navigate = useNavigate();
    
    // Estado local para mapeamento de componentes (para gerar a string de seleções)
    const [allComponents, setAllComponents] = useState<Componente[]>([]);
    const [isSubmitting, setIsSubmitting] = useState(false);

    useEffect(() => {
        // Carregamos os componentes para poder traduzir ID -> Nome na hora de criar o pedido
        ComponenteService.getAll().then(setAllComponents).catch(console.error);
    }, []);

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
    const taxaEntrega = modalidade === "DELIVERY" ? 1000 : 0; // Exemplo: R$ 10,00 fixo
    const total = subtotal + taxaEntrega;

    const handleFinishOrder = async () => {
        // 1. Validação
        if (!nome || !telefone) {
            toast.error("Por favor, preencha seu nome e telefone.");
            return;
        }
        if (modalidade === "DELIVERY" && (!endereco.rua || !endereco.numero || !endereco.bairro)) {
            toast.error("Por favor, preencha o endereço de entrega.");
            return;
        }

        setIsSubmitting(true);

        try {
            // 2. Construir Payload para API
            const pedidoPayload: PedidoCreate = {
                cliente: {
                    nome,
                    telefone,
                },
                modalidade,
                forma_pagamento: "PIX", // Simplificado para este exemplo
                entrega: modalidade === "DELIVERY" ? {
                    logradouro: endereco.rua,
                    numero: endereco.numero,
                    bairro: endereco.bairro
                } : undefined,
                itens: items.map(cartItem => {
                    // Converter selections {id: qty} para lista de nomes ["Arroz", "Feijão"]
                    let selecoesNomes: string[] = [];
                    if (cartItem.selections) {
                        Object.entries(cartItem.selections).forEach(([compId, qty]) => {
                            const comp = allComponents.find(c => c._id === compId);
                            if (comp) {
                                // Adiciona o nome N vezes conforme a quantidade
                                for (let i = 0; i < qty; i++) {
                                    selecoesNomes.push(comp.nome);
                                }
                            }
                        });
                    }

                    return {
                        nome_produto: cartItem.produto.nome,
                        quantidade: cartItem.quantidade,
                        preco_unitario: cartItem.totalPrice,
                        selecoes: selecoesNomes
                    };
                })
            };

            // 3. Enviar para Backend
            const novoPedido = await PedidoService.create(pedidoPayload);

            // 4. Montar mensagem WhatsApp (Opcional, mas útil para o fluxo)
            let message = `*NOVO PEDIDO #${novoPedido.codigo_pedido}*\n`;
            message += `*Cliente:* ${nome}\n`;
            message += `--------------------------------\n`;
            
            // Reutiliza a info local para a mensagem do zap ser rápida
            items.forEach((item) => {
                message += `${item.quantidade}x ${item.produto.nome}\n`;
                if (item.selections) {
                    const comps = Object.entries(item.selections)
                        .map(([id, qty]) => {
                            const c = allComponents.find(comp => comp._id === id);
                            return c ? `${qty}x ${c.nome}` : "";
                        })
                        .filter(Boolean)
                        .join(", ");
                    if (comps) message += `   _(${comps})_\n`;
                }
            });
            message += `\n*Total:* ${formatPrice(total)}\n`;
            
            const encodedMessage = encodeURIComponent(message);
            const whatsappUrl = `https://wa.me/5516999999999?text=${encodedMessage}`;

            // 5. Limpar e Redirecionar
            clearCart();
            toast.success("Pedido realizado com sucesso!");
            
            // Pequeno delay para usuário ver o toast antes de abrir o WhatsApp
            setTimeout(() => {
                window.open(whatsappUrl, "_blank");
                navigate("/");
            }, 1500);

        } catch (error) {
            console.error(error);
            toast.error("Erro ao processar o pedido. Tente novamente.");
        } finally {
            setIsSubmitting(false);
        }
    };

    if (items.length === 0) {
        return (
            <div className="flex h-[80vh] flex-col items-center justify-center p-4 text-center">
                <h2 className="text-xl font-semibold">Seu carrinho está vazio</h2>
                <p className="mb-6 text-gray-500">Adicione algumas delícias para continuar.</p>
                <Button onClick={() => navigate("/")}>Voltar ao Cardápio</Button>
            </div>
        );
    }

    return (
        <div className="container mx-auto max-w-2xl px-4 py-6 pb-20">
            <Button variant="ghost" onClick={() => navigate("/")} className="mb-6 pl-0 hover:bg-transparent">
                <ArrowLeft className="mr-2 h-4 w-4" />
                Continuar Comprando
            </Button>

            <h1 className="mb-6 text-2xl font-bold">Finalizar Pedido</h1>

            {/* Lista de Itens */}
            <div className="mb-8 space-y-4">
                <h2 className="font-semibold text-gray-700">Seus Itens</h2>

                {items.map((item) => (
                    <div key={item.id} className="flex gap-4 rounded-lg border p-4 bg-white shadow-sm">
                        <div className="flex-1">
                            <h3 className="font-bold">{item.produto.nome}</h3>
                            
                            {item.selections && (
                                <p className="mt-1 text-sm text-gray-500">
                                    {Object.entries(item.selections)
                                        .map(([id, qty]) => {
                                            const comp = allComponents.find((c) => c._id === id);
                                            return comp ? `${qty}x ${comp.nome}` : "";
                                        })
                                        .filter(Boolean)
                                        .join(", ")}
                                </p>
                            )}
                            <div className="mt-2 font-medium text-primary">
                                {formatPrice(item.totalPrice * item.quantidade)}
                            </div>
                        </div>

                        <div className="flex flex-col items-end justify-between">
                            <div className="flex items-center gap-3 rounded-md border bg-gray-50 p-1">
                                <button 
                                    className="h-6 w-6 rounded hover:bg-gray-200"
                                    onClick={() => updateQuantity(item.id, -1)}
                                >-</button>
                                <span className="text-sm font-medium w-4 text-center">{item.quantidade}</span>
                                <button 
                                    className="h-6 w-6 rounded hover:bg-gray-200"
                                    onClick={() => updateQuantity(item.id, 1)}
                                >+</button>
                            </div>

                            <button 
                                className="text-red-500 hover:text-red-700"
                                onClick={() => removeItem(item.id)}
                            >
                                <Trash2 className="h-4 w-4" />
                            </button>
                        </div>
                    </div>
                ))}
            </div>

            {/* Modalidade */}
            <div className="mb-8">
                <h2 className="mb-3 font-semibold text-gray-700">Como deseja receber?</h2>
                <div className="grid grid-cols-2 gap-4">
                    <div 
                        className={`cursor-pointer rounded-lg border-2 p-4 text-center transition-all ${
                            modalidade === "DELIVERY" ? "border-primary bg-primary/5" : "border-gray-200"
                        }`}
                        onClick={() => setModalidade("DELIVERY")}
                    >
                        <h3 className="font-bold">Entrega</h3>
                        <p className="text-sm text-gray-500">+ {formatPrice(taxaEntrega)}</p>
                    </div>

                    <div 
                        className={`cursor-pointer rounded-lg border-2 p-4 text-center transition-all ${
                            modalidade === "RETIRADA" ? "border-primary bg-primary/5" : "border-gray-200"
                        }`}
                        onClick={() => setModalidade("RETIRADA")}
                    >
                        <h3 className="font-bold">Retirada</h3>
                        <p className="text-sm text-green-600">Grátis</p>
                    </div>
                </div>
            </div>

            {/* Dados do Cliente */}
            <div className="mb-8 space-y-4">
                <h2 className="font-semibold text-gray-700">Seus Dados</h2>
                <div className="grid gap-4">
                    <Input 
                        placeholder="Seu Nome Completo" 
                        value={nome}
                        onChange={(e) => setNome(e.target.value)}
                    />
                    <Input 
                        placeholder="Telefone / WhatsApp" 
                        value={telefone}
                        onChange={(e) => setTelefone(e.target.value)}
                    />
                </div>
            </div>

            {/* Endereço (Condicional) */}
            {modalidade === "DELIVERY" && (
                <div className="mb-8 space-y-4 animate-in fade-in slide-in-from-top-2">
                    <h2 className="font-semibold text-gray-700">Endereço de Entrega</h2>
                    <div className="space-y-3">
                        <div className="grid grid-cols-2 gap-3">
                            <Input 
                                placeholder="CEP" 
                                value={endereco.cep}
                                onChange={(e) => setEndereco({ ...endereco, cep: e.target.value })}
                            />
                            <Input 
                                placeholder="Bairro" 
                                value={endereco.bairro}
                                onChange={(e) => setEndereco({ ...endereco, bairro: e.target.value })}
                            />
                        </div>
                        <div className="grid grid-cols-[1fr_80px] gap-3">
                            <Input 
                                placeholder="Rua / Avenida" 
                                value={endereco.rua}
                                onChange={(e) => setEndereco({ ...endereco, rua: e.target.value })}
                            />
                            <Input 
                                placeholder="Nº" 
                                value={endereco.numero}
                                onChange={(e) => setEndereco({ ...endereco, numero: e.target.value })}
                            />
                        </div>
                        <Input 
                            placeholder="Complemento (Apto, Bloco, etc)" 
                            value={endereco.complemento}
                            onChange={(e) => setEndereco({ ...endereco, complemento: e.target.value })}
                        />
                    </div>
                </div>
            )}

            {/* Total e Ação */}
            <div className="rounded-lg bg-gray-50 p-6">
                <div className="mb-2 flex justify-between text-sm">
                    <span>Subtotal</span>
                    <span>{formatPrice(subtotal)}</span>
                </div>
                <div className="mb-4 flex justify-between text-sm">
                    <span>Taxa de Entrega</span>
                    <span>{formatPrice(taxaEntrega)}</span>
                </div>
                <div className="mb-6 flex justify-between border-t pt-4 text-xl font-bold text-primary">
                    <span>Total</span>
                    <span>{formatPrice(total)}</span>
                </div>

                <Button 
                    className="w-full py-6 text-lg" 
                    onClick={handleFinishOrder}
                    disabled={isSubmitting}
                >
                    {isSubmitting ? (
                        <>
                            <Loader2 className="mr-2 h-5 w-5 animate-spin" />
                            Enviando...
                        </>
                    ) : (
                        "Finalizar Pedido"
                    )}
                </Button>
            </div>
        </div>
    );
}
