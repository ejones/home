from functools import wraps
from itertools import izip
from inspect import getargspec
from collections import Callable

def async(func):
    """ Decorator to turn a generator function into an asynchronous function,
    with yield points corresponding to asynchronous waits (they're also used
    to convey how asynchronous callbacks should be used)::

    >>> from threading import Thread
    >>> from time import sleep
    >>>
    >>> def timeout(func, interval):
    ...     def target(): sleep(interval); func()
    ...     Thread(target=target).start()
    ...
    >>> @async
    ... def do_stuff(callback):
    ...     ret = yield timeout((yield lambda: 'something'), 1)
    ...     print ret
    ...     callback('done!')
    ...
    >>> import sys
    >>>
    >>> @async
    ... def more_stuff(num, callback=lambda: sys.stdout.write('all done!\\n')):
    ...     print 'starting', num
    ...     print (yield do_stuff((yield lambda ret: ret)))
    ...
    >>> more_stuff(4)
    starting 4
    >>> sleep(2)
    something
    done!
    all done!

    The wrapped function must accept a parameter by the *exact* name of
    "callback", which is the sole exit point after all asynchronous execution
    of the function completes. To indicate where the callbacks of asynchronous
    functions that are called go and behave, yield a lambda in their place.
    This lambda will be called with the arguments to that asynchronous callback
    and the result will be what is returned from the surrounding yield point.

    If by your function never calls its ``callback``, it will be called after it
    exits, with no parameters. So for instance, if you need to "return" values to
    the callback, you will need to call it yourself, with whatever, at the end
    of your function.

    """
    argspec = getargspec(func)
    args = argspec.args
    if not 'callback' in args:
        raise ValueError('function does not have a "callback" argument')
    cbidx = args.index('callback')
    cbdflt = argspec.defaults and \
                next((v for k,v in izip(reversed(args), reversed(argspec.defaults)) 
                      if k == 'callback'), None)


    @wraps(func)
    def ret(*args, **kwargs):
        # locate and extract callback
        if cbidx < len(args):
            args = list(args)
            callback = args.pop(cbidx)
        else:
            callback = kwargs.get('callback', cbdflt)

        # wrap our callback
        did_call_cb_ref = [False]
        def complete(*args, **kwargs):
            did_call_cb_ref[0] = True
            callback(*args, **kwargs)
        kwargs['callback'] = complete
            
        gen = func(*args, **kwargs)
        def step(val):
            try: cont = gen.send(val)
            except StopIteration: 
                if not did_call_cb_ref[0]: callback()
                return

            # the generator sends continuation points, expecting callbacks provided
            # to asynchronous procedure calls
            if isinstance(cont, Callable):
                step(lambda *args, **kwargs: step(cont(*args, **kwargs)))

        step(None)
            
    return ret

