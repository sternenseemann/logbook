logbook — tool for personal log files
-------------------------------------------------------------------------------
%%VERSION%%

logbook is a small tool for dealing with log files, which were first [specified by Profpatsch](https://gist.github.com/Profpatsch/092ff68fa267b9fa0ccbe13e98149b21) (sadly only in german, I will add a translation as soon as possible).

Parsing and Representation of log files works at the moment, more to come!

## Example log file

```
[2017-02-11]
The 42nd day of the year.

+ Public information.
  foo bar
- Private information.
  Additional block
* Semi-private information.
  More text!
```

## Usage

```
logbook --file example.log [ --private | --public | --semi-private ]
```
