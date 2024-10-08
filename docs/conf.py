#
# Sphinx config file for nocasedict project.
#
# This file is execfile()d with the current directory set to its
# containing dir.
#
# Note that not all possible configuration values are present in this
# autogenerated file.
#
# All configuration values have a default; values that are commented out
# serve to show the default.

# pylint: disable=invalid-name

"""
Config file for Sphinx.
"""

import sys
import os
import inspect
import setuptools_scm
from sphinx.ext.autosummary import Autosummary
from sphinx.ext.autosummary import get_documenter
from sphinx.util.inspect import safe_getattr
from sphinx.util import logging
from docutils.parsers.rst import directives


XYZ_VAR = 'xyz'

# RST variable substitutions
rst_prolog = f"""

.. |XYZ_VAR| replace:: ``"{XYZ_VAR}"``

"""

# If extensions (or modules to document with autodoc) are in another directory,
# add these directories to sys.path here. If the directory is relative to the
# documentation root, use os.path.abspath to make it absolute, like shown here.
sys.path.insert(0, os.path.abspath('..'))

# -- General configuration ------------------------------------------------

# If your documentation needs a minimal Sphinx version, state it here.
needs_sphinx = '4.2'

# Add any Sphinx extension module names here, as strings. They can be
# extensions coming with Sphinx (named 'sphinx.ext.*') or your custom
# ones.
extensions = [
    'sphinx.ext.autodoc',
    'sphinx.ext.napoleon',
    'sphinx.ext.autosummary',
    'sphinx.ext.intersphinx',
    'sphinx.ext.extlinks',
    'sphinx.ext.todo',
    'sphinx.ext.coverage',
    'sphinx.ext.viewcode',   # disabed, raises anexception
    'sphinx.ext.ifconfig',
    'sphinx_rtd_theme',
]

# Add any paths that contain templates here, relative to this directory.
templates_path = ['_templates']

# The suffix(es) of source filenames.
# You can specify multiple suffix as a list of string:
# source_suffix = ['.rst', '.md']
source_suffix = '.rst'

# The encoding of source files.
source_encoding = 'utf-8'

# The master toctree document.
on_rtd = os.environ.get('READTHEDOCS', None) == 'True'
if on_rtd:
    master_doc = 'index'
else:
    master_doc = 'docs/index'

# This env var is evaluated in the nocasedict package and causes the methods
# that are supposed to exist only in a particular Python version, not to be
# removed, so they appear in the docs.
os.environ['BUILDING_DOCS'] = '1'

# General information about the project.
project = 'nocasedict'
# copyright = u''
author = "Andreas Maier"

# The short description of the package.
_short_description = "A case-insensitive ordered dictionary for Python"

# The version info for the project you're documenting, acts as replacement for
# |version| and |release|, also used in various other places throughout the
# built documents.

# The full version, including alpha/beta/rc tags
release = setuptools_scm.get_version(root='..', relative_to=__file__)

# The short M.N.U version, displayed in the docs.
# We also use the full version for that.
version = release

# The language for content autogenerated by Sphinx. Refer to documentation
# for a list of supported languages.
#
# This is also used if you do content translation via gettext catalogs.
# Usually you set "language" from the command line for these cases.
language = 'en'

# By default, highlight as Python 3.
highlight_language = 'python3'

# There are two options for replacing |today|: either, you set today to some
# non-false value, then it is used:
# today = ''
# Else, today_fmt is used as the format for a strftime call.
# today_fmt = '%B %d, %Y'

# List of patterns, relative to source directory, that match files and
# directories to ignore when looking for source files.
exclude_patterns = ["README.md",
                    ".tox", ".git", "design", "tests", "dist",
                    "build_doc"]

# The reST default role (used for this markup: `text`) to use for all
# documents. None means it is rendered in italic, without a link.
default_role = None

# If true, '()' will be appended to :func: etc. cross-reference text.
add_function_parentheses = True

# If true, the current module name will be prepended to all description
# unit titles (such as .. function::).
# add_module_names = True

# If true, sectionauthor and moduleauthor directives will be shown in the
# output. They are ignored by default.
# show_authors = False

# The name of the Pygments (syntax highlighting) style to use.
pygments_style = 'sphinx'

# A list of ignored prefixes for module index sorting.
# modindex_common_prefix = []

