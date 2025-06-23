import React, { useState } from 'react';

export default function Converter() {
  const [url, setUrl] = useState('');
  const [status, setStatus] = useState('');

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!url) return;
    setStatus('Converting...');
    try {
      const response = await fetch(`/api/convert?url=${encodeURIComponent(url)}`);
      if (!response.ok) throw new Error('Failed');
      const blob = await response.blob();
      const href = window.URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.style.display = 'none';
      a.href = href;
      a.download = 'audio.mp3';
      document.body.appendChild(a);
      a.click();
      document.body.removeChild(a);
      window.URL.revokeObjectURL(href);
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
