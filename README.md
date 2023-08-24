# LifeIsAJoke

A basic iOS application that

- fetches a joke from a remote API at equal intervals (1 second hardcoded).
- updates the UI in such a way that the newest joke appears at the botttom of the list.
- If the list of jokes exceed 10, the application will shift the jokes array up by N places where N = jokes.count - 10. This will be accomanied by a nice animation.
- persists the latest set of jokes on disk when it is about to enter background.
- shows the persisted jokes when the application launches the next time.
- uses MVP architecture with a lot of emphasis on protocol oriented programing.

## Requirements

1. Xcode 14.2
2. iOS >= 13.0
3. Swift 6

## Project Setup Instructions

1. Clone the repo.
2. Build using Xcode (No third party dependencies are needed to be installed).
