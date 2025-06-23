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
2. Start the backend server:
   ```bash
   npm run server
   ```
   This starts an Express service on `http://localhost:3001` that converts
   YouTube videos to MP3 files.
3. In a separate terminal start the development server:
   ```bash
   npm run dev
   ```
4. Open `http://localhost:5173` in your browser.

The backend uses `ffmpeg` for audio conversion. Ensure `ffmpeg` is installed
and available in your `PATH` before running the server.

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
- `server/index.js` – Express backend providing the `/api/convert` endpoint

Replace the placeholder images in `App.jsx` with your own content to personalize the page.
