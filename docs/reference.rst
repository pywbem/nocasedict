
.. _`API Reference`:

API Reference
=============

This section describes the external API of the nocasedict project. Any
internal symbols and APIs are omitted.


.. _`Class NocaseDict`:

Class NocaseDict
----------------

.. autoclass:: nocasedict.NocaseDict
   :members:
   :special-members: __getitem__

   .. # Note, we want to exclude __init__. Specifying one other special member
   .. # ba name causes __init__ to be excluded and all other special methods to
   .. # be included.

   .. rubric:: Methods

   .. autoautosummary:: nocasedict.NocaseDict
      :methods:
      :nosignatures:

   .. rubric:: Attributes

   .. autoautosummary:: nocasedict.NocaseDict
      :attributes:

   .. rubric:: Details


.. _`Class HashableMixin`:
.. _`Mixin class HashableMixin`:

Mixin class HashableMixin
-------------------------

.. autoclass:: nocasedict.HashableMixin
   :members:
   :special-members: __hash__

   .. rubric:: Methods

   .. autoautosummary:: nocasedict.HashableMixin
      :methods:
      :nosignatures:

   .. rubric:: Attributes

   .. autoautosummary:: nocasedict.HashableMixin
      :attributes:

   .. rubric:: Details


.. _`Mixin generator function KeyableByMixin()`:
.. _`Function KeyableByMixin`:

Mixin generator function KeyableByMixin()
-----------------------------------------

.. autofunction:: nocasedict.KeyableByMixin
