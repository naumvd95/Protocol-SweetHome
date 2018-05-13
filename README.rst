**Protocol-SweetHome**
======================

Scripts for deployment workspace from scratch on MacOs



Requirements:
~~~~~~~~~~~~~

#. Brew
#. Git
#. Macports
#. Vundle
#. Xcode
#. Python
#. Pip
#. Docker
#. Iterm2
#. Tunnelblick
#. Karabiner elements


Backup:
~~~~~~~

#. .bashrc
#. .zshrc
#. .vimrc
#. List with workspace repos
#. Workspace scripts
#. Sensitive Data


Optional:
~~~~~~~~~

#. Parallels
#. VirtualBox 
#. DaisyDisk 


Process:
--------

1. Clone this repo on current workspace setup:

  .. code-block:: bash

     git clone  https://github.com/naumvd95/Protocol-SweetHome.git
     cd Protocol-SweetHome

2. Backup sensitive data: 

  .. code-block:: bash

     bash backup.sh
     git add --all
     ID=$(date)
     git commit -m 'Backup for transfer from $ID'
     git push origin master


3. Clone this repo on new Mac.

4. Run setup initiative: 

  .. code-block:: bash

     bash setup.sh

5. Configure terminal: 

* `Iterm+zsh <https://gist.github.com/naumvd95/10754331e64430f2861944a093347504>`_.
* `Iterm schemes <https://iterm2colorschemes.com>`_.
* `Iterm schemes repo <https://github.com/mbadolato/iTerm2-Color-Schemes>`_.

