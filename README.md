# Daily Toolkit

This project has evolved into a small React application that provides a collection
of everyday utilities. It is built with [Vite](https://vitejs.dev/) and styled
using SCSS. One of the included tools is a simple YouTube to MP3 converter page
where you can submit a video URL and download the audio.

## Getting Started

1. Install dependencies (requires internet access):
   ```bash
   npm install
   ```
2. Start the development server:
   ```bash
   npm run dev
   ```
3. Open `http://localhost:5173` in your browser.

## Building for Production

To create a production build:
```bash
npm run build
```
The build output will be in the `dist` directory.

## Project Structure

- `index.html` – Entry HTML loaded by Vite
- `src/App.jsx` – Main React component
- `src/App.scss` – Styles for the app (SCSS)
- `src/main.jsx` – Application entry point
- `vite.config.js` – Vite configuration

Replace the placeholder images in `App.jsx` with your own content to personalize the page.
