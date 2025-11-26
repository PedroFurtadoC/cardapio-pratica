import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { formatPrice } from "@/lib/utils";
import { Bike, CheckCircle, Clock, Store } from "lucide-react";

// Mock Orders
const ORDERS = [
    {
        id: "#1001",
        cliente: "João Silva",
        modalidade: "DELIVERY",
        status: "RECEBIDO",
        total: 4500,
        itens: ["1x Marmita Média", "1x Coca-Cola"],
        tempo: "5 min",
    },
    {
        id: "#1002",
        cliente: "Maria Oliveira",
        modalidade: "RETIRADA",
        status: "EM_PREPARO",
        total: 2200,
        itens: ["1x Marmita Grande"],
        tempo: "15 min",
    },
    {
        id: "#1003",
        cliente: "Carlos Souza",
        modalidade: "DELIVERY",
        status: "PRONTO",
        total: 6800,
        itens: ["2x Marmita Média", "2x Suco"],
        tempo: "30 min",
    },
];

const COLUMNS = [
    { id: "RECEBIDO", label: "Recebidos", color: "bg-blue-100 text-blue-700" },
    { id: "EM_PREPARO", label: "Em Preparo", color: "bg-yellow-100 text-yellow-700" },
    { id: "PRONTO", label: "Pronto / Saiu", color: "bg-green-100 text-green-700" },
    { id: "ENTREGUE", label: "Entregue", color: "bg-gray-100 text-gray-700" },
];

export function AdminDashboard() {
    return (
        <div>
            <h1 className="mb-8 text-3xl font-bold">Pedidos em Tempo Real</h1>

            {ORDERS.length === 0 ? (
                <div className="flex flex-col items-center justify-center rounded-lg border border-dashed p-12 text-center">
                    <div className="mb-4 rounded-full bg-muted p-4">
                        <Store className="h-8 w-8 text-muted-foreground" />
                    </div>
                    <h3 className="text-lg font-semibold">Nenhum pedido recebido</h3>
                    <p className="text-muted-foreground">Aguardando novos pedidos...</p>
                </div>
            ) : (
                <div className="grid grid-cols-1 gap-6 md:grid-cols-2 lg:grid-cols-4">
                    {COLUMNS.map((col) => (
                        <div key={col.id} className="flex flex-col rounded-lg bg-muted/50 p-4">
                            <div className={`mb-4 flex items-center justify-between rounded-md px-3 py-2 font-semibold ${col.color}`}>
                                <span>{col.label}</span>
                                <span className="rounded-full bg-white/50 px-2 py-0.5 text-xs">
                                    {ORDERS.filter((o) => o.status === col.id).length}
                                </span>
                            </div>

                            <div className="flex flex-col gap-4">
                                {ORDERS.filter((o) => o.status === col.id).map((order) => (
                                    <div key={order.id} className="flex flex-col rounded-lg border bg-card p-4 shadow-sm">
                                        <div className="mb-2 flex items-center justify-between">
                                            <span className="font-bold">{order.id}</span>
                                            <span className="text-xs text-muted-foreground flex items-center gap-1">
                                                <Clock className="h-3 w-3" /> {order.tempo}
                                            </span>
                                        </div>

                                        <div className="mb-3">
                                            <p className="font-medium">{order.cliente}</p>
                                            <div className="mt-1 flex items-center gap-2 text-xs text-muted-foreground">
                                                {order.modalidade === "DELIVERY" ? (
                                                    <Badge variant="secondary" className="gap-1 px-1.5 py-0">
                                                        <Bike className="h-3 w-3" /> Delivery
                                                    </Badge>
                                                ) : (
                                                    <Badge variant="outline" className="gap-1 px-1.5 py-0">
                                                        <Store className="h-3 w-3" /> Retirada
                                                    </Badge>
                                                )}
                                            </div>
                                        </div>

                                        <div className="mb-4 space-y-1 border-t pt-2 text-sm text-muted-foreground">
                                            {order.itens.map((item, idx) => (
                                                <p key={idx}>{item}</p>
                                            ))}
                                        </div>

                                        <div className="mt-auto flex items-center justify-between border-t pt-3">
                                            <span className="font-bold text-primary">{formatPrice(order.total)}</span>
                                            <Button size="sm" variant="ghost">
                                                Mover <CheckCircle className="ml-1 h-3 w-3" />
                                            </Button>
                                        </div>
                                    </div>
                                ))}
                            </div>
                        </div>
                    ))}
                </div>
            )}
        </div>
    );
}
