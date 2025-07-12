# FR ZSH (A fork of LH ZSH)

Welcome to my Shell config

## Special thanks
First and foremost, I'd like to thank my very good friend Leon for creating this wonderful ZSH configuration.
If you're looking for a well-maintained and actively developed ZSH config, I highly recommend checking out his **original repo**!(https://github.com/AWildLeon/LH-ZSH)

All credit for the current configuration, structure, and design goes to Leon. If you want the best experience, use his version, since this fork is being used only for private deployment.
## Key Features

### Managed Configuration File

The core configuration file of FR ZSH is managed by the project, which means any manual modifications to this file will be overwritten during an update. Users are encouraged to use provided mechanisms for customization, ensuring their changes are preserved across updates.

### Environment Variables

- **FRZSH_INSTBASE**: The installation base directory for FR ZSH, defaulted to `$HOME/.frzsh`.
- **FRZSH_BASEURL**: The base URL from which FR ZSH files are fetched.

### Update Mechanism

FR ZSH periodically checks for updates to the configuration and related scripts:

- **Update Conditions**: The update only proceeds if the local version (`$FRZSH_INSTBASE/version`) does not match the remote version fetched from GitHub. The remote version is fetched from the latest commit to the GitHub repository `FReichelt/FR-ZSH`.
- **Prompt for Update**: If a new version is available, the user is prompted to approve the update. If declined, the configuration remains unchanged.
- **Changelog**: If an update is approved, the script fetches and displays a changelog between the local and remote versions.
- **Automatic Updates**: The frequency of automatic updates can be controlled using `zstyle ':omz:update' frequency`.

### Customization Options

#### Custom Scripts

FR ZSH supports user customization by allowing you to add custom scripts at various stages:

- **Start Script**: `~/.frzsh.custom/start.zsh` - Loaded at the start of the script, if it exists.
- **Plugins Script**: `~/.frzshrc.custom/plugins.zsh` - Loaded to extend or modify plugins, if it exists.
- **End Script**: `~/.frzshrc.custom/end.zsh` - Loaded at the end of the script, if it exists.

#### Plugins

FR ZSH provides a default set of plugins that can be customized depending on the operating system:

- **Default Plugins**: `git`, `docker`, `docker-compose`, `systemd`, `vscode`, `zoxide`.
- **Distro-Specific Plugin**: Depending on your system, either `archlinux`, `dnf`, or `debian` plugin is loaded.

You can add your custom plugins through the custom plugins script (`~/.frzshrc.custom/plugins.zsh`).

### Prompt Engine

FR ZSH uses [Oh My Posh](https://ohmyposh.dev/) to style the ZSH prompt:

- **Configuration File**: The prompt configuration is defined in `$FRZSH_INSTBASE/theme.omp.json`.
- **Command**: The prompt engine is initialized via `eval "$(oh-my-posh init zsh --config $LHZSH_INSTBASE/theme.omp.json)"`.

### Aliases and Environment Settings

- **Aliases**:
  - `cd=z`: Uses `zoxide` for faster directory navigation.
- **Path Extensions**: Adds `$HOME/.local/bin` to the PATH variable to ensure local executables can be run easily.

### Greetings and Miscellaneous

- **Greeting on Shell Load**: Displays system information using `fastfetch` if the shell is interactive. Uncommented lines in the file allow for customization of this behavior (e.g., to display network information).
- **Environment Cleanup**: Clears environment variables related to FR ZSH after sourcing the necessary scripts.

## Installation

To install FR ZSH, run the following command:

```sh
bash <(curl https://zsh.onfr.de)
```

This will install the necessary components and set up your `.zshrc` to use the managed configuration.

## Important Notes

- **Warning**: Manual changes to the managed configuration file will be overwritten by FR ZSH updates. To persist changes, use the custom scripts options mentioned above.
- **Update Handling**: You can disable the automatic update check by setting the variable `NOTRECOMENDED_DONTUPDATE`.

## Contributing

If you have suggestions or issues with FR/LH ZSH, you can contribute to the GitHub repository of this fork[FReichelt/FR-ZSH/](https://github.com/FReichelt/FR-ZSH/) or the original[AWildLeon/LH-ZSH](https://github.com/AWildLeon/LH-ZSH).

### How to Contribute

1. **Fork the Repository**: Create your own fork of the project.
2. **Make Your Changes**: Develop your feature or fix on a new branch.
3. **Submit a Pull Request**: Once your changes are ready, submit a pull request to the main repository.

Please ensure your code adheres to the style and conventions used throughout the project.

## License

This configuration is open-source, and contributions are welcome. Please follow the guidelines in the repository for submitting pull requests or reporting issues.

---

For any further questions or customizations, please refer to the `oh-my-zsh` and `Oh My Posh` documentation.
