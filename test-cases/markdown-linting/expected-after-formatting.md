# Test Document for Markdown Linting

## Purpose

This document tests the markdown linting configuration.
It should be automatically formatted by the pre-commit hook.
The sentences-per-line plugin should split multiple sentences on the same line.

## Multiple Sentences Per Line

This is the first sentence.
This is the second sentence.
And here is a third sentence for good measure.

Here's another paragraph with multiple sentences.
Each sentence should be on its own line after formatting.
This makes Git diffs much cleaner and easier to review.

## Tables Should Not Be Broken

Tables should remain intact and not be split by the sentences-per-line rule:

| Column 1 | Column 2 | Column 3 |
|----------|----------|----------|
| Data 1   | Data 2   | Data 3   |
| More data here | And some more | Final column |
| Row 3 | With multiple | Columns here |

The table above should remain properly formatted with all cells intact.

## Lists

- This is a list item.
  It has multiple sentences.
  Both should be handled correctly.
- Another list item here.
  It also has multiple sentences in it.
  The formatter should handle this properly.
- Final item

1. Numbered list item one.
   It has a second sentence.
   And even a third one.
2. Numbered list item two.
   Also with multiple sentences.
   This should work fine.
3. Third item

## Code Blocks

Code blocks should be preserved as-is:

```bash
# This is a comment. It has multiple sentences. They should not be split.
echo "This is a string. It has multiple sentences. They should not be modified."
```

Inline code should also be preserved: `echo "Hello. World. Test."` should remain on one line.

## Blockquotes

> This is a blockquote.
> It contains multiple sentences.
> They should be split appropriately.

## Edge Cases

### Sentences with periods in abbreviations

Dr. Smith works at the hospital.
He specializes in cardiology.
His office is on Main St. in the medical building.

### Sentences with numbers

The version is 1.2.3.
The next version will be 2.0.0.
We plan to release it in Q4 2024.

### Mixed content

Here's a sentence with inline `code.block.here`.
And another sentence.
The code should not be split even though it has periods.

## Complex Table

| Feature | Description | Status | Notes |
|---------|-------------|--------|-------|
| Sentence splitting | Splits multiple sentences onto separate lines. Works automatically. | ✅ Done | Should handle this correctly. |
| Table preservation | Keeps tables intact. Does not split cells. | ✅ Done | This is important for readability. Tables should remain formatted. |
| Code block handling | Preserves code blocks exactly as written. No modifications. | ✅ Done | Critical for code examples. Must not alter syntax. |

## Conclusion

This document contains various test cases.
The formatter should handle all of them correctly.
Sentences should be split.
Tables should remain intact.
Code blocks should be preserved.
After running the formatter, we can verify that everything works as expected.
