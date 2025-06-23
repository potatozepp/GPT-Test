const express = require('express');
const ytdl = require('ytdl-core');
const ffmpeg = require('fluent-ffmpeg');

const app = express();
const PORT = process.env.PORT || 3001;

app.get('/api/convert', async (req, res) => {
  const videoUrl = req.query.url;
  if (!videoUrl || !ytdl.validateURL(videoUrl)) {
    return res.status(400).json({ error: 'Invalid URL' });
  }

  try {
    const info = await ytdl.getInfo(videoUrl);
    const title = info.videoDetails.title.replace(/[^a-z0-9]/gi, '_').toLowerCase();

    res.setHeader('Content-Disposition', `attachment; filename="${title}.mp3"`);
    res.setHeader('Content-Type', 'audio/mpeg');

    const stream = ytdl(videoUrl, { quality: 'highestaudio' });
    ffmpeg(stream)
      .audioBitrate(128)
      .format('mp3')
      .on('error', (err) => {
        console.error('ffmpeg error:', err.stack || err);
        res.status(500).end();
      })
      .pipe(res, { end: true });
  } catch (err) {
    console.error('conversion error:', err.stack || err);
    const message = err && err.message ? err.message : '';
    if (message.includes('Could not extract functions')) {
      return res.status(502).json({
        error:
          'Failed to retrieve video details. The YouTube page layout may have changed or ytdl-core is outdated.'
      });
    }
    res.status(500).json({ error: 'Conversion failed' });
  }
});

if (require.main === module) {
  app.listen(PORT, () => {
    console.log(`Server listening on port ${PORT}`);
  });
}

module.exports = app;
