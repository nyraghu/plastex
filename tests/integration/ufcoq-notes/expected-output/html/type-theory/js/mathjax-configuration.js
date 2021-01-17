// MathJax configuration

// Don't break lines between inline mathematics and adjacent
// characters if those characters are not whitespace characters.
// https://michaelallenwarner.github.io/webdev/2020/08/18/how-to-keep-
// inline-mathjax-and-adjacent-punctuation-on-the-same-line.html
const inlineEquationAdjustLineBreak = () => {
    const inlineEquationSelector = 'span.math';
    const inlineEquations = document.querySelectorAll(
        inlineEquationSelector
    );
    const nowrapClass = 'nowrap';

    for (const equation of inlineEquations) {
        const previous = equation.previousSibling;
        const previousIsText
              = previous && previous.nodeType === Node.TEXT_NODE;
        const previousCharacter
              = previousIsText ? previous.textContent.slice(-1) : '';
        const previousCharacterIsSpace = /\s/.test(previousCharacter);
        const previousCharacterNotSpace = ! previousCharacterIsSpace;

        const next = equation.nextSibling;
        const nextIsText
              = next && next.nodeType === Node.TEXT_NODE;
        const nextCharacter
              = nextIsText ? next.textContent[0] : '';
        const nextCharacterIsSpace = /\s/.test(nextCharacter);
        const nextCharacterNotSpace = ! nextCharacterIsSpace;

        if (previousCharacterIsSpace && nextCharacterIsSpace)
            continue;

        const span = document.createElement('span');
        span.classList.add(nowrapClass);
        equation.parentNode.replaceChild(span, equation);

        if (previousCharacterNotSpace) {
            previous.textContent = previous.textContent.slice(0, -1);
            span.appendChild(
                document.createTextNode(previousCharacter)
            );
        }

        span.appendChild(equation);

        if (nextCharacterNotSpace) {
            next.textContent = next.textContent.slice(1);
            span.appendChild(
                document.createTextNode(nextCharacter)
            );
        }
    }
};

window.MathJax = {
    tex: {
        tags: 'ams',
        tagSide: 'left'
    },

    startup: {
        ready() {
            window.MathJax.startup.defaultReady();
            window.MathJax.startup.promise.then(
                inlineEquationAdjustLineBreak
            );
        }
    }
};

// End of file
