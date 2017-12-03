import logging
from functools import reduce
import json

class LogInformant:
    def __init__(self, logger=None):
        self.logger = logger
        if self.logger == None:
            self.logger = logging.getLogger('informed')

    def send(self, data={}, level='info'):
        self.logger.log(self._logger_level(level), json.dumps(data))

    LEVEL_TRANSLATION = {
            'critical': 50,
            'error': 40,
            'warning': 30,
            'info': 20,
            'debug': 10
            }

    def _logger_level(self,level):
        return self.LEVEL_TRANSLATION[level.lower()]

def maybe(obj, key):
    fn_or_value = getattr(obj, key, None)
    if callable(fn_or_value):
        return fn_or_value()
    else:
        return fn_or_value

def data_to_report(informed_upon_function, args, kwargs, desired):
    data = { kwarg: value for (kwarg, value) in kwargs.items() if kwarg in desired['values'] }
    data.update({ key: maybe(args[0], key) for key in desired['values'] if key not in data })
    data['function'] = informed_upon_function.__name__
    return data


def inform_on(via=LogInformant(), level='info', also_log={ 'result': False, 'values': []}):
    """
    Wraps calls to the given function with logging statements for start and end, including return value,
    duration, timestamp, event uuid, arguments and other contexts
    """
    def decorator(informed_upon_function):
        def wrapper(*args, **kwargs):
            data = data_to_report(informed_upon_function, args, kwargs, also_log)
            data['status']='starting'
            via.send(level=level, data=data)
            result = informed_upon_function(*args, **kwargs)
            second_data = data.copy()
            second_data['status'] = 'done'
            if 'result' in also_log and also_log['result']:
                second_data['result'] = result
            via.send(level=level, data=second_data)
            return result
        return wrapper
    return decorator

