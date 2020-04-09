# vibejournald

[![Build Status](https://travis-ci.org/symmetryinvestments/vibejournald.svg?branch=master)](https://travis-ci.org/symmetryinvestments/vibejournald)

```d
auto jl = cast(shared Logger)new JournaldLogger();
registerLogger(jl);
```

creates a vibe.d logger that logs to the journald logging facilities
provided by systemd.