# If true, keep warnings as "system message" paragraphs in the built documents.
# keep_warnings = False

# If true, `todo` and `todoList` produce output, else they produce nothing.
todo_include_todos = True


# -- Options for Napoleon extension ---------------------------------------

# Enable support for Google style docstrings. Defaults to True.
napoleon_google_docstring = True

# Enable support for NumPy style docstrings. Defaults to True.
napoleon_numpy_docstring = False

# Include private members (like _membername). False to fall back to Sphinx’s
# default behavior. Defaults to False.
napoleon_include_private_with_doc = False

# Include special members (like __membername__). False to fall back to Sphinx’s
# default behavior. Defaults to True.
napoleon_include_special_with_doc = True

# Use the .. admonition:: directive for the Example and Examples sections,
# instead of the .. rubric:: directive. Defaults to False.
napoleon_use_admonition_for_examples = False

# Use the .. admonition:: directive for Notes sections, instead of the
# .. rubric:: directive. Defaults to False.
napoleon_use_admonition_for_notes = False

# Use the .. admonition:: directive for References sections, instead of the
# .. rubric:: directive. Defaults to False.
napoleon_use_admonition_for_references = False

# Use the :ivar: role for instance variables, instead of the .. attribute::
# directive. Defaults to False.
napoleon_use_ivar = True

# Use a :param: role for each function parameter, instead of a single
# :parameters: role for all the parameters. Defaults to True.
napoleon_use_param = True

# Use the :rtype: role for the return type, instead of inlining it with the
# description. Defaults to True.
napoleon_use_rtype = True


# -- Options for viewcode extension ---------------------------------------

# Follow alias objects that are imported from another module such as functions,
# classes and attributes. As side effects, this option ... ???
# If false, ... ???.
# The default is True.
viewcode_import = True


# -- Options for HTML output ----------------------------------------------

# The theme to use for HTML and HTML Help pages.
# See https://www.sphinx-doc.org/en/stable/theming.html for built-in themes.
html_theme = 'sphinx_rtd_theme'

# Theme options are theme-specific and customize the look and feel of a theme
# further.
# See https://www.sphinx-doc.org/en/stable/theming.html for the options
# available for built-in themes.
# For options of the 'sphinx_rtd_theme', see
# https://sphinx-rtd-theme.readthedocs.io/en/latest/configuring.html
html_theme_options = {
    'style_external_links': False,
    'collapse_navigation': False,
}

# Add any paths that contain custom themes here, relative to this directory.
# html_theme_path = []

# The name for this set of Sphinx documents.  If not defined, it defaults to
# "<project> v<release> documentation".
# html_title = None

# A shorter title for the navigation bar.  Default is the same as html_title.
# html_short_title = 'ld'

# The name of an image file (relative to this directory) to place at the top
# of the sidebar.
# html_logo = None

# The name of an image file (relative to this directory) to use as a favicon of
# the docs.  This file should be a Windows icon file (.ico) being 16x16 or 32x32
# pixels large.
# html_favicon = None

# Add any paths that contain custom static files (such as style sheets) here,
# relative to this directory. They are copied after the builtin static files,
# so a file named "default.css" will overwrite the builtin "default.css".
# html_static_path = ['_static']

# Add any extra paths that contain custom files (such as robots.txt or
# .htaccess) here, relative to this directory. These files are copied
# directly to the root of the documentation.
# html_extra_path = ['_extra']

# If not '', a 'Last updated on:' timestamp is inserted at every page bottom,
# using the given strftime format.
# html_last_updated_fmt = '%b %d, %Y'

# If true, SmartyPants will be used to convert quotes and dashes to
# typographically correct entities.
# html_use_smartypants = True

# Custom sidebar templates, maps document names to template names.
html_sidebars = {
    '**': [
        'localtoc.html',
        'globaltoc.html',
        'relations.html',
        'sourcelink.html',
    ]
}

# Additional templates that should be rendered to pages, maps page names to
# template names.
# html_additional_pages = {}

# If false, no module index is generated.
# html_domain_indices = True

# If false, no index is generated.
# html_use_index = True

# If true, the index is split into individual pages for each letter.
# html_split_index = False

# If true, links to the reST sources are added to the pages.
# html_show_sourcelink = True

# If true, "Created using Sphinx" is shown in the HTML footer. Default is True.
# html_show_sphinx = True

