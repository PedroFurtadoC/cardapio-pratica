import axios from 'axios';

const api = axios.create({
  baseURL: 'http://54.167.29.152:8000', 
  headers: {
    'Content-Type': 'application/json',
  },
});

export default api;
