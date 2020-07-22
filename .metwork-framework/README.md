## What is it ?

This is a [drone](https://drone.io/) repository to check with docker
the availability of some (system) libraries on plenty of Linux distributions.

You can find/set the list of Linux distributions in [.github/workflows/test.yml file](test.yml). `IMAGE` names
must be available in public Docker Hub.

You can find/set the list of system libraries to test in [list.txt file](list.txt) (without any PATH, just the base name).
