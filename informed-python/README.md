Python implementation of [Informed](../README.md), an event-logging library that helps you understand what's happening in your application.

## Usage

### Install

Add `informed` to your requirements.txt? I dunno?

### Instrument

Decorate the functions you want to inform on:

  * `@inform_on(level="info")` - Logs entrances and exits to the decorated function at the info level
  * `@inform_on(level="debug", also_log={ "result": True })` - Logs entrances and exits to the decorated function at the debug level. Includes the functions result with the completed log statement
  * `@inform_on(level="warn", also_log={ "values": ["a_keyword_arg", "an_instance_method", "an_attribute"] })` - Logs entrances and exits to the decorated function at the warning level and includes the keyword arg named `a_keyword_arg` in the output as well as the results of calling `an_instance_method` and the value stored in `an_attribute`.

For a more detailed example, look at [example.py](example.py). The following are the results of running `example.py`:

```
INFO 2017-11-27 22:26:13,533 {"is_fancy": false, "force": null, "fanciness": 8, "function": "do_something", "status": "starting"}
INFO 2017-11-27 22:26:13,533 {"is_fancy": false, "force": null, "fanciness": 8, "function": "do_something", "status": "done", "result": "so plain"}
INFO 2017-11-27 22:26:13,533 {"force": true, "is_fancy": false, "fanciness": 8, "function": "do_something", "status": "starting"}
INFO 2017-11-27 22:26:13,533 {"force": true, "is_fancy": false, "fanciness": 8, "function": "do_something", "status": "done", "result": "so fancy"}
```

### Configure
Informed looks up it's logger using `logging.getLogger('informed')`. This falls back to the rootLogger if you haven't specified an informed specific logger. The following is an example that sets the informed logger up to log everything. Further configuration can be found in the [python logging documentation](https://docs.python.org/3.6/library/logging.html#)

```python
import logging
rootLogger = logging.getLogger('informed')
rootLogger.setLevel(10)
logging.basicConfig(format='%(levelname)s %(asctime)-15s %(message)s')
```
