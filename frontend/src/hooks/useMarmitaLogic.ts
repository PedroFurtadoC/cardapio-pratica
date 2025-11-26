import { Componente, Produto } from '@/types';
import { useMemo, useState } from 'react';

interface SelectionState {
    [componentId: string]: number; // quantity
}

export function useMarmitaLogic(produto: Produto, componentesDisponiveis: Componente[]) {
    const [selections, setSelections] = useState<SelectionState>({});

    // Filtrar componentes por tipo
    const bases = useMemo(() => componentesDisponiveis.filter(c => c.tipo === 'BASE'), [componentesDisponiveis]);
    const proteinas = useMemo(() => componentesDisponiveis.filter(c => c.tipo === 'PROTEINA'), [componentesDisponiveis]);

    // Guarnições Quentes (ocupam espaço)
    const guarnicoesQuentes = useMemo(() =>
        componentesDisponiveis.filter(c => c.tipo === 'GUARNICAO' && !c.embalagem_separada),
        [componentesDisponiveis]);

    // Saladas/Extras (embalagem separada - não ocupam espaço da marmita)
    const saladasExtras = useMemo(() =>
        componentesDisponiveis.filter(c => c.tipo === 'GUARNICAO' && c.embalagem_separada),
        [componentesDisponiveis]);

    // Contagem atual
    const getCountByType = (tipo: 'BASE' | 'PROTEINA' | 'GUARNICAO_QUENTE') => {
        let count = 0;
        Object.entries(selections).forEach(([id, qty]) => {
            const comp = componentesDisponiveis.find(c => c._id === id);
            if (!comp) return;

            if (tipo === 'BASE' && comp.tipo === 'BASE') count += qty;
            if (tipo === 'PROTEINA' && comp.tipo === 'PROTEINA') count += qty;
            if (tipo === 'GUARNICAO_QUENTE' && comp.tipo === 'GUARNICAO' && !comp.embalagem_separada) count += qty;
        });
        return count;
    };

    const counts = {
        base: getCountByType('BASE'),
        proteina: getCountByType('PROTEINA'),
        guarnicao: getCountByType('GUARNICAO_QUENTE'),
    };

    const limits = produto.regras_composicao || { max_base: 0, max_proteina: 0, max_guarnicao: 0 };

    const canIncrement = (componente: Componente) => {
        if (componente.tipo === 'BASE') return counts.base < limits.max_base;
        if (componente.tipo === 'PROTEINA') return counts.proteina < limits.max_proteina;
        if (componente.tipo === 'GUARNICAO') {
            if (componente.embalagem_separada) return true; // Sem limite definido no prompt para saladas, assumindo livre ou limite à parte (vou deixar livre por enquanto)
            return counts.guarnicao < limits.max_guarnicao;
        }
        return false;
    };

    const toggleSelection = (componente: Componente) => {
        const currentQty = selections[componente._id] || 0;

        if (currentQty > 0) {
            // Remove
            const newSelections = { ...selections };
            delete newSelections[componente._id];
            setSelections(newSelections);
        } else {
            // Add (if allowed)
            if (canIncrement(componente)) {
                setSelections({ ...selections, [componente._id]: 1 });
            }
        }
    };

    // Preço Total
    const totalPrice = useMemo(() => {
        let total = produto.preco_centavos;
        Object.entries(selections).forEach(([id, qty]) => {
            const comp = componentesDisponiveis.find(c => c._id === id);
            if (comp && comp.preco_adicional_centavos > 0) {
                total += comp.preco_adicional_centavos * qty;
            }
        });
        return total;
    }, [produto.preco_centavos, selections, componentesDisponiveis]);

    // Validação Final
    const isValid =
        counts.base > 0 && // Pelo menos 1 base? (Assumindo obrigatório)
        counts.proteina > 0 && // Pelo menos 1 proteina?
        counts.guarnicao <= limits.max_guarnicao; // Não exceder (já garantido pelo canIncrement, mas bom checar)
    // Nota: O prompt diz "requisitos mínimos". Vou assumir que precisa preencher pelo menos 1 de cada tipo principal se o limite > 0.

    return {
        selections,
        toggleSelection,
        counts,
        limits,
        totalPrice,
        isValid,
        groups: {
            bases,
            proteinas,
            guarnicoesQuentes,
            saladasExtras
        }
    };
}
