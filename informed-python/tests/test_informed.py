import os
import sys
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from informed import inform_on

class FakeInformant:
    def __init__(self, messages={ }):
        self.reset_messages(messages)

    def send(self, data={}, level='info'):
        self.messages_at(level).append(data)

    def messages_at(self, level):
        return self.messages[level]

    def reset_messages(self, messages):
        self.messages = { 'info': [], 'debug': [], 'error': []  }

fake_informant = FakeInformant()
@inform_on(via=fake_informant, level='info', also_log={ 'result': True, 'values': ['a_keyword_arg'] })
def informed_on_function(a_positional_arg, a_keyword_arg=None, another_keyword_arg=None):
    return "you should see me as the result"

@inform_on(via=fake_informant, level='info', also_log={ 'values': ['another_keyword_arg'] })
def other_informed_on_function(a_positional_arg, a_keyword_arg=None, another_keyword_arg=None):
    return "you shouldn't see me as the result"

class FancyService:
    def __init__(self, fanciness=None):
        self.fanciness = fanciness

    @inform_on(via=fake_informant, level='info', also_log={ 'result': True, 'values': ["is_fancy", "force", "fanciness"] })
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

def test_informing_on_a_function():
    fake_informant.reset_messages

    informed_on_function("first", a_keyword_arg="something", another_keyword_arg="DONT LOOK AT ME")
    first_message = fake_informant.messages_at('info')[-2]

    assert first_message['status'] == 'starting'
    assert 'another_keyword_arg' not in first_message

    second_message = fake_informant.messages_at('info')[-1]
    assert second_message['a_keyword_arg'] == 'something'
    assert second_message['status'] == 'done'
    assert second_message['function'] == 'informed_on_function'
    assert second_message['result'] == 'you should see me as the result'

    fake_informant.reset_messages
    other_informed_on_function("first", a_keyword_arg="something", another_keyword_arg="LOOK AT ME NOW")
    first_message = fake_informant.messages_at('info')[-2]
    assert first_message['status'] == 'starting'
    assert first_message['another_keyword_arg'] == "LOOK AT ME NOW"

    second_message = fake_informant.messages_at('info')[-1]
    assert 'result' not in second_message

def test_informing_on_a_method():
    fake_informant.reset_messages
    fancy = FancyService(fanciness=10)
    fancy.do_something()

    first_message = fake_informant.messages_at('info')[-2]

    assert first_message['status'] == 'starting'
    assert first_message['force'] == None
    assert first_message['is_fancy'] == False
    assert first_message['fanciness'] == 10
    assert 'result' not in first_message

    second_message = fake_informant.messages_at('info')[-1]
    assert second_message['status'] == 'done'
    assert second_message['result'] == 'so plain'

    fake_informant.reset_messages


    fancy.do_something(force=True)

    first_message = fake_informant.messages_at('info')[-2]
    assert first_message['force']

    second_message = fake_informant.messages_at('info')[-1]
    assert second_message['force']
