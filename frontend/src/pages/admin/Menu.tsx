import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle } from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { formatPrice } from "@/lib/utils";
import { ProdutoService } from "../../services/ProdutoService";
import { CategoriaProduto, Produto, ProdutoCreate, TipoProduto } from "@/types";
import { Edit, Image as ImageIcon, Loader2, Plus, Power, PowerOff, Trash2 } from "lucide-react";
import { useEffect, useState } from "react";
import { toast } from "sonner";

// Estado inicial para o formulário
const initialFormState: ProdutoCreate = {
    nome: "",
    descricao: "",
    preco_centavos: 0,
    categoria: "MARMITAS",
    tipo: "SIMPLES",
    imagem_url: "",
    ativo: true,
    tags_dieteticas: [],
    regras_composicao: { max_proteina: 1, max_guarnicao: 2 }
};

export function AdminMenu() {
    const [produtos, setProdutos] = useState<Produto[]>([]);
    const [loading, setLoading] = useState(true);
    
    // Estados do Modal e Formulário
    const [isDialogOpen, setIsDialogOpen] = useState(false);
    const [isSaving, setIsSaving] = useState(false);
    const [editingProduct, setEditingProduct] = useState<Produto | null>(null);
    const [formData, setFormData] = useState<ProdutoCreate>(initialFormState);
    const [priceInput, setPriceInput] = useState(""); // Input de preço em string (R$)

    const categories: CategoriaProduto[] = ["MARMITAS", "SALGADOS", "BEBIDAS", "SOBREMESAS", "PRATOS PRONTOS"];
    const types: TipoProduto[] = ["SIMPLES", "COMPOSTO"];

    const fetchProdutos = async () => {
        setLoading(true);
        try {
            const data = await ProdutoService.getAll();
            setProdutos(data);
        } catch (error) {
            console.error(error);
            toast.error("Erro ao carregar cardápio.");
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        fetchProdutos();
    }, []);

    // --- Ações de UI (Abrir Modais) ---

    const handleOpenCreate = () => {
        setEditingProduct(null);
        setFormData(initialFormState);
        setPriceInput("");
        setIsDialogOpen(true);
    };

    const handleOpenEdit = (produto: Produto) => {
        setEditingProduct(produto);
        setFormData({
            nome: produto.nome,
            descricao: produto.descricao,
            preco_centavos: produto.preco_centavos,
            categoria: produto.categoria,
            tipo: produto.tipo,
            imagem_url: produto.imagem_url,
            ativo: produto.ativo,
            tags_dieteticas: produto.tags_dieteticas,
            regras_composicao: produto.regras_composicao
        });
        setPriceInput((produto.preco_centavos / 100).toFixed(2));
        setIsDialogOpen(true);
    };

    // --- Lógica de CRUD ---

    const handleSave = async (e: React.FormEvent) => {
        e.preventDefault();

        if (!formData.nome || !formData.descricao) {
            toast.error("Preencha os campos obrigatórios.");
            return;
        }

        setIsSaving(true);
        try {
            // Converte input "10.50" para centavos (1050)
            const price = parseFloat(priceInput.replace(",", ".")) * 100;
            const payload = { ...formData, preco_centavos: Math.round(price) };

            if (editingProduct) {
                await ProdutoService.update(editingProduct._id, payload);
                toast.success("Produto atualizado!");
            } else {
                await ProdutoService.create(payload);
                toast.success("Produto criado!");
            }
            
            setIsDialogOpen(false);
            fetchProdutos(); // Recarrega a lista
        } catch (error) {
            console.error(error);
            toast.error("Erro ao salvar produto.");
        } finally {
            setIsSaving(false);
        }
    };

    const handleDelete = async (id: string) => {
        if (!confirm("Tem certeza que deseja excluir permanentemente este produto?")) return;
        try {
            await ProdutoService.delete(id);
            setProdutos(produtos.filter(p => p._id !== id));
            toast.success("Produto excluído.");
        } catch (error) {
            console.error(error);
            toast.error("Erro ao excluir produto.");
        }
    };

    const toggleStatus = async (id: string, currentStatus: boolean) => {
        // Optimistic update para UI rápida
        setProdutos(produtos.map(p =>
            p._id === id ? { ...p, ativo: !p.ativo } : p
        ));

        try {
            await ProdutoService.update(id, { ativo: !currentStatus });
            toast.success(`Produto ${currentStatus ? "desativado" : "ativado"} com sucesso!`);
        } catch (error) {
            console.error(error);
            toast.error("Erro ao atualizar status.");
            fetchProdutos(); // Rollback em caso de erro
        }
    };

    if (loading) {
        return (
            <div className="flex h-full items-center justify-center">
                <Loader2 className="h-8 w-8 animate-spin text-primary" />
            </div>
        );
    }

    return (
        <div className="space-y-6">
            <div className="flex items-center justify-between">
                <div>
                    <h1 className="text-2xl font-bold">Gerenciar Cardápio</h1>
                    <p className="text-sm text-gray-500">Adicione, edite ou remova itens do seu menu.</p>
                </div>
                <Button onClick={handleOpenCreate}>
                    <Plus className="mr-2 h-4 w-4" />
                    Novo Produto
                </Button>
            </div>

            <div className="rounded-md border bg-white shadow-sm">
                <Table>
                    <TableHeader>
                        <TableRow>
                            <TableHead className="w-[400px]">Produto</TableHead>
                            <TableHead>Categoria</TableHead>
                            <TableHead>Preço</TableHead>
                            <TableHead>Status</TableHead>
                            <TableHead className="text-right">Ações</TableHead>
                        </TableRow>
                    </TableHeader>
                    <TableBody>
                        {produtos.map((produto) => (
                            <TableRow key={produto._id}>
                                <TableCell>
                                    <div className="flex items-center gap-3">
                                        <div className="h-10 w-10 rounded-md bg-gray-100 overflow-hidden flex-shrink-0">
                                            {produto.imagem_url ? (
                                                <img 
                                                    src={produto.imagem_url} 
                                                    alt="" 
                                                    className="h-full w-full object-cover"
                                                    onError={(e) => (e.currentTarget.style.display = 'none')}
                                                />
                                            ) : (
                                                <ImageIcon className="h-full w-full p-2 text-gray-300" />
                                            )}
                                        </div>
                                        <div>
                                            <p className="font-medium">{produto.nome}</p>
                                            <p className="text-xs text-gray-500 line-clamp-1 max-w-[250px]">
                                                {produto.descricao}
                                            </p>
                                        </div>
                                    </div>
                                </TableCell>
                                <TableCell>
                                    <Badge variant="secondary">{produto.categoria}</Badge>
                                </TableCell>
                                <TableCell className="font-medium">
                                    {formatPrice(produto.preco_centavos)}
                                </TableCell>
                                <TableCell>
                                    <Badge variant={produto.ativo ? "default" : "destructive"}>
                                        {produto.ativo ? "Ativo" : "Inativo"}
                                    </Badge>
                                </TableCell>
                                <TableCell className="text-right">
                                    <div className="flex justify-end gap-2">
                                        <Button 
                                            variant="ghost" 
                                            size="icon" 
                                            onClick={() => handleOpenEdit(produto)}
                                            title="Editar"
                                        >
                                            <Edit className="h-4 w-4" />
                                        </Button>
                                        
                                        <Button 
                                            variant="ghost" 
                                            size="icon"
                                            className={produto.ativo ? "text-orange-500 hover:text-orange-600" : "text-green-500 hover:text-green-600"}
                                            onClick={() => toggleStatus(produto._id, produto.ativo)}
                                            title={produto.ativo ? "Desativar" : "Ativar"}
                                        >
                                            {produto.ativo ? <PowerOff className="h-4 w-4" /> : <Power className="h-4 w-4" />}
                                        </Button>

                                        <Button 
                                            variant="ghost" 
                                            size="icon"
                                            className="text-red-500 hover:text-red-700 hover:bg-red-50"
                                            onClick={() => handleDelete(produto._id)}
                                            title="Excluir"
                                        >
                                            <Trash2 className="h-4 w-4" />
                                        </Button>
                                    </div>
                                </TableCell>
                            </TableRow>
                        ))}
                    </TableBody>
                </Table>

                {produtos.length === 0 && (
                    <div className="p-8 text-center text-gray-500">
                        Nenhum produto cadastrado. Clique em "Novo Produto" para começar.
                    </div>
                )}
            </div>

            {/* Modal de Formulário (Dialog) */}
            <Dialog open={isDialogOpen} onOpenChange={setIsDialogOpen}>
                <DialogContent>
                    <DialogHeader>
                        <DialogTitle>{editingProduct ? "Editar Produto" : "Novo Produto"}</DialogTitle>
                        <DialogDescription>
                            Preencha os detalhes abaixo para {editingProduct ? "atualizar" : "criar"} um item do cardápio.
                        </DialogDescription>
                    </DialogHeader>

                    <form onSubmit={handleSave} className="space-y-4 py-4">
                        <div className="grid grid-cols-2 gap-4">
                            <div className="space-y-2">
                                <Label htmlFor="nome">Nome do Produto</Label>
                                <Input 
                                    id="nome" 
                                    value={formData.nome}
                                    onChange={(e) => setFormData({...formData, nome: e.target.value})}
                                    placeholder="Ex: Marmita Executiva"
                                    required 
                                />
                            </div>
                            <div className="space-y-2">
                                <Label htmlFor="preco">Preço (R$)</Label>
                                <Input 
                                    id="preco" 
                                    type="number"
                                    step="0.01"
                                    min="0"
                                    placeholder="0.00"
                                    value={priceInput}
                                    onChange={(e) => setPriceInput(e.target.value)}
                                    required 
                                />
                            </div>
                        </div>

                        <div className="space-y-2">
                            <Label htmlFor="descricao">Descrição</Label>
                            <Input 
                                id="descricao" 
                                value={formData.descricao}
                                onChange={(e) => setFormData({...formData, descricao: e.target.value})}
                                placeholder="Ex: Arroz, feijão, bife acebolado e fritas..."
                            />
                        </div>

                        <div className="grid grid-cols-2 gap-4">
                            <div className="space-y-2">
                                <Label htmlFor="categoria">Categoria</Label>
                                <select 
                                    id="categoria"
                                    className="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring disabled:cursor-not-allowed disabled:opacity-50"
                                    value={formData.categoria}
                                    onChange={(e) => setFormData({...formData, categoria: e.target.value as CategoriaProduto})}
                                >
                                    {categories.map(cat => <option key={cat} value={cat}>{cat}</option>)}
                                </select>
                            </div>
                            <div className="space-y-2">
                                <Label htmlFor="tipo">Tipo</Label>
                                <select 
                                    id="tipo"
                                    className="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring disabled:cursor-not-allowed disabled:opacity-50"
                                    value={formData.tipo}
                                    onChange={(e) => setFormData({...formData, tipo: e.target.value as TipoProduto})}
                                >
                                    {types.map(t => <option key={t} value={t}>{t}</option>)}
                                </select>
                            </div>
                        </div>

                        <div className="space-y-2">
                            <Label htmlFor="imagem">URL da Imagem</Label>
                            <Input 
                                id="imagem" 
                                placeholder="https://exemplo.com/imagem.jpg"
                                value={formData.imagem_url}
                                onChange={(e) => setFormData({...formData, imagem_url: e.target.value})}
                            />
                            {formData.imagem_url && (
                                <div className="mt-2 h-40 w-full rounded-md bg-gray-50 overflow-hidden border flex items-center justify-center">
                                    <img 
                                        src={formData.imagem_url} 
                                        alt="Preview" 
                                        className="h-full w-full object-contain"
                                        onError={(e) => (e.currentTarget.style.display = 'none')}
                                    />
                                </div>
                            )}
                        </div>

                        <DialogFooter>
                            <Button type="button" variant="outline" onClick={() => setIsDialogOpen(false)}>Cancelar</Button>
                            <Button type="submit" disabled={isSaving}>
                                {isSaving && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
                                Salvar Produto
                            </Button>
                        </DialogFooter>
                    </form>
                </DialogContent>
            </Dialog>
        </div>
    );
}
