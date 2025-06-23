import React, { useState } from 'react';
import './App.scss';
import Home from './pages/Home';
import About from './pages/About';
import Contact from './pages/Contact';
import Nav from './components/Nav';
import Footer from './components/Footer';

export default function App() {
  const [page, setPage] = useState('home');

  const renderPage = () => {
    switch (page) {
      case 'about':
        return <About />;
      case 'contact':
        return <Contact />;
      default:
        return <Home />;
    }
  };

  return (
    <>
      <Nav currentPage={page} onNavigate={setPage} />
      {renderPage()}
      <Footer />
    </>
  );
}
