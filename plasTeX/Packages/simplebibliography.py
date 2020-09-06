# Simple processing of BibLaTeX bibliographies

from collections import namedtuple
from pathlib import Path
from xml.etree.ElementTree import parse

from plasTeX import Command
from plasTeX.Base.LaTeX.Sectioning import section
from plasTeX.Packages.packageprefix import define_prefixed_exports

# ====================================================================
# Global variables
# ====================================================================

NAMESPACES = {
    'bl': 'http://biblatex-biber.sourceforge.net/biblatexml'
}

BIBLIOGRAPHY_HTML_FILE_NAME = 'bibliography.html'

# ====================================================================
# Namespace prefix option
# ====================================================================

exports_to_be_prefixed = [
    'addbibresource', 'cite', 'printbibliography'
]


def ProcessOptions(options, document):
    define_prefixed_exports(
        options,
        document,
        exports_from_package=exports_to_be_prefixed,
        classes_in_package=globals(),
        prefix_in_package='simplebibliography_',
        default_prefix_in_document='SIMPLEBIBLIOGRAPHY',
    )

# ====================================================================
# Macros
# ====================================================================


class simplebibliography_addbibresource(Command):
    args = 'name:str'

    def invoke(self, tex) -> None:
        super().invoke(tex)
        name = self.attributes['name']
        stem = Path(name).stem
        suffix = '.bltxml'
        filename = stem + suffix
        metadata = self.ownerDocument.userdata
        file = tex.kpsewhich(filename)
        metadata['bibliography_file'] = file
        path = Path(file)
        with path.open() as source:
            tree = parse(source)
        metadata['bibliography_tree'] = tree
        metadata['citations'] = {}


class simplebibliography_cite(Command):
    args = '[ note ] key:str'
    creator = None
    bibliography_entry_number = None
    bibliography_link_target = None

    def invoke(self, tex):
        result = super().invoke(tex)
        current_key = self.attributes['key']
        metadata = self.ownerDocument.userdata
        tree = metadata['bibliography_tree']
        entry_element = tree.find(
            f'bl:entry[@id="{current_key}"]', NAMESPACES
        )
        author_elements = entry_element.findall(
            'bl:names[@type="author"]/'
            'bl:name/bl:namepart[@type="family"]',
            NAMESPACES
        )
        names = [element.text for element in author_elements]
        self.creator = truncate(names)
        self.bibliography_entry_number = position(
            tree.getroot(), entry_element
        )
        self.bibliography_link_target = (
            f'{BIBLIOGRAPHY_HTML_FILE_NAME}#{current_key}'
        )
        citations_table = metadata['citations']
        current_citations = citations_table.get(current_key, [])
        citations_table[current_key] = current_citations + [self]
        return result


class simplebibliography_printbibliography(section):
    linkType = 'bibliography'
    entries = {}

    def invoke(self, tex):
        result = super().invoke(tex)
        self.title = (
            self.ownerDocument
                .createElement('refname')
                .expand(tex)
        )
        self.id = self.title.textContent.lower()
        self.ref = None
        document = self.ownerDocument
        metadata = document.userdata
        tree = metadata['bibliography_tree']
        allowed_entrytypes = ['article', 'book']
        entry_elements = [
            element for element in list(tree.getroot())
            if entrytype(element) in allowed_entrytypes
        ]
        self.entries = {
            key(entry_element): create_entry(
                entry_element, document, tex
            )
            for entry_element in entry_elements
        }
        return result

    @property
    def filenameoverride(self):
        return BIBLIOGRAPHY_HTML_FILE_NAME

# ====================================================================
# Classes for bibliography entries
# ====================================================================


class Entry:
    def __init__(self, entry_element, document, tex):
        self.key = key(entry_element)
        self.authors = authors(entry_element)
        self.title = title(entry_element, tex)
        self.subtitle = subtitle(entry_element, tex)
        self.volume = volume(entry_element)
        self.year = year(entry_element)
        self.doi = doi(entry_element)
        self.arxiv = arxiv(entry_element)
        self.url = url(entry_element)
        self.citations = citations(entry_element, document)


class Article(Entry):
    entrytype = 'article'

    def __init__(self, entry_element, document, tex):
        super().__init__(entry_element, document, tex)
        self.xref_key, self.xref_entry_number = xref(
            entry_element, document
        )
        self.start_page, self.end_page = pages(entry_element)
        self.journaltitle = journaltitle(entry_element)
        self.shortjournal = shortjournal(entry_element)
        self.journal = journal(entry_element)


class Book(Entry):
    entrytype = 'book'

    def __init__(self, entry_element, document, tex):
        super().__init__(entry_element, document, tex)
        self.editors = editors(entry_element)
        self.edition = edition(entry_element)
        self.series = series(entry_element)
        self.publisher = publisher(entry_element)


# ====================================================================
# Factory function for creating bibliography entry classes
# ====================================================================


def create_entry(entry_element, document, tex):
    kind = entrytype(entry_element)
    if kind == 'article':
        return Article(entry_element, document, tex)
    else:
        return Book(entry_element, document, tex)

# ====================================================================
# Functions to dissect a BibLaTeXML entry element
# ====================================================================


def arxiv(entry_element):
    arxiv_element = entry_element.find('bl:arxiv', NAMESPACES)
    if arxiv_element is not None:
        return arxiv_element.text


def authors(entry_element):
    name_elements = entry_element.findall(
        'bl:names[@type="author"]/bl:name', NAMESPACES
    )
    authors_list = [
        create_name(name_element)
        for name_element in name_elements
    ]
    return format_names(authors_list)


def citations(entry_element, document):
    metadata = document.userdata
    key_to_citations = metadata['citations']
    current_key = key(entry_element)
    current_citations = key_to_citations.get(current_key, [])
    return current_citations


