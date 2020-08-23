# Environments and macros for typesetting theorems, etc.

from plasTeX import Environment
from plasTeX.Packages.packageprefix import define_prefixed_exports

theorem_style_theorems = [
    'corollary', 'lemma', 'proposition', 'theorem'
]

definition_style_theorems = [
    'axiom', 'axioms', 'definition', 'definitions',
    'example', 'examples', 'exercise', 'exercises', 'notation',
    'postulate', 'postulates', 'primitiveNotion', 'primitiveNotions',
    'remark', 'remarks'
]

theorems = theorem_style_theorems + definition_style_theorems

theorem_to_name = {
    theorem: theorem.title() for theorem in theorems
}
theorem_to_name.update(
    primitiveNotion='Primitive notion',
    primitiveNotions='Primitive notions'
)

theorem_to_style = {
    theorem: ('theorem' if theorem in theorem_style_theorems
              else 'definition')
    for theorem in theorems
}

exports_to_be_prefixed = theorems + ['proof']


def ProcessOptions(options, document):
    define_prefixed_exports(
        options,
        document,
        exports_from_package=exports_to_be_prefixed,
        classes_in_package=globals(),
        prefix_in_package='theoremsetc_',
        default_prefix_in_document='THEOREMSETC',
    )
    document.context.newcounter(
        'theoremsetc_theorem', initial=0, resetby='section',
        format='${thesection}.${theoremsetc_theorem}'
    )
    # Create the 'theoremsetc_theoremname' macro.  See float.py and
    # subfig.py in plasTeX/Packages.  Without this, I get "WARNING:
    # unrecognized command/environment: theoremsetc_theoremname" when
    # I run plastex on a document.
    document.context.newcommand(
        'theoremsetc_theoremname', 0, 'theoremsetc_theorem'
    )
    document.context.newcounter(
        'theoremsetc_proof', initial=0, resetby='section',
        format='${thesection}.${theoremsetc_proof}'
    )
    document.context.newcommand(
        'theoremsetc_proofname', 0, 'theoremsetc_proof'
    )


for theorem in theorems:
    class_name = 'theoremsetc_' + theorem
    name = theorem_to_name[theorem]
    style = theorem_to_style[theorem]
    globals()[class_name] = type(
        class_name,
        (Environment,),
        {
            'args': '[ note ]',
            'blockType': True,
            'counter': 'theoremsetc_theorem',
            'forcePars': True,
            'theorem_raw_name': theorem,
            'theorem_name': name,
            'theorem_style': style
        }
    )


class theoremsetc_proof(Environment):
    args = '[ name ]'
    blockType = True
    counter = 'theoremsetc_proof'
    forcePars = True

# End of file
