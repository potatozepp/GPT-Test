import React, { useState } from 'react';

export default function Converter() {
  const [url, setUrl] = useState('');
  const [status, setStatus] = useState('');

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!url) return;
    setStatus('Converting...');
    try {
      // This would normally call a backend service to perform the conversion.
      await new Promise((r) => setTimeout(r, 1000));
      setStatus('Conversion complete!');
    } catch (err) {
      setStatus('Conversion failed');
    }
  };

  return (
    <div className="container">
      <h3>YouTube to MP3</h3>
      <form onSubmit={handleSubmit}>
        <div className="input-field">
          <input
            type="url"
            placeholder="YouTube URL"
            value={url}
            onChange={(e) => setUrl(e.target.value)}
            required
          />
        </div>
        <button className="btn purple" type="submit">Convert</button>
      </form>
      {status && <p>{status}</p>}
    </div>
  );
}
