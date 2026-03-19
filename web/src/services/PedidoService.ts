import api from './api';
import { Pedido, PedidoCreate, StatusPedido } from '../types';

export const PedidoService = {
	getAll: async (): Promise<Pedido[]> => {
		const response = await api.get<Pedido[]>('/pedidos');
		return response.data;
	},

	getById: async (id: string): Promise<Pedido> => {
		const response = await api.get<Pedido>(`/pedidos/${id}`);
		return response.data;
	},

	create: async (data: PedidoCreate): Promise<Pedido> => {
		const response = await api.post<Pedido>('/pedidos', data);
		return response.data;
	},

	// Rota específica PATCH criada no backend para atualizar status
	updateStatus: async (id: string, status: StatusPedido): Promise<Pedido> => {
		const response = await api.patch<Pedido>(`/pedidos/${id}/status`, { status });
		return response.data;
	}
};