def doi(entry_element):
    doi_element = entry_element.find('bl:doi', NAMESPACES)
    if doi_element is not None:
        return doi_element.text


def edition(entry_element):
    edition_element = entry_element.find('bl:edition', NAMESPACES)
    if edition_element is not None:
        content = edition_element.text
        suffix = 'ed.'
        if content.isdecimal():
            main = ordinal(int(content))
            return f'{main} {suffix}'
        return content


def editors(entry_element):
    name_elements = entry_element.findall(
        'bl:names[@type="editor"]/bl:name', NAMESPACES
    )
    editors_list = [
        create_name(name_element)
        for name_element in name_elements
    ]
    main = format_names(editors_list)
    count = len(editors_list)
    suffix = 'ed.' if count == 1 else 'eds.'
    if count > 0:
        return f'{main} ({suffix})'


def entrytype(entry_element):
    return entry_element.get('entrytype')


def journal(entry_element):
    short = shortjournal(entry_element)
    full = journaltitle(entry_element)
    return full if short is None else short


def journaltitle(entry_element):
    journaltitle_element = entry_element.find(
        'bl:journaltitle', NAMESPACES
    )
    if journaltitle_element is not None:
        return journaltitle_element.text


def key(entry_element):
    return entry_element.get('id')


def pages(entry_element):
    start = entry_element.find(
        'bl:pages/bl:list/bl:item/bl:start', NAMESPACES
    )
    start_page = None if start is None else start.text
    end = entry_element.find(
        'bl:pages/bl:list/bl:item/bl:end', NAMESPACES
    )
    end_page = None if end is None else end.text
    return start_page, end_page


def publisher(entry_element):
    publisher_element = entry_element.find(
        'bl:publisher/bl:list/bl:item', NAMESPACES
    )
    if publisher_element is not None:
        return publisher_element.text


def series(entry_element):
    series_element = entry_element.find('bl:series', NAMESPACES)
    if series_element is not None:
        return series_element.text


def shortjournal(entry_element):
    shortjournal_element = entry_element.find(
        'bl:shortjournal', NAMESPACES
    )
    if shortjournal_element is not None:
        return shortjournal_element.text


def subtitle(entry_element, tex):
    subtitle_element = entry_element.find('bl:subtitle', NAMESPACES)
    if subtitle_element is not None:
        return tex.expandTokens(subtitle_element.text)


def title(entry_element, tex):
    title_element = entry_element.find('bl:title', NAMESPACES)
    return tex.expandTokens(title_element.text)


def volume(entry_element):
    volume_element = entry_element.find('bl:volume', NAMESPACES)
    if volume_element is not None:
        return volume_element.text


def year(entry_element):
    year_element = entry_element.find('bl:date', NAMESPACES)
    if year_element is not None:
        return year_element.text


def url(entry_element):
    url_element = entry_element.find('bl:url', NAMESPACES)
    if url_element is not None:
        return url_element.text


def xref(entry_element, document):
    xref_element = entry_element.find('bl:xref', NAMESPACES)
    metadata = document.userdata
    tree = metadata['bibliography_tree']
    if xref_element is None:
        xref_key = None
        xref_entry_number = None
    else:
        xref_key = xref_element.text
        xref_entry = tree.find(
            f'bl:entry[@id="{xref_key}"]', NAMESPACES
        )
        xref_entry_number = position(
            tree.getroot(), xref_entry
        )
    return xref_key, xref_entry_number

# ====================================================================
# Helper functions
# ====================================================================


NamePart = namedtuple('NamePart', ['full', 'initial'])
Name = namedtuple('Name', ['family_name', 'given_names'])


def create_name(name_element):
    family_element = name_element.find(
        'bl:namepart[@type="family"]', NAMESPACES
    )
    family_full = family_element.text
    family_initial = family_element.get('initial')
    family_name = NamePart(family_full, family_initial)

    given_child = name_element.find(
        'bl:namepart[@type="given"]', NAMESPACES
    )
    given_child_initial = given_child.get('initial')
    if given_child_initial is None:
        given_elements = given_child.findall(
            'bl:namepart', NAMESPACES
        )
    else:
        given_elements = [given_child]
    given_names = [
        NamePart(element.text, element.get('initial'))
        for element in given_elements
    ]

    return Name(family_name, given_names)


def format_names(names):
    def format_(name):
        given_names_string = ' '.join(
            f'{given_name.initial}.'
            for given_name in name.given_names
        )
        family_name_string = name.family_name.full
        return f'{given_names_string} {family_name_string}'

    count = len(names)
    if count == 0:
        return ''
    if count == 1:
        return format_(names[0])
    if count == 2:
        return '%s and %s' % (
            format_(names[0]), format_(names[1])
        )
    if count >= 3:
        comma_part = ', '.join(
            format_(name) for name in names[:-1]
        )
        and_part = f', and {format_(names[-1])}'
        return comma_part + and_part


def ordinal(number):
    if 11 <= number <= 19:
        suffix = 'th'
        return f'{number}{suffix}'
    units_digit_to_suffix = {
        1: 'st', 2: 'nd', 3: 'rd'
    }
    for digit in range(9):
        units_digit_to_suffix.setdefault(digit, 'th')
    suffix = units_digit_to_suffix[number % 10]
    return f'{number}{suffix}'


def position(element, child):
    return list(element).index(child) + 1


def truncate(names):
    count = len(names)
    if count == 0:
        return ''
    if count == 1:
        return names[0]
    if count == 2:
        return f'{names[0]} and {names[1]}'
    if count == 3:
        return f'{names[0]}, {names[1]}, and {names[2]}'
    return f'{names[0]} et al.'

# End of file
