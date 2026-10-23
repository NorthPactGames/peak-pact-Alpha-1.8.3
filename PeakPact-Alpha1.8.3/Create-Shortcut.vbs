
Option Explicit
Dim sh, fso, install, target, ico, desktop, lnk, s, folders, i, d, ok
Set sh = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")
install = sh.ExpandEnvironmentStrings("%LOCALAPPDATA%") & "\PeakPact"
target = install & "\PeakPact.vbs"
ico = install & "\peak-pact.ico"
If Not fso.FileExists(ico) Then ico = install & "\game\peak-pact.ico"
If Not fso.FileExists(target) Then
  MsgBox "PeakPact.vbs not found in " & install & vbCrLf & "Run Install-PeakPact.bat first.", 16, "Peak Pact"
  WScript.Quit 1
End If

folders = Array( _
  sh.SpecialFolders("Desktop"), _
  sh.ExpandEnvironmentStrings("%USERPROFILE%\Desktop"), _
  sh.ExpandEnvironmentStrings("%USERPROFILE%\OneDrive\Desktop"), _
  sh.ExpandEnvironmentStrings("%USERPROFILE%\OneDrive\Рабочий стол"), _
  sh.SpecialFolders("AllUsersDesktop") _
)

ok = 0
For i = 0 To UBound(folders)
  d = folders(i)
  On Error Resume Next
  If d <> "" Then
    If fso.FolderExists(d) Then
      lnk = d & "\Peak Pact.lnk"
      Set s = sh.CreateShortcut(lnk)
      s.TargetPath = "wscript.exe"
      s.Arguments = "//nologo """ & target & """"
      s.WorkingDirectory = install
      s.WindowStyle = 7
      s.Description = "Peak Pact"
      If fso.FileExists(ico) Then s.IconLocation = ico
      s.Save
      If Err.Number = 0 Then ok = ok + 1
      Err.Clear
    End If
  End If
  On Error GoTo 0
Next

If ok > 0 Then
  MsgBox "Shortcut created: Peak Pact" & vbCrLf & "Desktop shortcuts: " & ok, 64, "Peak Pact"
Else
  MsgBox "Could not create desktop shortcut." & vbCrLf & "Start game with: " & target, 48, "Peak Pact"
End If
