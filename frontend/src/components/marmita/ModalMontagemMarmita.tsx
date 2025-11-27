import { Badge } from '../ui/badge';
import { Button } from "../ui/button";
import { Dialog } from "../ui/dialog";
import { useMarmitaLogic } from "../../hooks/useMarmitaLogic";
import { formatPrice } from "../../lib/utils";
import { Componente, Produto } from "../../types";
import { Check, ChevronLeft, ChevronRight, Info } from "lucide-react";
import { useState } from "react";
import { ScrollArea } from "../ui/ScrollArea";

interface ModalMontagemMarmitaProps {
    isOpen: boolean;
    onClose: () => void;
    produto: Produto;
    componentes: Componente[];
    onAddToCart: (item: { produto: Produto; selections?: { [key: string]: number }; totalPrice: number }) => void;
}

export function ModalMontagemMarmita({
    isOpen,
    onClose,
    produto,
    componentes,
    onAddToCart,
}: ModalMontagemMarmitaProps) {
    const { selections, toggleSelection, counts, limits, totalPrice, isValid, groups } = useMarmitaLogic(
        produto,
        componentes
    );

    const [step, setStep] = useState(1);
    const totalSteps = 4;

    const handleNext = () => {
        if (step < totalSteps) setStep(step + 1);
    };

    const handleBack = () => {
        if (step > 1) setStep(step - 1);
    };

    const handleFinish = () => {
        if (isValid) {
            onAddToCart({
                produto,
                selections,
                totalPrice,
            });
            setStep(1); 
            onClose();
        }
    };

    const renderStepContent = () => {
        switch (step) {
            case 1:
                return (
                    <StepSection
                        title="Escolha a Base"
                        subtitle={`Selecione até ${limits.max_base} opções`}
                        items={groups.bases}
                        selections={selections}
                        onToggle={toggleSelection}
                        max={limits.max_base}
                        current={counts.base}
                    />
                );
            case 2:
                return (
                    <StepSection
                        title="Proteína"
                        subtitle={`Escolha ${limits.max_proteina} opções deliciosas`}
                        items={groups.proteinas}
                        selections={selections}
                        onToggle={toggleSelection}
                        max={limits.max_proteina}
                        current={counts.proteina}
                    />
                );
            case 3:
                return (
                    <StepSection
                        title="Guarnições"
                        subtitle={`Complete com até ${limits.max_guarnicao} acompanhamentos`}
                        items={groups.guarnicoesQuentes}
                        selections={selections}
                        onToggle={toggleSelection}
                        max={limits.max_guarnicao}
                        current={counts.guarnicao}
                    />
                );
            case 4:
                return (
                    <div className="space-y-4">
                        <div className="bg-blue-50 p-4 rounded-lg flex gap-3 items-start text-blue-800">
                            <Info className="h-5 w-5 mt-0.5 shrink-0" />
                            <div>
                                <h4 className="font-semibold text-sm">Embalagem Separada</h4>
                                <p className="text-xs mt-1 opacity-90">
                                    Estes itens vão em potes separados e não ocupam espaço na sua marmita. Aproveite para complementar seu pedido!
                                </p>
                            </div>
                        </div>

                        <StepSection
                            title="Saladas e Extras"
                            subtitle="Adicionais à parte (Opcional)"
                            items={groups.saladasExtras}
                            selections={selections}
                            onToggle={toggleSelection}
                            max={99} // Sem limite estrito de UI para extras
                            current={0}
                            isExtra={true}
                        />
                    </div>
                );
            default:
                return null;
        }
    };

    return (
        <Dialog 
            open={isOpen} 
            onOpenChange={(open) => !open && onClose()}
            title={`Montar ${produto.nome}`}
            description={produto.descricao}
        >
            <div className="flex flex-col h-[65vh]"> {/* Altura fixa para permitir scroll interno */}
                
                {/* Progress Bar (Inserida manualmente pois o Dialog simples não tem slot de Header customizado) */}
                <div className="flex gap-2 mb-4 shrink-0">
                    {[1, 2, 3, 4].map((s) => (
                        <div 
                            key={s}
                            className={`h-1.5 flex-1 rounded-full transition-colors ${
                                s <= step ? 'bg-primary' : 'bg-gray-100'
                            }`} 
                        />
                    ))}
                </div>

                {/* Content */}
                <ScrollArea className="flex-1 pr-2">
                    {renderStepContent()}
                </ScrollArea>

                {/* Footer */}
                <div className="mt-4 pt-4 border-t flex items-center justify-between shrink-0">
                    <div className="flex flex-col">
                        <span className="text-sm text-gray-500">Total do Item:</span>
                        <span className="font-bold text-xl text-primary">
                            {formatPrice(totalPrice)}
                        </span>
                    </div>

                    <div className="flex gap-2">
                        {step > 1 && (
                            <Button variant="outline" onClick={handleBack}>
                                <ChevronLeft className="mr-2 h-4 w-4" />
                                Voltar
                            </Button>
                        )}
                        {step < totalSteps ? (
                            <Button onClick={handleNext} disabled={!isValid && step === totalSteps}>
                                Próximo
                                <ChevronRight className="ml-2 h-4 w-4" />
                            </Button>
                        ) : (
                            <Button onClick={handleFinish} disabled={!isValid}>
                                <Check className="mr-2 h-4 w-4" />
                                Adicionar ao Pedido
                            </Button>
                        )}
                    </div>
                </div>
            </div>
        </Dialog>
    );
}

