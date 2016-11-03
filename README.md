[![Build Status](https://travis-ci.org/zyedidia/micro.svg?branch=master)](https://travis-ci.org/zyedidia/micro)
[![Go Report Card](https://goreportcard.com/badge/github.com/zyedidia/micro)](https://goreportcard.com/report/github.com/zyedidia/micro)
[![Join the chat at https://gitter.im/zyedidia/micro](https://badges.gitter.im/zyedidia/micro.svg)](https://gitter.im/zyedidia/micro?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
[![MIT License](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/zyedidia/micro/blob/master/LICENSE)

**Scraper** is a toy to extract web data just by mouse.

* All css styles and layouts come from [https://dexi.io](http://dexi.io).
* All images including logo comes from  [https://dexi.io](http://dexi.io).
* All functions come from  [https://dexi.io](http://dexi.io). but are self-implemented.

Dexi.io provides such amazing tool, so I just want to make a little copy from it.

Here is a gif to show the little toy how to work.

![Screenshot](./app/assets/images/scraper_baidu.gif)

To see more gif of Scraper, see [show1](./app/assets/images/scraper_show1.gif) and [show2](./app/assets/images/scraper_yahoo.gif).

# Features

* Not need coding, but need web concepts include html,XPath.
* using XPath selector , but dexi.io using CSS selector.
* using phantomjs engine at backend

# Installation

To install scraper, you should install [rails](http://installrails.com/) and download [phantomjs](http://phantomjs.org/).

### After install rails.

For Centos ,Mac and Windows, you should update scraper project

```sh
cd <scraper root>
bundle update
```

then all dependencies will be installed.

For Mac, installing nokogiri gem may have some problem, but keep some patience.

If you cannot link http://rubygems.org or https://rubygems.org, you had better use proxy to update.

### Colors and syntax highlighting

If you open micro and it doesn't seem like syntax highlighting is working, this is probably because
you are using a terminal which does not support 256 color. Try changing the colorscheme to `simple`
by running `> set colorscheme simple`.

If you are using the default ubuntu terminal, to enable 256 make sure your `TERM` variable is set
to `xterm-256color`.

Many of the Windows terminals don't support more than 16 colors, which means
that micro's default colorscheme won't look very good. You can either set
the colorscheme to `simple`, or download a better terminal emulator, like
mintty.

### Plan9, NaCl, Cygwin

Please note that micro uses the amazing [tcell library](https://github.com/gdamore/tcell), but this
means that micro is restricted to the platforms tcell supports. As a result, micro does not support
Plan9, NaCl, and Cygwin (although this may change in the future).

# Usage

Once you have built the editor, simply start it by running `micro path/to/file.txt` or simply `micro` to open an empty buffer.

Micro also supports creating buffers from `stdin`:

```sh
ifconfig | micro
```

You can move the cursor around with the arrow keys and mouse.

You can also use the mouse to manipulate the text. Simply clicking and dragging
will select text. You can also double click to enable word selection, and triple
click to enable line selection.

# Documentation and Help

Micro has a built-in help system which you can access by pressing `CtrlE` and typing `help`. Additionally, you can
view the help files online [here](https://github.com/zyedidia/micro/tree/master/runtime/help).

I also recommend reading the [tutorial](https://github.com/zyedidia/micro/tree/master/runtime/help/tutorial.md) for
a brief introduction to the more powerful configuration features micro offers.

# Contributing

If you find any bugs, please report them! I am also happy to accept pull requests from anyone.

You can use the Github issue tracker to report bugs, ask questions, or suggest new features.