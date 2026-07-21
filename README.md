# xdayoungx Vape

Bedwars용 Vape — [mickievely/xdayoungx](https://github.com/mickievely/xdayoungx)

- **GitHub:** https://github.com/mickievely/xdayoungx
- **Raw 진입점:** https://raw.githubusercontent.com/mickievely/xdayoungx/main/xdayoungx.lua

## 빠른 실행 (복붙)

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/mickievely/xdayoungx/main/load.lua", true))()
```

## 자동 실행 (autoexec)

첫 실행 후 `autoexec/xdayoungx.lua`가 자동 설치됩니다.  
이후 게임 들어갈 때마다 자동 로드됩니다.

수동 설치:

```lua
-- exploit workspace/autoexec/xdayoungx.lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/mickievely/xdayoungx/main/load.lua", true))()
```

## 텔레포트 / 서버 이동

- 다른 서버·로비·인게임 이동 시 **자동 재로드**
- 설정·프로필 **자동 저장** (10초마다 + 텔레포트 전)

## 폴더 구조

```
xdayoungx.lua             # 진입점
load.lua                  # 원라인 로더
xdayoungx/                 # 내부 모듈 (경로명 유지)
  core/bootstrap.lua
  core/download.lua
  guis/main.lua
  games/universal.lua
  games/bedwars.lua
  games/lobby.lua
  libraries/
  loader.lua              # autoexec용
  profiles/
```

## 수정할 파일

| 대상 | 파일 |
|------|------|
| GUI | `xdayoungx/guis/main.lua` |
| Fly, ESP 등 | `xdayoungx/games/universal.lua` |
| 배드워즈 | `xdayoungx/games/bedwars.lua` |
| 로비 | `xdayoungx/games/lobby.lua` |

## 원격 설정

`xdayoungx/profiles/commit.txt`:

```
https://raw.githubusercontent.com/mickievely/xdayoungx/main
```

## GitHub 푸시

```powershell
cd "c:\Users\a0107\Downloads\배드워즈"
powershell -ExecutionPolicy Bypass -File tools/publish.ps1
```
