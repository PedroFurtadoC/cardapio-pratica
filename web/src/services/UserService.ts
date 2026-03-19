import api from './api';
import { Usuario, UsuarioCreate, UsuarioUpdate } from '../types';

export const UserService = {
	getAll: async (): Promise<Usuario[]> => {
		const response = await api.get<Usuario[]>('/usuarios');
		return response.data;
	},

	create: async (data: UsuarioCreate): Promise<Usuario> => {
		const response = await api.post<Usuario>('/usuarios', data);
		return response.data;
	},

	update: async (id: string, data: UsuarioUpdate): Promise<Usuario> => {
		const response = await api.put<Usuario>(`/usuarios/${id}`, data);
		return response.data;
	},

	delete: async (id: string): Promise<void> => {
		await api.delete(`/usuarios/${id}`);
	}
};
