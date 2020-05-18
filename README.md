logbook — tool for publishing personal log files
-------------------------------------------------------------------------------
%%VERSION%%

`logbook` is a simple tool for converting `log` files (a really poor choice of
name) to HTML. `log` is a file format for structured log or diary keeping which
is flexible in choice of markup language and allows to be published while hiding
private information.

`logbook` also provides a module `Log` for parsing `log` files and performing
basic operations on an OCaml representation of a `log` file. It is currently
mostly useful for reading `log` files and processing its information in some
way.

`logbook` uses a simplified version of the `log` format, which was originally
[specified by Profpatsch](https://gist.github.com/Profpatsch/092ff68fa267b9fa0ccbe13e98149b21).
Here is a short example of a `log` file:

    [2020-05-13]
    Today was just an average day. I haven't been too productive.

    + Worked on `logbook` again.
      Mostly spent time on writing user documentation which
      was more or less non-existent before.
    * Procrastinated a lot.
      Was very tired and got almost nothing done for university.

In this example the second item of the entry would be hidden, if the
log was to be shared publicly, using `logbook` for HTML generation.
This would be done like this: `logbook --file my.log --public --markdown > out.html`.

For more details read on!

## (Post-)Privacy mechanism

The `log` format differenciates between three privacy levels, which can be used
to control what parts of your `log` file is shared with whom. These levels can
be applied to the items of a `log` entry and indicate to which group of people
the respective items are allowed to be displayed.

* Private (indicated by `-` in the format): private information which
  usually means only the author(s) of the file are allowed to access it
* Semi Private (indicated by `*`): semi private information
  which can be accessed by a group of trusted individuals (e. g. friends and
  family or close associates)
* Public (indicated by `+`): information which can be accessed by anyone and
  could be published, for example as a blog

The privacy levels double up as levels an individual or program could have accessing
the log file. In this case the level means “has access to this level and all less
trustful levels”. Someone with privacy level private could access all three types
of items, someone with level semi private could access semi private and public items
and someone with level public could only access public items.

Entry summaries are always public.

In `logbook` this system is implemented as follows: When running it, you can
specify the privacy level of the output file which `logbook` respects by
only including items visible at this privacy level in the generated HTML file.
Distributing the output to other individuals and managing access to them is
beyond the scope of this utility, but such dynamic systems are possible.

## The `log` format

A `log` file consists of multiple entries for specific dates (`logbook` respects
the order used in the file, so either ascending or descending, even random could
be used). Entries are separated by any number of empty lines.

An entry looks like this (comments starting with `#` are not part of the file and
would make it invalid!):

    [YYYY-MM-DD]                                # date of the entry, also functions as its title
    Any number of lines in a markup of          # summary (of the day), any markup, terminated
    your choice! Empty lines, however,          # by one or more empty lines,
    are not allowed.
    
    + Title of a Public Item                    # title of an entry, one line of any markup
      A block of markup of your choice, which   # with "+ ", "* " or "- " prepended.
      must be indented using 2 spaces. Empty
      lines also terminate this block.
    * Title of a Semi Private Item
      Also a non indented line ends an item,    # The Item text is a block of any markup indented
      like you just saw. Of course only a       # using 2 spaces.
      line initiating a new item would be
      seen as valid in this case.
    - Title of a Private Item
      There is a way to have empty lines of
      your markup in items: You just need to
      indent an empty line using 2 spaces,
      i. e. have a line only containing
      2 spaces, like so:
      
      Probably invisible for you, but those
      spaces are there! This of course only
      works in an item and not in the summary.
    
    + Title of Another Public Item
      Of course you can have any number of
      items of each type and also empty lines
      between them.

As you saw an entry consists of:

* A date in brackets at the beginning
* A summary which is terminated by an empty line (or the beginning of an item)
* 0 or more items consisting of:
  * A preceding privacy indicator (`+`, `*` or `-`) and a space
  * A title (the rest of the line with the indicator)
  * A text as a block of markup indented using 2 spaces.

For the semantics of the three privacy indicators, see above.

The entry's summary, its item's title and text may contain (almost) any
markup. The `logbook` tool supports markdown and optionally converts these
parts of the `log` file to HTML by applying a markdown to HTML converter
to them.

You can find an example log file in [`example.log`](./example.log).

### Difference to Profpatsch's `log`

The original `log` format uses more complex items: Instead of having a one-line title and
a block indented using 2 spaces, it uses a block indented by 2 spaces for the title and
the item's text would be indented using 4 spaces.

While it allows for multi-line titles, it has the major drawback that — when using
indentation-sensitive markup — it can't be differenciated between a line of the title
which is indented using 2 spaces and the beginning of the 4 space indented block of
the item text. I decided to rework this in order to avoid such cases altogether.

## Usage

`logbook` can be called using the following options. All of them can be
omitted. The default behavior is roughly equivalent to
`logbook --file /dev/stdin --title log --public`

* `--file <path>` specify input `log` file. If omitted, use stdin.
* `--markdown` enable markdown markup.
* `--paragraph` enables a trivial “markup” which just wraps the supplied text with `<p>`.
  This is similar to what markdown does, so this option is intended to make templates
  intended for markdown makeup work without a markup.
* `--public` set privacy level to public
* `--semi-private` set privacy level to semi private
* `--private` set privacy level to private
* `--template <path>` specify [Jingoo](https://github.com/tategakibunko/jingoo)
  template to use instead of the default one.
* `--title <string>` title of the output HTML file, defaults to `"log"`

In the case of the privacy level options, the last one specified overrides the previous ones.

## Templating

`logbook` uses [Jingoo](https://github.com/tategakibunko/jingoo) templates to generate html
per default using a very simple template. You'll probably want to specify your own using
the `--template` option. For templating, `logbook` provides the following variables
(see also `model_of_log` in [`src/logbook_models.ml`](./src/logbook_models.ml)):

* `title`: equivalent to what is specified using `--title`
* `entries`: list of objects containing:
  * `summary`: the summary of the entry as string (might already be converted to HTML using markdown)
  * `date`: the date of the entry as string
  * `items`: list of objects containing:
    * `title`: title of the item as string
    * `text`: text of the item as string (might already be converted to HTML)

For an example template see [`src/logbook_template.ml`](./src/logbook_template.ml)


## Installation

* Using OPAM:
  `opam pin add logbook https://github.com/sternenseemann/logbook.git`
* On NixOS:
  * Directly from `master`: `nix-env -f https://github.com/sternenseemann/logbook/archive/master.tar.gz -i` (also works with the release source tarballs!)
  * using [vuizvui](https://github.com/openlab-aux/vuizvui): `vuizvui.pkgs.sternenseemann.logbook`

## Future Improvements

A little todo list, might get to it at some point.

* [x] man page
* [ ] Improve error messages of parser
* [ ] General Comments
* [ ] CSS support
* [ ] Make item blocks optional.
* [ ] Make summary an option type.
