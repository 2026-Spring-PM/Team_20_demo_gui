# Fonts

The game loads two font slots at startup, one for English UI and one
for Korean. Each slot tries the optional **PFStardust** face first,
then falls back to the bundled default.

## Resolution order (per slot)

| Slot | Try first              | Fall back to              |
|------|------------------------|---------------------------|
| EN   | `PFStardust.ttf`       | `SAOUITT-Regular.ttf`     |
| KO   | `PFStardust.ttf`       | `KBLJump_R.ttf`           |

If `PFStardust.ttf` is present in this folder, it is used for BOTH
languages -- the file ships Hangul + Latin together, so the same
face renders English and Korean text in a unified pixel style.
If it is absent, the bundled defaults (always present in the repo)
take over and the game runs identically to before.

## Adding PF스타더스트 (optional)

The PFStardust font is created by Pinata (campanula913@naver.com)
and distributed under a free-for-personal-and-commercial-use license
that **prohibits redistribution**. For that reason the `.ttf` is not
checked into this repository.

To use it locally:

1. Download the font from one of the official sources:
   - 눈누: https://noonnu.cc/font_page/393
   - 디자인베이스: https://designbase.co.kr/freefonts/pfseutadeoseuteu/
   - 타입피디아: https://typedia.kr/font/pfstardust/
2. Extract the archive and place the `.ttf` file in this folder,
   renaming it to **`PFStardust.ttf`** if needed.
3. Run the game. The startup log will not mention falling back to
   SAOUITT / KBL Jump R, and all text will render in the pixel style.

Add `assets/fonts/PFStardust.ttf` to your local `.gitignore` if you
ever push the repo publicly, to stay clear of the redistribution
clause.

## Bundled fonts

| File                       | License                                       |
|----------------------------|-----------------------------------------------|
| `SAOUITT-Regular.ttf`      | Free fan-font, non-commercial OK              |
| `KBLJump_R.ttf`            | KBL family -- **current KO default** (Regular). Bold is synthesised by the UI, so the Regular weight is the base. |
| `KBLJump_B.ttf` / `KBLCourt_EB.ttf` / `KBLJump_EB_Condensed.ttf` / `KBLJump_EB_Extended.ttf` | KBL family -- alternate weights/widths. Swap in via `FONT_PATH_KO` in `src/core/Game.cpp`. |
| `NEXONLv1Gothic-Regular.ttf` | NEXON Korea -- free incl. commercial use & redistribution; no modification. Legacy KO fallback, no longer the default. |
| `NanumGothic-Regular.ttf`  | SIL Open Font License (redistribution OK) -- legacy fallback, no longer the KO default |
| `PFStardust.ttf` (absent)  | Free use, redistribution PROHIBITED -- BYOF   |
