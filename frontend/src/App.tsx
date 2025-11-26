import { Header } from "@/components/layout/Header";
import { Home } from "@/pages/Home";
import { Route, BrowserRouter as Router, Routes } from "react-router-dom";

function App() {
    return (
        <Router>
            <div className="flex min-h-screen flex-col">
                <Header />
                <Routes>
                    <Route path="/" element={<Home />} />
                    <Route path="/sobre" element={<div className="p-20 text-center">Sobre Nós (Em breve)</div>} />
                </Routes>
            </div>
        </Router>
    );
}

export default App;
