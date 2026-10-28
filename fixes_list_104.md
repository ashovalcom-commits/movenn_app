fixes to impliment for 1.0.4



1. the gap between the "איזה סרט מסתתר..." question and the upper border of the answers display looks too large on smartphones (while it looks ok on PC debug mode)



---

## Release Notes – v1.0.4

### Bug Fixes
1. **Answer panel gap on smartphones** – Changed the answer panel's inner column alignment from `MainAxisAlignment.center` to `MainAxisAlignment.start`. The centered layout caused the question text and answer buttons to float in the middle of the panel; on tall smartphone screens (with more vertical space than a PC debug window), this produced a visibly large gap above the question. Content now hugs the top of the answer area consistently across all screen sizes.
