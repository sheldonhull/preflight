# Markdown Linting Test Cases

This directory contains test cases to verify the markdown linting configuration works correctly.

## Test Files

- `before-formatting.md` - Sample markdown with formatting issues (multiple sentences per line)
- `expected-after-formatting.md` - Expected result after auto-formatting
- `run-test.sh` - Script to test the formatting behavior

## What Gets Tested

### Should Be Fixed (Sentence Splitting)

1. **Multiple sentences on one line** - Should be split into separate lines
2. **Sentences in paragraphs** - Each sentence should get its own line
3. **List items with multiple sentences** - Should be split appropriately
4. **Blockquotes** - Multiple sentences should be split

### Should NOT Be Modified (Preservation)

1. **Tables** - Should remain intact with all columns aligned
2. **Code blocks** - Should be preserved exactly as written
3. **Inline code** - Should not be split even with periods
4. **Table cells** - Multiple sentences in cells should remain together

## Running Tests

### With Docker

```bash
# From repository root
cd test-cases/markdown-linting
./run-test.sh
```

### Manual Testing

```bash
# Copy the test file
cp before-formatting.md test-output.md

# Run formatting
docker run --rm \
  -v "$(pwd):/workspace" \
  -w /workspace \
  lefthook/markdownlint-cli2:latest \
  markdownlint-cli2 --fix test-output.md

# Compare results
diff test-output.md expected-after-formatting.md
```

### With Lefthook

```bash
# From repository root
lefthook run pre-commit
# This will format all markdown files including test cases
```

## Expected Behavior

After running the formatter on `before-formatting.md`:

1. Sentences like "This is one. This is two." become:
   ```markdown
   This is one.
   This is two.
   ```

2. Tables remain formatted:
   ```markdown
   | Col1 | Col2 |
   |------|------|
   | A    | B    |
   ```

3. Code blocks are unchanged:
   ````markdown
   ```bash
   echo "Multiple. Sentences. Here."
   ```
   ````

## Troubleshooting

If tests fail:

1. Check that the Docker image is built: `docker images | grep markdownlint`
2. Verify the config file exists: `.markdownlint-cli2.yaml` in the repo root
3. Check for conflicting config files in your home directory
4. Run with verbose output: `markdownlint-cli2 --fix test-output.md --verbose`
