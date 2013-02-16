# Contributing

If you want to contribute to the project just follow this steps:

1. Fork the repository.
2. Run the tests. Only pull request with passing test will be considered, so its better to start with a clean slate. The project at `Project/DRTPFObjectDynamicPropertiesTest` contains a GHUnit target with all the tests.
3. Include a test for your changes if you are adding some new functionality or fixing a bug. Your test should fail without your code, and pass with it. Refactorings and documentation does not require new tests.
4. Make all the tests pass.
5. Make sure you have updated the documentation, the surrounding code comments, examples elsewhere, and whatever might be affected by your contribution.
6. Push to your fork and submit a pull request.

## Code style

- Two spaces, no tabs. The project is configured for that. Xcode should honor the settings.
- No trailing whitespace. Blank lines should not have any space.
- No spaces inside parenthesis. No space after function names. A space after `if`, `while`, `do`, `switch`. Spaces around operators.
- Braces in a line of its own, at the same indentation than the surrounding block.
- Generally, just follow the rest of the code you see around.
