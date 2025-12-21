Reference:
- https://github.com/jgm/pandoc

Create the pandoc feature by following the instructions and the patterns used in features/mdc:

Tasks:
- Create the features/pandoc folder with the required files:
  - install.sh: Installation script.
  - devcontainer-feature.json: Metadata and configuration options.
  - README.md: Documentation for the feature.

- Match the scripting pattern used in features/mdc:
  - Use utils.sh for shared utilities.
  - Use docker image pandoc/extra for pandoc docker base feature
  - Implement proper logging and error handling.
  - Validate system requirements (e.g., OS, architecture).

- Test the install.sh script:
  - Verify installation works as expected.
  - Test with different versions and configurations.

- Create a sample in folder examples/pandoc to let developer test the created feature, with required files:
  - .devcontainer/devcontainer.json: metadata and configuration options
  - readme.md: Documentation for how to use the feature

- Update the project root README.md:
  - Add the new feature to the list of available features.
  - Ensure the README reflects the current state of the repository.

---

Run command to test the feature aspire and fix all issues/errors during tests. Ensure feature will work properly and all tests must be passed.

Command:
```
./devcontainer-features.sh test aspire
```