# If true, "(C) Copyright ..." is shown in the HTML footer. Default is True.
html_show_copyright = False

# If true, an OpenSearch description file will be output, and all pages will
# contain a <link> tag referring to it.  The value of this option must be the
# base URL from which the finished HTML is served.
# html_use_opensearch = ''

# This is the file name suffix for HTML files (e.g. ".xhtml").
# html_file_suffix = None

# Language to be used for generating the HTML full-text search index.
# Sphinx supports the following languages:
#   'da', 'de', 'en', 'es', 'fi', 'fr', 'hu', 'it', 'ja'
#   'nl', 'no', 'pt', 'ro', 'ru', 'sv', 'tr'
# html_search_language = 'en'

# A dictionary with options for the search language support, empty by default.
# Now only 'ja' uses this config value
# html_search_options = {'type': 'default'}

# The name of a javascript file (relative to the configuration directory) that
# implements a search results scorer. If empty, the default will be used.
# html_search_scorer = 'scorer.js'

# Output file base name for HTML help builder.
htmlhelp_basename = 'nocasedict_doc'

# -- Options for LaTeX output ---------------------------------------------

latex_elements = {
    # The paper size ('letterpaper' or 'a4paper').
    # 'papersize': 'letterpaper',

    # The font size ('10pt', '11pt' or '12pt').
    # 'pointsize': '10pt',

    # Additional stuff for the LaTeX preamble.
    # 'preamble': '',

    # Latex figure (float) alignment
    # 'figure_align': 'htbp',
}

# Grouping the document tree into LaTeX files. List of tuples
# (source start file, target name, title,
#  author, documentclass [howto, manual, or own class]).
latex_documents = [
    (master_doc, 'nocasedict.tex', _short_description, author, 'manual'),
]

# The name of an image file (relative to this directory) to place at the top of
# the title page.
# latex_logo = None

# For "manual" documents, if this is true, then toplevel headings are parts,
# not chapters.
# latex_use_parts = False

# If true, show page references after internal links.
# latex_show_pagerefs = False

# If true, show URL addresses after external links.
# latex_show_urls = False

# Documents to append as an appendix to all manuals.
# latex_appendices = []

# If false, no module index is generated.
# latex_domain_indices = True


# -- Options for manual page output ---------------------------------------

# One entry per manual page. List of tuples
# (source start file, name, description, authors, manual section).
man_pages = [
    (master_doc, 'nocasedict', _short_description, [author], 1)
]

# If true, show URL addresses after external links.
# man_show_urls = False


# -- Options for Texinfo output -------------------------------------------

# Grouping the document tree into Texinfo files. List of tuples
# (source start file, target name, title, author,
#  dir menu entry, description, category)
texinfo_documents = [
    (master_doc, 'nocasedict', _short_description,
     author, 'nocasedict', _short_description,
     'Miscellaneous'),
]

# Documents to append as an appendix to all manuals.
# texinfo_appendices = []

# If false, no module index is generated.
# texinfo_domain_indices = True

# How to display URL addresses: 'footnote', 'no', or 'inline'.
# texinfo_show_urls = 'footnote'

# If true, do not generate a @detailmenu in the "Top" node's menu.
# texinfo_no_detailmenu = False


# -- Options for autodoc extension ----------------------------------------
# For documentation, see
# https://www.sphinx-doc.org/en/stable/ext/autodoc.html

# Note on the :special-members: option:
# In Sphinx releases azt least up to 1.6.5, this option does not behave
# as documented. Its behavior is that it only has an effect on the presence
# of the __init__ member in the documentation, which is shown when the
# option is specified without arguments or with an an argument list that
# includes __init__. Other special members that exist in the code are
# always shown (regardless of whether the option is omitted, specified without
# arguments, or specified with an argument list that may or may not
# include the special member).

# Selects what content will be inserted into a class description.
# The possible values are:
#   "class" - Only the class’ docstring is inserted. This is the default.
#   "both"  - Both the class’ and the __init__ method’s docstring are
#             concatenated and inserted.
#   "init"  - Only the __init__ method’s docstring is inserted.
# In all cases, the __init__ method is still independently rendered as a
# special method when the :special-members: option of the autoclass
# directive includes __init__ or is specified with no arguments.
# Based upon the behavior of the :special-members: option described above,
# the recommendation is to not specify the :special-members: option
# when this config value is set to "both" or "init".
autoclass_content = "both"

