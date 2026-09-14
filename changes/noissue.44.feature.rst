Made the following :class:`nocasedict.NocaseDict` methods subclass-safe,
that so far returned a NocaseDict object. Now, they return an object of
NocaseDict or a subclass, if NocaseDict was subclassed:
``fromkeys()``, ``__or__()``, ``__ror__()``, ``copy()``.
