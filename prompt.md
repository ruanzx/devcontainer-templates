Create the Azure Functions Core Tools feature by following the instructions and the patterns used in features/edit:

Tasks:
- Create the features/azure-functions-core-tools folder with the required files:
  - install.sh: Installation script for Azure Functions Core Tools.
  - devcontainer-feature.json: Metadata and configuration options.
  - README.md: Documentation for the feature.

- Match the scripting pattern used in features/edit:
  - Use utils.sh for shared utilities.
  - Implement proper logging and error handling.
  - Validate system requirements (e.g., OS, architecture).

- Test the install.sh script:
  - Verify installation works as expected.
  - Test with different versions and configurations.

- Create a sample in folder examples/azure-functions-core-tools to let developer test the created feature, with required files:
  - .devcontainer/devcontainer.json: metadata and configuration options
  - readme.md: Documentation for how to use the feature

- Update the project root README.md:
  - Add the new feature to the list of available features.
  - Ensure the README reflects the current state of the repository.