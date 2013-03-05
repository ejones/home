import time
import threading
import logging

from tornado.web import asynchronous, RequestHandler, Application
from tornado.ioloop import IOLoop
from tornado import stack_context

io_loop = IOLoop.instance()

class HangingHandler(RequestHandler):
    @asynchronous
    def get(self):
        threading.Thread(target = lambda:
            time.sleep(1) or 
            
            # Assertion error, 42 is not valid to write
            # will leave the original request hanging *until it times out*
            io_loop.add_callback(lambda: self.finish(42))
        ).start()

class SafeThreadExcHandler(RequestHandler):
    @asynchronous
    def get(self):

        # NB: callback must be wrapped while in the original (main) thread
        @stack_context.wrap
        def callback():
            self.finish(42) # AssertionError, but will close out request

        def target():
            time.sleep(1)
            with stack_context.NullContext():
                io_loop.add_callback(callback)
        threading.Thread(target = target).start()

if __name__ == '__main__':

    Application([
        ('/hanging', HangingHandler),
        ('/safe', SafeThreadExcHandler)]).listen(8000)

    logging.getLogger().setLevel(logging.DEBUG)
    import tornado.options
    tornado.options.enable_pretty_logging()

    io_loop.start()
