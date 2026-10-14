# nvim

Neovim 0.12+ / lazy.nvim. Kotlin·Java(Spring) + TS/React + Claude Code·Codex.

## 새 맥 셋업

```sh
brew install neovim tree-sitter-cli ripgrep fd JetBrains/utils/kotlin-lsp
# JDK 21+ 필요 (jdtls / kotlin-lsp 실행용), mise로 설치한 JDK는 jdtls runtimes에 자동 등록
git clone git@github.com:kimyoungi99/kickstart.nvim.git ~/.config/nvim
nvim   # 플러그인·Mason 툴·treesitter 파서 자동 설치 (비동기라 설치 끝나면 한 번 재시작)
```

npm으로 깐 `tree-sitter-cli`가 PATH 앞에 있으면 지울 것 (nvim-treesitter main은 0.26+ 네이티브 CLI 필요).

## 구조

- `init.lua` — 옵션 / 기본 키맵 / lazy 부트스트랩
- `lua/plugins/` — `ui`, `editor`(snacks·mini·harpoon·gitsigns), `lsp`(LSP·완성·포맷·treesitter), `ai`(sidekick), `debug`
- `ftplugin/java.lua` — jdtls

## AI (`<leader>c`)

`cc` Claude Code · `cx` Codex · `cs` 선택 · `ct` 현재 위치 전송 · `cf` 파일 · `cv` 선택영역 · `cp` 프롬프트 · `<C-.>` 포커스
