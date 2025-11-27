import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { formatPrice } from "@/lib/utils";
import { PedidoService } from "../../services/PedidoService";
import { Pedido, StatusPedido } from "@/types";
import { Loader2, RefreshCw } from "lucide-react";
import { useEffect, useState } from "react";
import { toast } from "sonner";

const COLUMNS: { id: StatusPedido; label: string; color: string }[] = [
    { id: "RECEBIDO", label: "Recebidos", color: "bg-blue-100 text-blue-700" },
    { id: "EM_PREPARO", label: "Em Preparo", color: "bg-yellow-100 text-yellow-700" },
    { id: "PRONTO", label: "Pronto", color: "bg-green-100 text-green-700" },
    { id: "ENTREGUE", label: "Entregue", color: "bg-gray-100 text-gray-700" },
];

export function AdminDashboard() {
    const [orders, setOrders] = useState<Pedido[]>([]);
    const [loading, setLoading] = useState(true);

    const fetchOrders = async () => {
        setLoading(true);
        try {
            const data = await PedidoService.getAll();
            // Ordenar por data (mais recentes primeiro) se necessário
            setOrders(data.reverse()); 
        } catch (error) {
            console.error(error);
            toast.error("Erro ao carregar pedidos.");
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        fetchOrders();
        // Polling simples a cada 30 segundos
        const interval = setInterval(fetchOrders, 30000);
        return () => clearInterval(interval);
    }, []);

    const handleUpdateStatus = async (id: string, currentStatus: StatusPedido) => {
        let nextStatus: StatusPedido | null = null;
        if (currentStatus === "RECEBIDO") nextStatus = "EM_PREPARO";
        else if (currentStatus === "EM_PREPARO") nextStatus = "PRONTO";
        else if (currentStatus === "PRONTO") nextStatus = "ENTREGUE";

        if (nextStatus) {
            try {
                // Atualização otimista da UI
                setOrders(orders.map(o => o._id === id ? { ...o, status: nextStatus! } : o));
                
                await PedidoService.updateStatus(id, nextStatus);
                toast.success(`Pedido #${id.slice(-4)} movido para ${nextStatus}`);
            } catch (error) {
                console.error(error);
                toast.error("Erro ao atualizar status.");
                fetchOrders(); // Reverte em caso de erro
            }
        }
    };

    return (
        <div className="h-full flex flex-col">
            <div className="mb-6 flex items-center justify-between">
                <h1 className="text-2xl font-bold">Pedidos em Tempo Real</h1>
                <Button variant="outline" size="sm" onClick={fetchOrders} disabled={loading}>
                    <RefreshCw className={`mr-2 h-4 w-4 ${loading ? 'animate-spin' : ''}`} />
                    Atualizar
                </Button>
            </div>

            {loading && orders.length === 0 ? (
                <div className="flex flex-1 items-center justify-center">
                    <Loader2 className="h-8 w-8 animate-spin text-primary" />
                </div>
            ) : orders.length === 0 ? (
                <div className="flex flex-1 flex-col items-center justify-center text-gray-400">
                    <p>Nenhum pedido encontrado.</p>
                </div>
            ) : (
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 h-full overflow-x-auto pb-4">
                    {COLUMNS.map((col) => (
                        <div key={col.id} className="flex flex-col rounded-lg bg-gray-50 p-4 h-full min-w-[280px]">
                            <div className={`mb-4 flex items-center justify-between rounded px-3 py-2 font-bold ${col.color}`}>
                                {col.label}
                                <Badge variant="secondary" className="bg-white/50 text-inherit border-0">
                                    {orders.filter((o) => o.status === col.id).length}
                                </Badge>
                            </div>

                            <div className="flex-1 space-y-3 overflow-y-auto pr-2">
                                {orders.filter((o) => o.status === col.id).map((order) => (
                                    <div key={order._id} className="bg-white p-3 rounded-lg shadow-sm border border-gray-100">
                                        <div className="flex justify-between items-start mb-2">
                                            <span className="font-mono text-xs text-gray-400">#{order.codigo_pedido}</span>
                                            <span className="text-xs text-gray-400">
                                                {new Date(order.data_criacao).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                                            </span>
                                        </div>

                                        <div className="mb-2">
                                            <p className="font-bold text-gray-800">{order.cliente.nome}</p>
                                            <div className="flex gap-2 text-xs mt-1">
                                                <Badge variant="outline" className={order.modalidade === "DELIVERY" ? "text-blue-600 bg-blue-50" : "text-orange-600 bg-orange-50"}>
                                                    {order.modalidade}
                                                </Badge>
                                            </div>
                                        </div>

                                        <div className="text-sm text-gray-600 mb-3 border-t border-b py-2 space-y-1">
                                            {order.itens.map((item, idx) => (
                                                <div key={idx} className="flex justify-between">
                                                    <span>{item.quantidade}x {item.nome_produto}</span>
                                                </div>
                                            ))}
                                        </div>

                                        <div className="flex items-center justify-between mt-2">
                                            <span className="font-bold text-primary">{formatPrice(order.valor_total_centavos)}</span>
                                            
                                            {order.status !== "ENTREGUE" && (
                                                <Button 
                                                    size="sm" 
                                                    variant="outline"
                                                    onClick={() => handleUpdateStatus(order._id, order.status)}
                                                >
                                                    Mover &rarr;
                                                </Button>
                                            )}
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
