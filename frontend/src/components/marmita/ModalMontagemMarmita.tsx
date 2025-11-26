import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Dialog } from "@/components/ui/dialog";
import { useMarmitaLogic } from "@/hooks/useMarmitaLogic";
import { formatPrice } from "@/lib/utils";
import { Componente, Produto } from "@/types";
import { Check, ChevronLeft, ChevronRight, Info } from "lucide-react";
import { useState } from "react";

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
            onClose();
        }
    };

    const renderStepContent = () => {
        switch (step) {
            case 1:
                return (
                    <StepSection
                        title="Escolha sua Base"
                        subtitle={`Selecione até ${limits.max_base} opção(ões)`}
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
                        title="Escolha sua Proteína"
                        subtitle={`Selecione até ${limits.max_proteina} opção(ões)`}
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
                        title="Guarnições Quentes"
                        subtitle={`Selecione até ${limits.max_guarnicao} opção(ões)`}
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
                        <div className="rounded-lg border border-green-200 bg-green-50 p-4 text-green-800">
                            <div className="flex items-center gap-2 font-semibold">
                                <Info className="h-5 w-5" />
                                Embalagem Separada
                            </div>
                            <p className="mt-1 text-sm">
                                Estes itens vão em potes separados e <strong>não ocupam espaço</strong> na sua marmita. Aproveite para complementar seu pedido!
                            </p>
                        </div>
                        <StepSection
                            title="Saladas e Extras"
                            subtitle="Selecione quantos quiser"
                            items={groups.saladasExtras}
                            selections={selections}
                            onToggle={toggleSelection}
                            max={99} // Livre
                            current={0} // Não usa contador global
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
            <div className="flex flex-col h-[60vh]">
                {/* Progress Bar */}
                <div className="mb-4 flex gap-2">
                    {[1, 2, 3, 4].map((s) => (
                        <div
                            key={s}
                            className={`h-2 flex-1 rounded-full transition-colors ${s <= step ? "bg-primary" : "bg-muted"
                                }`}
                        />
                    ))}
                </div>

                {/* Content */}
                <div className="flex-1 overflow-y-auto pr-2">
                    {renderStepContent()}
                </div>

                {/* Footer */}
                <div className="mt-4 border-t pt-4">
                    <div className="mb-4 flex items-center justify-between">
                        <span className="text-sm text-muted-foreground">Total do Item:</span>
                        <span className="text-xl font-bold text-primary">
                            {formatPrice(totalPrice)}
                        </span>
                    </div>
                    <div className="flex gap-2">
                        {step > 1 && (
                            <Button variant="outline" onClick={handleBack} className="flex-1">
                                <ChevronLeft className="mr-2 h-4 w-4" />
                                Voltar
                            </Button>
                        )}
                        {step < totalSteps ? (
                            <Button onClick={handleNext} className="flex-1">
                                Próximo
                                <ChevronRight className="ml-2 h-4 w-4" />
                            </Button>
                        ) : (
                            <Button
                                onClick={handleFinish}
                                className="flex-1"
                                disabled={!isValid}
                            >
                                Adicionar ao Pedido
                                <Check className="ml-2 h-4 w-4" />
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
            <div>
                <h3 className="text-lg font-medium">{title}</h3>
                <p className="text-sm text-muted-foreground flex items-center gap-2">
                    {subtitle}
                    {!isExtra && (
                        <Badge variant={current === max ? "default" : "secondary"} className="ml-auto">
                            {current}/{max}
                        </Badge>
                    )}
                </p>
            </div>

            <div className="grid gap-3">
                {items.map((item) => {
                    const isSelected = (selections[item._id] || 0) > 0;
                    const isDisabled = !isSelected && !isExtra && current >= max;

                    return (
                        <div
                            key={item._id}
                            className={`relative flex cursor-pointer items-center justify-between rounded-lg border p-4 transition-all hover:bg-accent ${isSelected ? "border-primary bg-primary/5 ring-1 ring-primary" : "bg-card"
                                } ${isDisabled ? "opacity-50 cursor-not-allowed" : ""}`}
                            onClick={() => !isDisabled && onToggle(item)}
                        >
                            <div className="flex flex-col">
                                <span className="font-medium">{item.nome}</span>
                                {item.preco_adicional_centavos > 0 && (
                                    <span className="text-xs text-muted-foreground">
                                        + {formatPrice(item.preco_adicional_centavos)}
                                    </span>
                                )}
                            </div>
                            {isSelected && (
                                <div className="flex h-6 w-6 items-center justify-center rounded-full bg-primary text-primary-foreground">
                                    <Check className="h-4 w-4" />
                                </div>
                            )}
                        </div>
                    );
                })}
            </div>

            {items.length === 0 && (
                <div className="py-8 text-center text-muted-foreground bg-muted/20 rounded-lg border border-dashed">
                    <Info className="mx-auto h-8 w-8 mb-2 opacity-50" />
                    <p>Nenhuma opção disponível nesta categoria.</p>
                </div>
            )}
        </div>
    );
}
