""" Utilities for writing code that adapts to specific types """

from functools import wraps, partial
from itertools import islice

class TypeDispatch:
    """ Matches types to values based on subclass matching. Use the item setter
    to associate a value with a type, then use the item getter to retrieve the value
    for the most specific type/supertype
    """
    def __init__(self, default=None):
        self.default = default
        self._targets = {}
        self._cache = None

    def __setitem__(self, typ, val):
        if typ is object:
            raise ValueError('Invalid type mapping: object')
        self._targets[typ] = val
        self._cache = None

    def __getitem__(self, typ):
        cache = self._cache
        if cache is None:
            cache = self._cache = self._targets.copy()

        target = cache.get(typ)
        if target is None:
            # check for direct subclass
            for base in typ.mro():
                if base in cache:
                    target = cache[base]
                    break
            else: # check for ABC, default to default target (func)
                abases = [b for b in cache if issubclass(typ, b)]    
                target = next((b for i, b in enumerate(abases)
                               if not any(issubclass(sb, b) for sb in
                                            islice(abases, i + 1, None))),
                              self.default)
            cache[typ] = target

        return target
        

def specializable(func):
    """ Decorator that allows the function to be specialized 
    on the type of the first argument, that is, given (a) different 
    implementation(s) later, conditional on the first argument matching 
    some type. Use the ``of`` method on the returned function::

    >>> @specializable
    ... def foo(x, y, z):
    ...     print x, y, z
    ...
    >>> @foo.of(int)
    ... def foo(x, y, z):
    ...     print 'an int:', x, y, z
    ...
    >>> foo('blah', 42, [])
    blah 42 []
    >>> foo(42, 'blah', [])
    an int: 42 blah []

    Note that even abstract types like `collections.Iterable` are
    matchable.

    You can use the ``get`` method to get the callable that would be 
    called for a given type.

    """
    disp = TypeDispatch(func)

    ret = wraps(func)(lambda *args, **kwargs: disp[type(args[0])](*args, **kwargs))

    @partial(setattr, ret, 'of')
    def of(typ):
        """ Decorator that allows you to specialize the behaviour
        of the current function on the type of its first argument.
        See the docs on `specializable`.
        """
        def dec(f):
            disp[typ] = f
            return ret
        return dec

    @partial(setattr, ret, 'get')
    def get(typ):
        """ Return the callable that would be called for this type """
        return disp[typ]

    return ret

def specializable_converter(func):
    """ Decorator that turns a function into one that can be customized on
    the first argument's *value* (similar to, but unlike `specializable`, 
    where the resulting funtion is customizable on the *type* of the first
    argument); this value must be a type.

    As such, it can be used to implement conversion functions and is sort 
    of the opposite of `specializable` functions, bringing values into
    a certain type.

    Here is an example, where you might be converting "ID"s that are submitted
    as query string parameters in a web app::

    >>> @specializable_converter
    ... def id_conversion(typ, val):
    ...     return typ(val)
    ...
    >>> class MyDatum(object):
    ...     def __init__(self, id, a, b):
    ...         self.id, self.a, self.b = id, a, b
    ...     
    ...     index = {}
    ...     
    ...     @classmethod
    ...     def add(cls, id, *args, **kwargs):
    ...         cls.index[id] = cls(id, *args, **kwargs)
    ...
    >>> MyDatum.add(1, 'hello', 'world')
    >>> MyDatum.add(2, 'hola', 'mundo')
    >>>
    >>> @id_conversion.of(MyDatum)
    ... def id_conversion(typ, val):
    ...     return typ.index[int(val)]
    ...
    >>> id_conversion(int, '45')
    45
    >>> x = id_conversion(MyDatum, '2')
    >>> x.a, x.b
    ('hola', 'mundo')

    Just like `specializable`, abstract types like `Iterable` are supported, and
    just like `specializable`, the ``get`` method can also be used to just get the
    function that would be called for a specific type.

    """
    disp = TypeDispatch(func)
    ret = wraps(func)(lambda *args, **kwargs: disp[args[0]](*args, **kwargs))

    @partial(setattr, ret, 'of')
    def of(typ):
        """ Decorator that allows you to specialize the behaviour
        of the current function on the value (a type) of its first argument.
        See the docs on `specializable_converter`.
        """
        def dec(f):
            disp[typ] = f
            return ret
        return dec

    @partial(setattr, ret, 'get')
    def get(typ):
        """ Return the callable that would be called for this type """
        return disp[typ]

    return ret
