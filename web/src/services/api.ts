import axios from 'axios';

// Variável de ambiente do Vite ou URL de produção no Render como fallback (padrão)
const API_BASE_URL = import.meta.env.VITE_API_URL || 'https://cardapio-pratica.onrender.com';

const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

export default api;
