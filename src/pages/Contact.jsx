import React, { useState } from 'react';

export default function Contact() {
  const [submitted, setSubmitted] = useState(false);

  const handleSubmit = (e) => {
    e.preventDefault();
    setSubmitted(true);
  };

  return (
    <div className="container">
      <h3>Contact Us</h3>
      {submitted ? (
        <p>Thanks for reaching out! We'll be in touch.</p>
      ) : (
        <form onSubmit={handleSubmit}>
          <div className="input-field">
            <input id="name" type="text" required />
            <label htmlFor="name">Name</label>
          </div>
          <div className="input-field">
            <input id="email" type="email" required />
            <label htmlFor="email">Email</label>
          </div>
          <div className="input-field">
            <textarea id="message" className="materialize-textarea" required></textarea>
            <label htmlFor="message">Message</label>
          </div>
          <button className="btn waves-effect waves-light" type="submit">Send</button>
        </form>
      )}
    </div>
  );
}
