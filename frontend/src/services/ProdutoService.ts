import api from './api';
import { Produto, ProdutoCreate, ProdutoUpdate } from '../types';

export const ProdutoService = {
	getAll: async (): Promise<Produto[]> => {
		const response = await api.get<Produto[]>('/produtos');
		return response.data;
	},

	create: async (data: ProdutoCreate): Promise<Produto> => {
		const response = await api.post<Produto>('/produtos', data);
		return response.data;
	},

	update: async (id: string, data: ProdutoUpdate): Promise<Produto> => {
		const response = await api.put<Produto>(`/produtos/${id}`, data);
		return response.data;
	},

	delete: async (id: string): Promise<void> => {
		await api.delete(`/produtos/${id}`);
	}
};
