# `fprintd`

## Enrollement

    sudo fprintd-enroll $USER
    sudo fprintd-enroll $USER --finger right-middle-finger

Beware that just `sudo fprintd-enroll` confusingly also does work,
but that sets the fingerprints of the `root` user, which is not
what you'll want.

## Configuration

Enable extra fprintd configuration with `services.fprintd-extra.enable = true;`.

You can adjust the allowed fingerprint authentication attempts before falling back to password input using:

```nix
services.fprintd-extra.maxTries = 10; # Defaults to 10 attempts
```
