# xdayoungx Vape

Bedwars용 Vape 스크립트 — 모듈화 버전.

- **GitHub:** https://github.com/xdayoungx/gokuvape
- **Raw 진입점:** https://raw.githubusercontent.com/xdayoungx/gokuvape/main/gokuvape.lua

## 빠른 실행

```lua
shared.GokuVapeRepo = "https://raw.githubusercontent.com/xdayoungx/gokuvape/main"
loadstring(game:HttpGet("https://raw.githubusercontent.com/xdayoungx/gokuvape/main/gokuvape.lua", true))()
```

로컬 파일:

```lua
loadstring(readfile("gokuvape.lua"))()
```

## 폴더 구조

```
gokuvape.lua              # 진입점
gokuvape/
  core/bootstrap.lua        # 부트스트랩, 텔레포트, 자동 저장
  core/download.lua         # 파일 로드 + 공용 라이브러리
  guis/main.lua             # GUI
  games/universal.lua       # 공통 모듈
  games/bedwars.lua         # 배드워즈 인게임
  games/lobby.lua           # 배드워즈 로비
  libraries/                # hash, entity, bedwars API
  loader.lua                # autoexec용
  profiles/                 # 설정
```

## 수정할 파일

| 대상 | 파일 |
|------|------|
| GUI | `gokuvape/guis/main.lua` |
| Fly, ESP 등 | `gokuvape/games/universal.lua` |
| 배드워즈 | `gokuvape/games/bedwars.lua` |
| 로비 | `gokuvape/games/lobby.lua` |
| Bedwars API | `gokuvape/libraries/bedwars/` |

## 원격 자동 다운로드

`gokuvape/profiles/commit.txt`:

```
https://raw.githubusercontent.com/xdayoungx/gokuvape/main
```

## 개발

원본 단일 파일에서 다시 분할:

```powershell
python tools/split_gokuvape.py
```
