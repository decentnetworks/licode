## Basic Example: record all streams

This note describes the changes that make the basic example record every active stream/channel.

### What changed
- `extras/basic_example/basicServer.js`: default media configuration is now `VP8_AND_OPUS` so recordings use a compatible codec setup by default.
- `extras/basic_example/public/script.js`: the UI now uses "Record all" / "Stop all" and records every local + remote stream, storing each recording id to stop them as a group.

### How it works
1. When "Record all" is clicked, the client iterates:
   - all local streams in `localStreams`
   - all remote streams in `room.remoteStreams` (if present)
2. For each stream, it calls `room.startRecording(stream, cb)`.
3. Each recording id is stored in a `recordingIds` map keyed by stream id.
4. When "Stop all" is clicked, the client calls `room.stopRecording(id)` for every stored id and clears the map.

### Notes for developers
- Duplicate calls for the same stream are prevented by checking the map first.
- If a stream has no id yet, recording is skipped until it is available.

### Accessing recorded files
Recordings are written on the server to the path configured by
`config.erizoController.recording_path` (see `licode_config.js`). The client only
receives a `recordingId` and does not get a downloadable URL by default.

There are two supported client-side flows:
- Stream the recording back into a room by creating an external stream with
  `recording: <recordingId>` or `url: <full file path>`.
- If you need direct file download or playback via HTTP, you must expose the
  recording files yourself (e.g., via your web server or a custom API).

Relevant client API calls are documented in `doc/client_api.md` under
"Start Recording", "Stop Recording", and "Playing recorded streams".
