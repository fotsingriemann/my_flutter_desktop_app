[Setup]
AppName=my_flutter_desktop_app
AppVersion=1.0
DefaultDirName={pf}\my_flutter_desktop_app
DefaultGroupName=my_flutter_desktop_app
OutputDir=Output
OutputBaseFilename=setup

[Files]
Source: "build\windows\x64\runner\Release*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\my_flutter_desktop_app"; Filename: "{app}\my_flutter_desktop_app.exe"

