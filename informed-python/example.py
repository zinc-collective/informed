import os
import sys
sys.path.insert(0, os.path.abspath(os.path.dirname(__file__)))

import logging
rootLogger = logging.getLogger('informed')
rootLogger.setLevel(10)
logging.basicConfig(format='%(levelname)s %(asctime)-15s %(message)s')

from informed import inform_on

class FancyService:
    def __init__(self, fanciness=None):
        self.fanciness = fanciness

    @inform_on(level='info', also_log={ 'result': True, 'values': ["is_fancy", "force", "fanciness"] })
    def do_something(self, force=False):
        if self.is_fancy() or force:
            return self.do_it_fancy()
        else:
            return self.do_it_plain()

    def is_fancy(self):
        return self.fanciness > 10

    def do_it_plain(self):
        return "so plain"

    def do_it_fancy(self):
        return "so fancy"

fs = FancyService(fanciness=8)
fs.do_something()
fs.do_something(force=True)
