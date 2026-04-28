import fs from 'node:fs'
import path from 'node:path'
import { fileURLToPath } from 'node:url'
import { defineConfig } from 'vite'
import react, { reactCompilerPreset } from '@vitejs/plugin-react'
import babel from '@rolldown/plugin-babel'
import { VitePWA } from 'vite-plugin-pwa'

const __dirname = path.dirname(fileURLToPath(import.meta.url))
const repoExamsDir = path.resolve(__dirname, '../assets/json/exams')

/** dev/preview: /assets/json/exams/*.json → repo `assets/json/exams` (모의고사 출제) */
function serveRepoExamsPlugin() {
  const middleware = (
    req: { url?: string },
    res: {
      setHeader: (n: string, v: string) => void
      statusCode?: number
      end: (s?: string) => void
    },
    next: () => void
  ) => {
    const raw = req.url?.split('?')[0] ?? ''
    if (!raw.startsWith('/assets/json/exams/')) {
      next()
      return
    }
    const base = path.basename(raw)
    if (!/^(bread|pastry)_\d{8}\.json$/i.test(base)) {
      next()
      return
    }
    const full = path.join(repoExamsDir, base)
    if (!full.startsWith(repoExamsDir) || !fs.existsSync(full)) {
      res.statusCode = 404
      res.end()
      return
    }
    const body = fs.readFileSync(full, 'utf8')
    res.setHeader('Content-Type', 'application/json; charset=utf-8')
    res.end(body)
  }
  return {
    name: 'serve-repo-exams',
    configureServer(server: import('vite').ViteDevServer) {
      server.middlewares.use(middleware)
    },
    configurePreviewServer(server: import('vite').PreviewServer) {
      server.middlewares.use(middleware)
    },
  }
}

// https://vite.dev/config/
export default defineConfig({
  plugins: [
    serveRepoExamsPlugin(),
    react(),
    babel({ presets: [reactCompilerPreset()] }),
    VitePWA({
      registerType: 'autoUpdate',
      includeAssets: ['favicon.svg', 'icons.svg'],
      manifest: {
        name: '광고없는제과제빵필기기출회독',
        short_name: '광고없는제과제빵필기기출회독',
        description: '광고없는제과제빵필기기출회독',
        theme_color: '#222222',
        background_color: '#ffffff',
        display: 'standalone',
        start_url: '/',
        scope: '/',
        icons: [
          {
            src: '/favicon.svg',
            sizes: 'any',
            type: 'image/svg+xml',
            purpose: 'any',
          },
        ],
      },
    }),
  ],
})
