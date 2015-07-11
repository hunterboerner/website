# `brew services`

`brew services` (https://github.com/Homebrew/homebrew-services) is a command that allows you to start and
stop packages you have installed through homebrew without having to
manually link plist files. You're probably used to seeing something
like this after installing a package:

```
==> Caveats

To have launchd start redis at login:
    ln -sfv /usr/local/opt/redis/*.plist ~/Library/LaunchAgents
Then to load redis now:
    launchctl load ~/Library/LaunchAgents/homebrew.mxcl.redis.plist
Or, if you don't want/need launchctl, you can just run:
    redis-server /usr/local/etc/redis.conf
```

There exists a couple of tools to help manage your LaunchAgents, most
notably https://github.com/eddiezane/lunchy and its dependency free
go-lang port, https://github.com/sosedoff/lunchy-go.

These still do not provide as clean of an interface as would be
expected when installing packages. Instead, we can use the wonderful
`brew services` command.

`brew services` used to be a homebrew built-in but it was removed due
to lack of maintainers. Somebody rewrote the command and it is now
provided in an official tap. Install it using:

```
brew tap homebrew/services
```

NOTE: if you have tapped homebrew/boneyard, you will not be able to
use this tap since the boneyard includes the _old_ `brew services`
command.

Using it is as simple as: `brew services start redis`.

Run `brew services --help` or look at the GitHub repo for more instructions.
