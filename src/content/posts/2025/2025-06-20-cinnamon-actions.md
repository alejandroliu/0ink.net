---
title: Nemo file explorer custom actions
date: "2025-06-04"
author: alex
tags: linux, browser, feature, power, terminal, editor, sudo, directory, manager
---
[toc]
***

# Adding a "Copy File Path" Option to Nemo in Linux Cinnamon  

The **Nemo** file browser in **Linux Cinnamon** is highly customizable, allowing users to
tweak its functionality to suit their workflow. One useful feature missing by default is a
**right-click menu option** to copy a file's full path to the clipboard—an essential shortcut
for developers, power users, and anyone working with file paths regularly.

Note that you could simply download the
[Copy Path to Cliboard](https://cinnamon-spices.linuxmint.com/actions/view/40)
from [Cinnamon Spices](https://cinnamon-spices.linuxmint.com/), the __official__
addons repository.

In this guide, we'll show you how to add this feature by creating a **Nemo Action**, both for
individual users and system-wide use manually.


## Step 1: Create a Nemo Action File  

First, we need to create a `.nemo_action` file that tells Nemo how to handle the new menu option.  

- Open a terminal and navigate to the **actions** folder:  
  ```bash
  mkdir -p ~/.local/share/nemo/actions
  cd ~/.local/share/nemo/actions
  ```

- Create a new file:  
  ```bash
  touch copy_path.nemo_action
  ```

## Step 2: Define the Action  

Edit the `copy_path.nemo_action` file in your favorite text editor and add the following content:

```ini
[Nemo Action]
Name=Copy Full Filepath
Comment=Copies the full path of the selected file
Exec=sh -c "readlink -f %F | xclip -selection clipboard"
Icon-Name=edit-copy
Selection=notnone
Extensions=nodirs
Dependencies=readlink;xclip;
```

### Explanation of Key Parameters:  
- **Name**: Defines the name appearing in the right-click menu.  
- **Exec**: Runs a command using `readlink` (to get the full path) and `xclip` (to copy it to
  the clipboard).  
- **Selection & Extensions**: Ensures it only applies to files, not directories.  


## Step 3: Install Required Dependencies  

Ensure `xclip` is installed, as it handles clipboard copying:

```bash
sudo apt install xclip
```


## Step 4: Restart Nemo  

To apply the changes, restart Nemo:

```bash
nemo --quit && nemo &
```

Now, when you **right-click** a file, you should see the **"Copy Full Filepath"** option. Clicking it copies the selected file's full path to the clipboard!


## Step 5: Make It Available for All Users (Optional)  

If you want all users on the system to have access to this feature, place the `.nemo_action` file in the system-wide **Nemo actions directory**:

```bash
sudo mv ~/.local/share/nemo/actions/copy_path.nemo_action /usr/share/nemo/actions/
```

Ensure proper permissions:  

```bash
sudo chmod 644 /usr/share/nemo/actions/copy_path.nemo_action
sudo chown root:root /usr/share/nemo/actions/copy_path.nemo_action
```

Restart Nemo once again:

```bash
nemo --quit && nemo &
```

Now, **all users** on the system should have the "Copy Full Filepath" option available!


# Variations

It is possible to restrict the custom action to specific conditions.  For example
if I want the action only to be available in a user's `~/custom` directory you can add
to the action defintion file:

```ini
Conditions=path =~ ~/custom/
```
You could also use `Conditions=path matches $HOME/custom/*` to specify the path.


# Other conditions


The `"Conditions"` field in Nemo actions allows you to specify when an action should be
available. Here are some common options:

- **`mime`**: Restrict the action to specific file types (e.g., `mime=text/plain` for text files).
- **`name`**: Match specific filenames (e.g., `name=*.txt` for all `.txt` files).
- **`path`**: Limit the action to certain directories (e.g., `path matches $HOME/special/*`).
- **`selection`**: Define how many files must be selected (e.g., `selection=1` for single-file actions).
- **`exec`**: Ensure a command exists before showing the action (e.g., `exec=command-name`).
- **`extension`**: Restrict based on file extensions (e.g., `extension=png,jpg` for images).

You can combine multiple conditions to fine-tune when your action appears.


# Conclusion  

Adding custom **Nemo Actions** is a powerful way to extend the functionality of your
**Linux Cinnamon** file manager. With just a few simple steps, you now have a 
**quick and efficient way** to copy file paths—saving time and effort, especially in
development workflows.  



