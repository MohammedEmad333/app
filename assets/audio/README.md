# Sound effects (optional)

Drop short `.mp3` files here to enable sound effects. The app references:

- `correct.mp3` — plays on a correct answer
- `wrong.mp3` — plays on a wrong answer
- `celebrate.mp3` — plays on lesson completion
- `tap.mp3` — UI tap feedback

`AudioService` fails silently if a file is missing, so the app runs fine
without them. Word/sentence pronunciation is handled live by device TTS
(`TtsService`), so no recorded voice files are needed.
