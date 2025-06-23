import React from 'react';
import './App.scss';

export default function App() {
  return (
    <>
      <header className="hero"></header>
      <div className="container">
        <div className="row image-text">
          <div className="col s12 m6">
            <img src="https://picsum.photos/500/300" alt="Example" />
          </div>
          <div className="col s12 m6">
            <h5>Example Section</h5>
            <p>This is an example image with accompanying text. Replace the image and text with your own content.</p>
          </div>
        </div>
        <div className="row">
          <div className="col s12">
            <h4 className="center-align">Customer Reviews</h4>
          </div>
          <div className="col s12 m4">
            <div className="card">
              <div className="card-content">
                <span className="card-title">Jane</span>
                <p>Great service and fantastic quality!</p>
              </div>
            </div>
          </div>
          <div className="col s12 m4">
            <div className="card">
              <div className="card-content">
                <span className="card-title">John</span>
                <p>A wonderful experience from start to finish.</p>
              </div>
            </div>
          </div>
          <div className="col s12 m4">
            <div className="card">
              <div className="card-content">
                <span className="card-title">Alex</span>
                <p>I would definitely recommend this to my friends.</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </>
  );
}
