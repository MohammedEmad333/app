# Sound effects

Short synthesized `.wav` tones ship with the app and play during lessons:

- `correct.wav` — plays on a correct answer
- `wrong.wav` — plays on a wrong answer
- `celebrate.wav` — plays on lesson completion
- `tap.wav` — UI tap feedback

They were generated as simple tones so the demo has sound with no external
assets. Swap in your own `.wav` files with the same names to change them.
`AudioService` fails silently if a file is missing, and haptic feedback fires
alongside these on supported devices. Word/sentence pronunciation is handled
live by device TTS (`TtsService`), so no recorded voice files are needed.
