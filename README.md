If you run the install_all.bat file as an administrator, the following actions will take place:

•	Adobe Acrobat will be installed silently.
•	Bever Support will be installed silently.
•	Both themes, dark and light, will be added.
•	Google Chrome will be installed silently.
•	Registry keys will be added.
•	Power management settings will be adjusted so that the display does not turn off on battery or AC power. Additionally, high performance mode will be enabled on PCs.
•	Bever Support will then be copied to the desktop.

**Autounatted.xml**


This code is an XML configuration file used for automating the installation and setup of a Windows operating system. Here's a detailed breakdown of what each part does:

### Overall Structure
- The file defines various settings and commands to be executed during different phases of the Windows installation process. It uses XML namespaces to differentiate between elements.

### Phases
1. **offlineServicing**
   - This phase is empty in the provided code, but it typically includes updates and packages that need to be applied to the Windows image offline.

2. **windowsPE**
   - **Localization Settings**: Sets the user interface language, input locale, system locale, and user locale to Dutch (Netherlands).
   - **Disk Configuration**: Specifies commands to be run synchronously during the Windows Preinstallation Environment (Windows PE) phase to prepare the disk:
     - Selects disk 0 and cleans it.
     - Converts the disk to GPT (GUID Partition Table).
     - Creates and formats partitions, including an EFI system partition and a primary partition.
     - Bypasses hardware requirements checks by modifying registry settings.

3. **generalize**
   - This phase is empty but is usually used to prepare the Windows installation to be captured as an image.

4. **specialize**
   - **Disable Recovery Environment**: Disables Windows Recovery Environment (WinRE) and deletes its image file.
   - **Execute PowerShell Scripts**: Loads and executes a PowerShell script defined in the `unattend.xml` file to remove certain provisioned packages.
   - **Registry Modifications**: Configures various registry settings, including disabling widgets, setting start menu pins, and enabling Remote Desktop.

5. **auditSystem**
   - This phase is empty but is typically used for audit mode tasks.

6. **auditUser**
   - This phase is empty but is typically used for tasks that need to run under a specific user context during audit mode.

7. **oobeSystem**
   - **Localization Settings**: Sets the input locale, system locale, UI language, and user locale to Dutch (Netherlands).
   - **User Accounts**: Creates a local user account named "Gebruiker" with administrative privileges.
   - **Auto Logon**: Configures automatic logon for the "Gebruiker" account.
   - **OOBE (Out of Box Experience) Settings**: Hides certain setup pages and configures initial protection settings.
   - **First Logon Commands**: Sets up commands to run at the first logon, including modifying registry settings to disable auto logon after the first use.

### Extensions
- **Custom PowerShell Script**: Defines a script to extract files and another to remove specific provisioned apps like ZuneVideo and Solitaire.
- **LayoutModification.xml**: Provides a custom start menu layout, ensuring no predefined tiles are pinned.

### Summary
The XML file automates the installation of a Windows OS with specific regional settings, disk partitioning, bypassing of hardware checks, removal of certain built-in apps, and other customizations. The goal is to streamline the setup process and configure the system according to predefined requirements without manual intervention.
