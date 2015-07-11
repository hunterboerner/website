# Persistent SSH connections to make Git get git faster

SSH connections take a while to initiate which is annoying when
working with git over ssh. Add these lines to your ssh config
`~/.ssh/config` which should persist your SSH connections and make
remote git commands faster.

```
Host *
    ControlMaster auto
    ControlPath /tmp/%r@%h:%p
    ControlPersist yes
```

If you only want it to be enabled on certain domains, put it under a
different `Host` section.

Original Source: http://interrobeng.com/2013/08/25/speed-up-git-5x-to-50x/
