"""
Utility functions for N-gram analysis and text processing.
"""

from typing import List, Tuple, Iterator
import re


def clean_text(text: str, lowercase: bool = True, remove_punctuation: bool = True) -> str:
    """
    Clean and preprocess text.

    Args:
        text: Input text to clean
        lowercase: Convert to lowercase if True
        remove_punctuation: Remove punctuation if True

    Returns:
        Cleaned text
    """
    if lowercase:
        text = text.lower()

    if remove_punctuation:
        text = re.sub(r'[^\w\s]', '', text)

    # Remove extra whitespace
    text = ' '.join(text.split())

    return text


def tokenize(text: str) -> List[str]:
    """
    Simple tokenization by splitting on whitespace.

    Args:
        text: Input text

    Returns:
        List of tokens
    """
    return text.split()


def generate_ngrams(tokens: List[str], n: int) -> List[Tuple[str, ...]]:
    """
    Generate n-grams from a list of tokens.

    Args:
        tokens: List of tokens
        n: Size of n-grams (e.g., 2 for bigrams, 3 for trigrams)

    Returns:
        List of n-gram tuples
    """
    if n < 1:
        raise ValueError("n must be at least 1")

    if len(tokens) < n:
        return []

    return [tuple(tokens[i:i+n]) for i in range(len(tokens) - n + 1)]


def ngrams_to_strings(ngrams: List[Tuple[str, ...]]) -> List[str]:
    """
    Convert n-gram tuples to space-separated strings.

    Args:
        ngrams: List of n-gram tuples

    Returns:
        List of n-gram strings
    """
    return [' '.join(ngram) for ngram in ngrams]


def get_ngram_frequencies(ngrams: List[Tuple[str, ...]]) -> dict:
    """
    Count the frequency of each n-gram.

    Args:
        ngrams: List of n-gram tuples

    Returns:
        Dictionary mapping n-grams to their frequencies
    """
    frequencies = {}
    for ngram in ngrams:
        frequencies[ngram] = frequencies.get(ngram, 0) + 1
    return frequencies


def sliding_window(sequence: List, window_size: int, step: int = 1) -> Iterator[List]:
    """
    Generate sliding windows over a sequence.

    Args:
        sequence: Input sequence
        window_size: Size of each window
        step: Step size between windows

    Yields:
        Windows of the specified size
    """
    for i in range(0, len(sequence) - window_size + 1, step):
        yield sequence[i:i + window_size]
