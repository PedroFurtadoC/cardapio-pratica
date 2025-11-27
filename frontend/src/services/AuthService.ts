import api from './api';
import { Usuario } from '../types';

interface LoginResponse {
	access_token: string;
	token_type: string;
	user: Usuario;
}

export const AuthService = {
	login: async (email: string, password: string): Promise<LoginResponse> => {
		const response = await api.post<LoginResponse>('/auth/login', { email, password });
		
		if (response.data.access_token) {
			api.defaults.headers.common['Authorization'] = `Bearer ${response.data.access_token}`;
		}
		return response.data;
	},

	logout: async (): Promise<void> => {
		// Remove o token do header
		delete api.defaults.headers.common['Authorization'];
		// Opcional: chamar endpoint de logout no backend se existir lista de revogação
		// await api.post('/auth/logout');
	}
};
