# LH ZSH

Welcome to my Shell config.

## Key Features

### Managed Configuration File

The core configuration file of LH ZSH is managed by the project, which means any manual modifications to this file will be overwritten during an update. Users are encouraged to use provided mechanisms for customization, ensuring their changes are preserved across updates.

### Environment Variables

- **LHZSH_INSTBASE**: The installation base directory for LH ZSH, defaulted to `$HOME/.lhzsh`.
- **LHZSH_BASEURL**: The base URL from which LH ZSH files are fetched.

### Update Mechanism

LH ZSH periodically checks for updates to the configuration and related scripts:

- **Update Conditions**: The update only proceeds if the local version (`$LHZSH_INSTBASE/version`) does not match the remote version fetched from GitHub. The remote version is fetched from the latest commit to the GitHub repository `Games-Crack/shellconfig`.
- **Prompt for Update**: If a new version is available, the user is prompted to approve the update. If declined, the configuration remains unchanged.
- **Changelog**: If an update is approved, the script fetches and displays a changelog between the local and remote versions.
- **Automatic Updates**: The frequency of automatic updates can be controlled using `zstyle ':omz:update' frequency`.

### Customization Options

#### Custom Scripts

LH ZSH supports user customization by allowing you to add custom scripts at various stages:

- **Start Script**: `~/.lhzsh.custom/start.zsh` - Loaded at the start of the script, if it exists.
- **Plugins Script**: `~/.lhzshrc.custom/plugins.zsh` - Loaded to extend or modify plugins, if it exists.
- **End Script**: `~/.lhzshrc.custom/end.zsh` - Loaded at the end of the script, if it exists.

#### Plugins

LH ZSH provides a default set of plugins that can be customized depending on the operating system:

- **Default Plugins**: `git`, `docker`, `docker-compose`, `systemd`, `vscode`, `zoxide`.
- **Distro-Specific Plugin**: Depending on your system, either `archlinux`, `dnf`, or `debian` plugin is loaded.

You can add your custom plugins through the custom plugins script (`~/.lhzshrc.custom/plugins.zsh`).

### Prompt Engine

LH ZSH uses [Oh My Posh](https://ohmyposh.dev/) to style the ZSH prompt:

- **Configuration File**: The prompt configuration is defined in `$LHZSH_INSTBASE/theme.omp.json`.
- **Command**: The prompt engine is initialized via `eval "$(oh-my-posh init zsh --config $LHZSH_INSTBASE/theme.omp.json)"`.

### Aliases and Environment Settings

- **Aliases**:
  - `cd=z`: Uses `zoxide` for faster directory navigation.
- **Path Extensions**: Adds `$HOME/.local/bin` to the PATH variable to ensure local executables can be run easily.

### Greetings and Miscellaneous

- **Greeting on Shell Load**: Displays system information using `fastfetch` if the shell is interactive. Uncommented lines in the file allow for customization of this behavior (e.g., to display network information).
- **Environment Cleanup**: Clears environment variables related to LH ZSH after sourcing the necessary scripts.

## Installation

To install LH ZSH, run the following command:

```sh
bash <(curl https://zsh.onlh.de)
```

This will install the necessary components and set up your `.zshrc` to use the managed configuration.

## Important Notes

- **Warning**: Manual changes to the managed configuration file will be overwritten by LH ZSH updates. To persist changes, use the custom scripts options mentioned above.
- **Update Handling**: You can disable the automatic update check by setting the variable `NOTRECOMENDED_DONTUPDATE`.

## Contributing

If you have suggestions or issues with LH ZSH, you can contribute to the GitHub repository [Games-Crack/shellconfig](https://github.com/Games-Crack/shellconfig).

### How to Contribute

1. **Fork the Repository**: Create your own fork of the project.
2. **Make Your Changes**: Develop your feature or fix on a new branch.
3. **Submit a Pull Request**: Once your changes are ready, submit a pull request to the main repository.

Please ensure your code adheres to the style and conventions used throughout the project.

## License

This configuration is open-source, and contributions are welcome. Please follow the guidelines in the repository for submitting pull requests or reporting issues.

---

For any further questions or customizations, please refer to the `oh-my-zsh` and `Oh My Posh` documentation.
