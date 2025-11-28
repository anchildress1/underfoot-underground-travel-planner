# Underfoot Underground Travel Planner

<p align="center">
  <img src="frontend/public/favicon.png" alt="Underfoot logo" width="140" height="140" />
</p>

> 🦄 Yes — I know\... _another_ project. It can't be helped! I really do plan on finishing them all (at some point). So, since I'm already over-worked and short on time as-is. Here's my 2nd attempt at **vibe coding** with ChatGPT at the wheel and GitHub Copilot playing backup. We'll see how it goes without me going to crazy with the overbearing-OCD. 🤞
>
> P.S. I'll keep notes of how it goes in the [JOURNEY](./docs/planning/JOURNEY.md) file, because... why not?

🧭 Quirky, snarky, _absolutely-not-your-typical_ travel planner for finding the coolest, least obvious spots — the ones the big travel sites forgot.

Underfoot helps you find hidden gems in any given location by digging into local blogs, indie magazines, and offbeat sources. No TripAdvisor Top 10 lists here — we're all about the "Wait, this exists?!" moments.


| Pulse Points | Badges |
| - | - |
| 🫶 Show Some Love | [![dev.to Badge](https://img.shields.io/badge/dev.to-0A0A0A?logo=devdotto&logoColor=fff&style=for-the-badge)](https://dev.to/anchildress1) [![LinkedIn](https://img.shields.io/badge/linkedin-%230077B5.svg?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/anchildress1/) [![BuyMeACoffee](https://img.shields.io/badge/Buy%20Me%20a%20Coffee-ffdd00?style=for-the-badge&logo=buy-me-a-coffee&logoColor=black)](https://www.buymeacoffee.com/anchildress1) |
| 🛼 Recent Activity | ![GitHub commit activity](https://img.shields.io/github/commit-activity/t/checkmarkdevtools/underfoot-underground-travel-planner?style=for-the-badge&color=F054B2&cacheSeconds=3600) ![GitHub last commit](https://img.shields.io/github/last-commit/checkmarkdevtools/underfoot-underground-travel-planner?display_timestamp=author&style=for-the-badge&color=34A853&cacheSeconds=3600)<br/>![GitHub Created At](https://img.shields.io/github/created-at/checkmarkdevtools/underfoot-underground-travel-planner?style=for-the-badge&color=EDC531) [![wakatime](https://wakatime.com/badge/user/ce7cc1c3-1f1a-4f77-ad68-9e3a9caac39b/project/274505a2-d55b-4b16-9479-661b724d63e6.svg?style=for-the-badge)](https://wakatime.com/badge/user/ce7cc1c3-1f1a-4f77-ad68-9e3a9caac39b/project/274505a2-d55b-4b16-9479-661b724d63e6) |
| 📊 At a Glance | [![Project Type Badge](https://img.shields.io/badge/project_type-toy-blue?style=for-the-badge)](https://project-types.github.io/) [![GitHub License](https://img.shields.io/badge/license-Polyform_1.0.0-yellow?style=for-the-badge)](./LICENSE) [![dev.to hackathon entry Badge](https://img.shields.io/badge/dev.to_challenge-RealTime%20AI%20Agents%20-0A0A0A?logo=devdotto&logoColor=fff&style=for-the-badge)](https://dev.to/challenges/brightdata-n8n-2025-08-13) |
| 🧩 The Non-Negotiable | [![Volta Badge](https://img.shields.io/badge/Volta-3377CC.svg?style=for-the-badge)](https://volta.sh) [![NPM](https://img.shields.io/badge/NPM-%23CB3837.svg?style=for-the-badge&logo=npm&logoColor=white)](https://www.npmjs.com/) [![Node.js Badge](https://img.shields.io/badge/Node.js-5FA04E?logo=nodedotjs&logoColor=fff&style=for-the-badge)](https://nodejs.org/)<br/>[![JavaScript Badge](https://img.shields.io/badge/JavaScript-F7DF1E?logo=javascript&logoColor=000&style=for-the-badge)](https://developer.mozilla.org/en-US/docs/Web/JavaScript) [![Markdown Badge](https://img.shields.io/badge/Markdown-000?logo=markdown&logoColor=fff&style=for-the-badge)](https://www.markdownguide.org) |
| 🔧 Nerd Tools I Can't Live Without<br/>- Dependencies | [![Conventional Commits Badge](https://img.shields.io/badge/Conventional%20Commits-FE5196?logo=conventionalcommits&logoColor=fff&style=for-the-badge)](https://conventionalcommits.org/) [![commitlint Badge](https://img.shields.io/badge/commitlint-000?logo=commitlint&logoColor=fff&style=for-the-badge)](https://commitlint.js.org/) <br /> |
| 👾 Bots in the Basement | [![GitHub Copilot Badge](https://img.shields.io/badge/GitHub%20Copilot-000?logo=githubcopilot&logoColor=fff&style=for-the-badge)](https://github.com/features/copilot) [![OpenAI Badge](https://img.shields.io/badge/OpenAI-412991?logo=openai&logoColor=fff&style=for-the-badge)](https://openai.com/chatgpt) [![Verdent AI Badge](https://img.shields.io/badge/Verdent-00D486?logo=data:image/svg%2bxml;base64,PHN2ZyByb2xlPSJpbWciIHZpZXdCb3g9IjAgMCAzMiAzMiIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj48dGl0bGU+VmVyZGVudDwvdGl0bGU+CjxwYXRoIGQ9Ik0xNy42IDkuOUMxNy42IDEyLjEgMTYuOCAxNC4yIDE1LjQgMTUuN0wxNS4xIDE2QzEzLjcgMTcuNSAxMi44IDE5LjYgMTIuOCAyMS44QzEyLjggMjIuNSAxMi45IDIzLjIgMTMuMSAyMy45QzEwLjcgMjIuOSA4LjggMjAuOSA4IDE4LjRDNy44IDE3LjYgNy43IDE2LjggNy43IDE2QzcuNyAxMy44IDguNSAxMS44IDkuOCAxMC4zTDE1LjMgNEMxNi4yIDUgMTYuOSA2LjEgMTcuMyA3LjVDMTcuNSA4LjIgMTcuNiA5IDE3LjYgOS45WiIgZmlsbD0iI2ZmZmZmZiIvPgo8cGF0aCBkPSJNMTQuMyAyMi43QzE0LjMgMjAuNSAxNS4xIDE4LjQgMTYuNSAxNi45TDE2LjggMTYuNkMxOC4yIDE1LjEgMTkuMSAxMyAxOS4xIDEwLjhDMTkuMSAxMCAxOSA5LjQgMTguOCA4LjdDMjEuMiA5LjcgMjMuMSAxMS43IDIzLjkgMTQuMkMyNCAxNSAyNC4yIDE1LjggMjQuMiAxNi42QzI0LjIgMTguOCAyMy40IDIwLjggMjIuMSAyMi4zTDE2LjYgMjguNkMxNS43IDI3LjYgMTUgMjYuNSAxNC42IDI1LjFDMTQuNCAyNC4zIDE0LjMgMjMuNSAxNC4zIDIyLjdaIiBmaWxsPSIjZmZmZmZmIi8+Cjwvc3ZnPg==&style=for-the-badge)](https://verdent.ai/) |
| 💬 Meta Magic & Shiny Things | [![Git](https://img.shields.io/badge/git-%23F05033.svg?style=for-the-badge&logo=git&logoColor=white)](https://git-scm.com/) [![GitHub](https://img.shields.io/badge/github-%23121011.svg?style=for-the-badge&logo=github&logoColor=white)](https://github.com/) [![gitignore.io Badge](https://img.shields.io/badge/gitignore.io-204ECF?logo=gitignoredotio&logoColor=fff&style=for-the-badge)](https://www.toptal.com/developers/gitignore/api/node,dotenv,visualstudiocode,macos) [![VS Code Insiders](https://img.shields.io/badge/VS%20Code%20Insiders-35b393.svg?style=for-the-badge&logo=visual-studio-code&logoColor=white)](https://code.visualstudio.com/updates/v1_102) [![macOS](https://img.shields.io/badge/mac%20os-000000?style=for-the-badge&logo=macos&logoColor=F0F0F0)](https://www.apple.com/shop/buy-mac?afid=p240%7Cgo~cmp-21640797485~adg-171722772185~ad-756023446016_kwd-978205588~dev-c~ext-~prd-~mca-~nt-search&cid=aos-us-kwgo-mac-bts-launch-061725-)<br/>[![Shields.io Badge](https://img.shields.io/badge/Shields.io-000?logo=shieldsdotio&logoColor=fff&style=for-the-badge)](https://shields.io/badges/static-badge) ![Simple Icons Badge](https://img.shields.io/badge/Simple%20Icons-111?logo=simpleicons&logoColor=fff&style=for-the-badge) |

---

## Environment Setup

**Quick Start:**

1. **Frontend** (`/frontend/.env`)

   ```bash
   cp frontend/.env.example frontend/.env
   # Add: VITE_GOOGLE_MAPS_API_KEY=your_key
   # Add: VITE_API_BASE=http://localhost:8000
   ```

2. **Backend** (`/backend/.env`)

   ```bash
   cp backend/.env.example backend/.env
   # Configure API keys as needed
   ```

---

## Getting Started

### Frontend

```bash
cd frontend
npm install
npm run dev
```

### Backend

```bash
cd backend
poetry install
poetry run uvicorn src.workers.chat_worker:app --reload
```

### Both (from root)

```bash
npm run dev        # Starts both frontend and backend
npm run test       # Run all tests
```

---

## Streaming Chat (SSE)

The backend supports an EventSource-compatible pseudo-streaming interface (currently a single final payload framed as events; ready to evolve into true token streaming).

Endpoint (GET):

```
/underfoot/chat?chatInput=Your+prompt&stream=true
```

Events (protocolVersion 1):

| Event | Data Shape | Notes |
| - | - | - |
| `start` | `{ requestId, protocolVersion:1, cacheHit:boolean }` | First event confirming stream accepted |
| `complete` | Full JSON chat payload (`{ response, items?, debug }`) | Same object shape as POST response |
| `heartbeat` | `{ ts, requestId }` | Sent every \~20s if connection held long enough |
| `error` | `{ message, fatal?, requestId }` | Only on internal failure before completion |
| `end` | `{ requestId }` | Terminates stream |

Cache hits emit: `start(cacheHit:true)` → `complete` → `end` rapidly.

Example (browser):

```js
const es = new EventSource('/underfoot/chat?stream=true&chatInput=' + encodeURIComponent('Hello'));
es.addEventListener('complete', (e) => {
  const data = JSON.parse(e.data);
  console.log('Reply:', data.response);
});
es.addEventListener('end', () => es.close());
```

Non‑streaming: You can use `POST /underfoot/chat` with `{ "chatInput": "Hello" }`.

## 📄 License

**Custom License** - This project is not open source but allows broad usage.

**TL;DR**: Do what you want—as long as you're not turning it into the next big SaaS or selling subscriptions. For commercial use, ask first.

See [LICENSE](./LICENSE) for full details.


---

<p align="center">
  <em>Built with ❤️ and way too much coffee</em><br>
  <small>🛡️ This entire project was built with the help of ChatGPT, GitHub Copilot, and Verdent AI: The coding assistant that actually understands the assignment and doesn't try to rewrite your entire codebase "for better practices." Thanks for being the sane voice in the room, AI buddy!</small>
</p>

---
