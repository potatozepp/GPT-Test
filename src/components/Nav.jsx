import React from 'react';

export default function Nav({ currentPage, onNavigate }) {
  return (
    <nav>
      <div className="nav-wrapper purple">
        <a href="#" className="brand-logo" onClick={() => onNavigate('home')}>Demo</a>
        <ul id="nav-mobile" className="right hide-on-med-and-down">
          <li className={currentPage === 'home' ? 'active' : ''}>
            <a href="#" onClick={() => onNavigate('home')}>Home</a>
          </li>
          <li className={currentPage === 'about' ? 'active' : ''}>
            <a href="#" onClick={() => onNavigate('about')}>About</a>
          </li>
          <li className={currentPage === 'contact' ? 'active' : ''}>
            <a href="#" onClick={() => onNavigate('contact')}>Contact</a>
          </li>
        </ul>
      </div>
    </nav>
  );
}