interface StepSectionProps {
    title: string;
    subtitle: string;
    items: Componente[];
    selections: { [key: string]: number };
    onToggle: (c: Componente) => void;
    max: number;
    current: number;
    isExtra?: boolean;
}

function StepSection({ title, subtitle, items, selections, onToggle, max, current, isExtra }: StepSectionProps) {
    return (
        <div className="space-y-4">
            <div className="flex items-baseline justify-between">
                <h3 className="font-semibold text-lg">{title}</h3>

                <div className="text-sm text-gray-500">
                    <span className="mr-2">{subtitle}</span>
                    {!isExtra && (
                        <Badge variant={current >= max ? "default" : "outline"}>
                            {current}/{max}
                        </Badge>
                    )}
                </div>
            </div>

            <div className="grid grid-cols-1 gap-3">
                {items.map((item) => {
                    const isSelected = (selections[item._id] || 0) > 0;
                    const isDisabled = !isSelected && !isExtra && current >= max;

                    return (
                        <div
                            key={item._id}
                            className={`
                                relative p-4 rounded-lg border-2 cursor-pointer transition-all hover:shadow-md
                                ${isSelected 
                                    ? 'border-primary bg-primary/5' 
                                    : 'border-gray-100 hover:border-primary/50 bg-white'}
                                ${isDisabled ? 'opacity-50 cursor-not-allowed grayscale' : ''}
                            `}
                            onClick={() => !isDisabled && onToggle(item)}
                        >
                            <div className="flex justify-between items-start">
                                <span className="font-medium text-sm pr-6">{item.nome}</span>
                                {item.preco_adicional_centavos > 0 && (
                                    <Badge variant="secondary" className="text-xs">
                                        + {formatPrice(item.preco_adicional_centavos)}
                                    </Badge>
                                )}
                            </div>


                            {isSelected && (
                                <div className="absolute top-3 right-3 text-primary">
                                    <Check className="h-4 w-4" />
                                </div>
                            )}
                        </div>
                    );
                })}
            </div>


            {items.length === 0 && (
                <div className="text-center py-8 text-gray-400 border-2 border-dashed rounded-lg">
                    <Info className="h-8 w-8 mx-auto mb-2 opacity-50" />
                    Nenhuma opção disponível nesta categoria.
                </div>
            )}
        </div>
    );
}
