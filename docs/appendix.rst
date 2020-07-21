
.. _`Appendix`:

Appendix
========

This section contains information that is referenced from other sections,
and that does not really need to be read in sequence.


.. _`Troubleshooting`:

Troubleshooting
---------------

Here are some trouble shooting hints for ...


.. _'Glossary`:

Glossary
--------

.. glossary::

    string
       a :term:`unicode string` or a :term:`byte string`

    unicode string
       a Unicode string type (:func:`unicode <py2:unicode>` in
       Python 2, and :class:`py3:str` in Python 3)

    byte string
       a byte string type (:class:`py2:str` in Python 2, and
       :class:`py3:bytes` in Python 3). Unless otherwise
       indicated, byte strings in this project are always UTF-8 encoded.

    number
       one of the number types :class:`py:int`, :class:`py2:long` (Python 2
       only), or :class:`py:float`.

    integer
       one of the integer types :class:`py:int` or :class:`py2:long` (Python 2
       only).

    callable
       a callable object; for example a function, a class (calling it returns a
       new object of the class), or an object with a :meth:`~py:object.__call__`
       method.

    hashable
       a hashable object. Hashability requires an object not only to be able to
       produce a hash value with the :func:`py:hash` function, but in addition
       that objects that are equal (as per the ``==`` operator) produce equal
       hash values, and that the produced hash value remains unchanged across
       the lifetime of the object. See `term "hashable"
       <https://docs.python.org/3/glossary.html#term-hashable>`_
       in the Python glossary, although the definition there is not very crisp.
       A more exhaustive discussion of these requirements is in
       `"What happens when you mess with hashing in Python"
       <https://www.asmeurer.com/blog/posts/what-happens-when-you-mess-with-hashing-in-python/>`_
       by Aaron Meurer.


.. _`References`:

References
----------

.. glossary::

   XYZ
      `XYZ, Version 2.8 <https://xyz.org>`_

   Python Glossary
      * `Python 2.7 Glossary <https://docs.python.org/2.7/glossary.html>`_
      * `Python 3.4 Glossary <https://docs.python.org/3.4/glossary.html>`_