# Selects if automatically documented members are sorted alphabetically
# (value 'alphabetical'), by member type (value 'groupwise') or by source
# order (value 'bysource'). The default is alphabetical.
autodoc_member_order = "alphabetical"

# This value is a list of autodoc directive options (flags) that should be
# automatically applied to all autodoc directives. The supported options
# are:
#   'members', 'undoc-members', 'private-members', 'special-members',
#   'inherited-members' and 'show-inheritance'.
# If you set one of these options in this config value, they behave as if
# they had been specified without arguments on each applicable autodoc
# directive. If needed, an autodoc directive can then unspecify the option
# for the current autodoc directive with a negated form :no-{option}:.
# For example, you would specify an option :no-members: on an autoclass
# directive to unspecify a 'members' option included in this config value.
# Note that the :members: option on automodule is recursive w.r.t. the
# classes or other items in the module, so when you want to have specific
# autoclass directives, make sure that the :nmembers: option is not
# set for automodule.
autodoc_default_flags = []

# Functions imported from C modules cannot be introspected, and therefore the
# signature for such functions cannot be automatically determined. However, it
# is an often-used convention to put the signature into the first line of the
# function’s docstring.
# If this boolean value is set to True (which is the default), autodoc will
# look at the first line of the docstring for functions and methods, and if it
# looks like a signature, use the line as the signature and remove it from the
# docstring content.
autodoc_docstring_signature = True

# This value contains a list of modules to be mocked up. This is useful when
# some external dependencies are not met at build time and break the building
# process.
autodoc_mock_imports = []


# -- Options for intersphinx extension ------------------------------------
# For documentation, see
# https://www.sphinx-doc.org/en/stable/ext/intersphinx.html

# Defines the prefixes for intersphinx links, and the targets they resolve to.
# Example RST source for 'py' prefix:
#     :func:`py:platform.dist`
#
# Note: The URLs apparently cannot be the same for two different IDs; otherwise
#       the links for one of them are not being created. A small difference
#       such as adding a trailing backslash is already sufficient to work
#       around the problem.
#
# Note: This mapping does not control how links to datatypes of function
#       parameters are generated.
# TODO: Find out how the targeted Python version for auto-generated links
#       to datatypes of function parameters can be controlled.
#
intersphinx_mapping = {
    'py': ('https://docs.python.org/3', None),  # default is Python 3
}

intersphinx_cache_limit = 5

# -- Options for extlinks extension ---------------------------------------
# For documentation, see
# https://www.sphinx-doc.org/en/stable/ext/extlinks.html
#
# Defines aliases for external links that can be used as role names.
#
# This config value must be a dictionary of external sites, mapping unique
# short alias names to a base URL and a prefix:
# * key: alias-name
# * value: tuple of (base-url, prefix)
#
# Example for the config value:
#
#   extlinks = {
#     'issue': ('https://github.com/sphinx-doc/sphinx/issues/%s', 'Issue ')
#   }
#
# The alias-name can be used as a role in links. In the example, alias name
# 'issue' is used in RST as follows:
#   :issue:`123`.
# This then translates into a link:
#   https://github.com/sphinx-doc/sphinx/issues/123
# where the %s in the base-url was replaced with the value between back quotes.
#
# The prefix plays a role only for the link caption:
# * If the prefix is None, the link caption is the full URL.
# * If the prefix is the empty string, the link caption is the partial URL
#   given in the role content ("123" in this case.)
# * If the prefix is a non-empty string, the link caption is the partial URL,
#   prepended by the prefix. In the above example, the link caption would be
#   "Issue 123".
#
# You can also use the usual "explicit title" syntax supported by other roles
# that generate links to set the caption. In this case, the prefix is not
# relevant.
# For example, this RST:
#   :issue:`this issue <123>`
# results in the link caption "this issue".

extlinks = {

}

# -- Support for autoautosummary ----------------------------------------------
#
# Idea taken from https://stackoverflow.com/a/30783465/1424462
#


