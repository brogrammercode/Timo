# Timo Focus: Project Description
Timo Focus is an aesthetic, offline-capable study and focus timer built with Flutter and Firebase. Designed to help users track their daily deep-work sessions, the app automatically tracks focus duration when active and pauses when sent to the background. It boasts a beautiful, edge-to-edge dynamic UI featuring randomized lo-fi scenery wallpapers and massive typography. Powered by BLoC for state management and Firebase for cloud syncing, Timo Focus ensures sessions are never lost, automatically rolling over at midnight, and seamlessly syncing offline data when an internet connection is restored.

## Core Requirements
- The app should be made with flutter, bloc, background services, firebase (no api)
- The app is basically about timer how much I spent while studying like a focus kind of app
- It will have a google sign-up/sign-in, and will give one funky random avatar and will allow to write user_name that should be different
- The flow should be :
  - If I will open the app and app is active, the session will be built/started automatically telling about the time i spent on this app for the day (means i focused that day and quited phone and was studying)
  - If I will close the app or move it to background, It will pause the running session (will not count it as a duration added)
  - If the session is already on, then whenever I will open the app, the session will be resumed
  - The session will be per day wise, paused session will not be resumed if day is completed, new session will start
  - The session will be synced whenever it is online (internet connectivity is available) and will work even on offline
- It should contain a history page that will show all the detailed past sessions
- It will also have a .env file and all the secrets will be operated on that one
