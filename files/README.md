# Resource files

Generally, most things should go into "files\temp" subfolder; the installer scripts will use these files and then delete them. If a file is required after the image build is complete (such as a user logon script), you can place it in a different folder. If you need a persistent file outside of the itopia folder structure, place it in "files\temp" and have the install script copy it to the correct place.

The folders map as:
- temp → C:\Temp
- itopia → C:\Program Files\itopia
    - All subfolders map directly
