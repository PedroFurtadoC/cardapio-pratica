interface ScrollAreaProps extends React.HTMLAttributes<HTMLDivElement> {
	children: React.ReactNode;
}

export function ScrollArea({ className = "", children, ...props }: ScrollAreaProps) {
	return (
		<div
			className={`relative overflow-hidden ${className}`}
			{...props}
		>
			<div className="h-full w-full overflow-y-auto pr-2 scrollbar-thin scrollbar-thumb-gray-300 scrollbar-track-transparent">
				{children}
			</div>
		</div>
	);
}
