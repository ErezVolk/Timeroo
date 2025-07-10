(*

To install a global hotkey for Timeroo, the best and easiest way I know is with
BetterTouchTool (Add global "Keyboard Shortcut", create "Run Apple Script"
action, and copy the code below into the action). I've tried Shortcuts and
Automoator and found them too cumbersome and slow for this task.

*)

(* tell application "Timeroo" to activate *)
tell application "Timeroo" to toggle
