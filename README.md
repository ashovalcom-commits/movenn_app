# Movenn (מובן) — Israeli Movie Venn Diagram Trivia Game

A Flutter-based trivia game where players match Israeli movies to circles in a Venn diagram.

## Concept

Each level presents a Venn diagram image with three overlapping circles (A, B, C). The intersections show actors shared between movies. The player must identify which Israeli movie is behind each circle by recognizing the actors and their film connections.

## Gameplay

1. A Venn diagram image is displayed showing actors in overlapping regions.
2. The player is asked to identify the movie behind one circle at a time (A → B → C).
3. Four movie options are presented as multiple-choice answers — one correct, three distractors drawn from the global movie pool.
4. The active circle rotates automatically every **20 seconds** if unanswered.
5. Each level has a **4-minute time limit**; unanswered circles are marked wrong when time expires.
6. After all 3 circles are answered (or time runs out), a summary dialog shows results and score.

## Scoring

| Result | Points |
|---|---|
| 1 correct | 5 |
| 2 correct | 10 |
| 3 correct | 20 |
| 3 correct + finished under 60s | 30 (speed bonus) |

All scoring and timing values are configurable in `lib/game_config.dart`.

## Content

- **50 levels** with pre-made Venn diagram images (`assets/images/question_1.png` – `question_50.png`).
- Level data is stored in `assets/venn_questions_edit3_5.json`, containing for each level:
  - The three movies (A, B, C).
  - Actors in each intersection region (A-only, B-only, C-only, AB, AC, BC, ABC).
  - The corresponding diagram image filename.

## Project Structure

```
lib/
  main.dart          # App entry point, game UI, and all game logic
  game_config.dart   # Configurable timing and scoring constants
assets/
  venn_questions_edit3_5.json   # Level definitions (movies, actors, intersections)
  images/                    # Venn diagram images for each level
```

## Tech Stack

- **Flutter** (Dart SDK ^3.13.4)
- Material Design 3
- No external dependencies beyond Flutter core and Cupertino Icons

## Running

```bash
flutter pub get
flutter run
```

Targets: Android, iOS, Web, Windows, macOS, Linux.
