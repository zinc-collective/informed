import os
import sys
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

import informed

def func(x):
    return x + 1

def test_answer():
    assert func(5)
