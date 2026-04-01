# `fprintd`

## Enrollement

    sudo fprintd-enroll $USER
    sudo fprintd-enroll $USER --finger right-middle-finger

Beware that just `sudo fprintd-enroll` confusingly also does work,
but that sets the fingerprints of the `root` user, which is not
what you'll want.
