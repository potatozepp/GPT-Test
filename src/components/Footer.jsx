import React from 'react';

export default function Footer() {
  return (
    <footer className="page-footer blue darken-2">
      <div className="container">
        <div className="row">
          <div className="col s12 center-align">
            <h5 className="white-text">Demo App</h5>
            <p className="grey-text text-lighten-4">
              Making cool pages with React and Materialize.
            </p>
          </div>
        </div>
      </div>
      <div className="footer-copyright">
        <div className="container center-align">
          © 2024 Demo Inc.
        </div>
      </div>
    </footer>
  );
}
