export function About() {
  return (
    <div className="flex flex-col items-center justify-center flex-1 p-6 bg-gray-50">
      <div className="max-w-3xl bg-white shadow-lg rounded-2xl p-8 border border-gray-100">
        
        {/* Título Principal */}
        <h1 className="text-4xl font-bold mb-6 text-red-600 text-center">
          Sobre a Coração de Mãe
        </h1>

        {/* Bloco: Quem somos */}
        <div className="mb-6 space-y-4 text-gray-700 text-lg leading-relaxed">
          <p>
            Localizada em <strong>Ribeirão Preto</strong>, a <strong>Coração de Mãe Alimentos</strong> nasceu 
            para servir quem não abre mão de um almoço caseiro, consistente e, acima de tudo, seguro. 
            Somos especialistas no preparo de refeições <strong>100% livres de glúten e sem leite</strong>.
          </p>
          
          <p>
            Sabemos que para muitos de nossos clientes, a segurança alimentar não é apenas uma preferência, 
            é uma necessidade. Por isso, nossa cozinha é dedicada a evitar contaminações, garantindo tranquilidade 
            em cada garfada.
          </p>
        </div>

        {/* Bloco: A Evolução (O App) */}
        <div className="bg-red-50 p-6 rounded-xl border-l-4 border-red-500 mb-6">
          <h2 className="text-xl font-semibold text-red-700 mb-2">
            Por que criamos este Cardápio Digital?
          </h2>
          <p className="text-gray-700">
            Para melhorar sua experiência! Antigamente, nossos pedidos via mensagens podiam gerar dúvidas 
            sobre ingredientes ou disponibilidade. Com nosso novo aplicativo, você tem clareza total sobre 
            o que está pedindo.
          </p>
        </div>

        {/* Bloco: Como funciona hoje */}
        <div className="space-y-4 text-gray-700 text-lg leading-relaxed">
          <p>
            Agora você pode montar sua marmita (nos tamanhos <strong>P, M ou G</strong>) com facilidade, 
            conferir os preços em tempo real e acompanhar o status do seu pedido, desde o preparo até a entrega.
          </p>
          <p className="font-medium text-center mt-8">
            Horário de funcionamento: 11h30 às 13h30. <br/>
            <span className="text-red-600">Peça agora e sinta o sabor de casa com segurança total.</span>
          </p>
        </div>

      </div>
    </div>
  );
}