class AutoAutoSummary(Autosummary):
    """
    Sphinx extension that automatically generates a table of public methods or
    attributes of a class, using the AutoSummary extension.
    (i.e. each row in the table shows the method or attribute name with a
    link to the full description, and a one-line brief description).

    Usage in RST source::

        .. autoclass:: path.to.class
           :<autoclass-options>:

           .. rubric:: Methods

           .. autoautosummary:: path.to.class
              :methods:

           .. rubric:: Attributes

           .. autoautosummary:: path.to.class
              :attributes:

           .. rubric:: Details

    """

    option_spec = {
        'methods': directives.unchanged,
        'attributes': directives.unchanged
    }
    option_spec.update(Autosummary.option_spec)

    required_arguments = 1  # Fully qualified class name

    def __init__(self, *args, **kwargs):
        self._logger = logging.getLogger(__name__)  # requires Sphinx 1.6.1
        self._log_prefix = "conf.py/AutoAutoSummary"
        self._excluded_classes = ['BaseException']
        super().__init__(*args, **kwargs)

    def _get_members(self, class_obj, member_type, include_in_public=None):
        """
        Return class members of the specified type.

        class_obj: Class object.

        member_type: Member type ('method' or 'attribute').

        include_in_public: set/list/tuple with member names that should be
          included in public members in addition to the public names (those
          starting without underscore).

        Returns:
          tuple(public_members, all_members): Names of the class members of
            the specified member type (public / all).
        """
        try:
            app = self.state.document.settings.env.app
        except AttributeError:
            app = None
        if not include_in_public:
            include_in_public = []
        all_members = []
        for member_name in dir(class_obj):
            try:
                documenter = get_documenter(
                    app,
                    safe_getattr(class_obj, member_name),
                    class_obj)
            except AttributeError:
                continue
            if documenter.objtype == member_type:
                all_members.append(member_name)
        public_members = [x for x in all_members
                          if x in include_in_public or not x.startswith('_')]
        return public_members, all_members

    def _get_def_class(self, class_obj, member_name):
        """
        Return the class object in MRO order that defines a member.

        class_obj: Class object that exposes (but not necessarily defines) the
          member. I.e. starting point of the search.

        member_name: Name of the member (method or attribute).

        Returns:
          Class object that defines the member.
        """
        for def_class_obj in inspect.getmro(class_obj):
            if member_name in def_class_obj.__dict__:
                if def_class_obj.__name__ in self._excluded_classes:
                    return class_obj  # Fall back to input class
                return def_class_obj
        self._logger.warning(
            "%s: Definition class not found for member %s.%s, "
            "defaulting to class %s",
            self._log_prefix, class_obj.__name__, member_name,
            class_obj.__name__)
        return class_obj  # Input class is better than nothing

    def run(self):

        try:
            full_class_name = str(self.arguments[0])
            module_name, class_name = full_class_name.rsplit('.', 1)
            module_obj = __import__(module_name, globals(), locals(),
                                    [class_name])
            class_obj = getattr(module_obj, class_name)
            if 'methods' in self.options:
                _, methods = self._get_members(
                    class_obj, 'method', ['__init__'])
                self.content = []
                for method in methods:
                    if method.startswith('_'):
                        # Skip private methods
                        continue
                    def_class = self._get_def_class(class_obj, method)
                    def_module_name = def_class.__module__
                    if def_module_name.startswith('nocasedict'):
                        def_module_name = def_module_name.split('.')[0]
                    content_str = \
                        f"~{def_module_name}.{def_class.__name__}.{method}"
                    self.content.append(content_str)
            elif 'attributes' in self.options:
                _, attributes = self._get_members(class_obj, 'attribute')
                self.content = []
                for attrib in attributes:
                    if attrib.startswith('_'):
                        # Skip private attributes
                        continue
                    def_class = self._get_def_class(class_obj, attrib)
                    def_module_name = def_class.__module__
                    if def_module_name.startswith('nocasedict'):
                        def_module_name = def_module_name.split('.')[0]
                    content_str = \
                        f"~{def_module_name}.{def_class.__name__}.{attrib}"
                    self.content.append(content_str)

        except Exception as exc:  # pylint: disable=broad-exception-caught
            self._logger.error(
                "%s: Internal error: %s: %s",
                self._log_prefix, exc.__class__.__name__, exc)

        return super().run()


def setup(app):
    """Additional Sphinx setup"""
    app.add_directive('autoautosummary', AutoAutoSummary)
