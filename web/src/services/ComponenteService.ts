import api from './api';
import { Componente, ComponenteCreate, ComponenteUpdate } from '../types';

export const ComponenteService = {
	getAll: async (): Promise<Componente[]> => {
		const response = await api.get<Componente[]>('/componentes');
		return response.data;
	},

	create: async (data: ComponenteCreate): Promise<Componente> => {
		const response = await api.post<Componente>('/componentes', data);
		return response.data;
	},

	update: async (id: string, data: ComponenteUpdate): Promise<Componente> => {
		const response = await api.put<Componente>(`/componentes/${id}`, data);
		return response.data;
	},

	delete: async (id: string): Promise<void> => {
		await api.delete(`/componentes/${id}`);
	}
};
