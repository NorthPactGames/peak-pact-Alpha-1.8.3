
' Peak Pact launcher — desktop app window, NO Node.js, no terminal
Option Explicit
Dim sh, fso, game, url, edge, chrome, yandex, cmd, profile, ico
Set sh = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")

Function AppData()
  AppData = sh.ExpandEnvironmentStrings("%LOCALAPPDATA%")
End Function

Function FindGame()
  Dim p
  p = fso.GetParentFolderName(WScript.ScriptFullName) & "\game\peak-pact.html"
  If fso.FileExists(p) Then FindGame = p : Exit Function
  p = fso.GetParentFolderName(WScript.ScriptFullName) & "\peak-pact.html"
  If fso.FileExists(p) Then FindGame = p : Exit Function
  p = AppData() & "\PeakPact\game\peak-pact.html"
  If fso.FileExists(p) Then FindGame = p : Exit Function
  FindGame = ""
End Function

Function ToFileUrl(path)
  Dim u
  u = Replace(path, "\", "/")
  If Mid(u, 2, 1) = ":" Then
    ToFileUrl = "file:///" & u
  Else
    ToFileUrl = "file:///" & u
  End If
End Function

Function Exists(p)
  Exists = fso.FileExists(p)
End Function

game = FindGame()
If game = "" Then
  MsgBox "peak-pact.html not found. Run Install-PeakPact.bat first.", 16, "Peak Pact"
  WScript.Quit 1
End If

url = ToFileUrl(game)
profile = AppData() & "\PeakPact\app-profile"
If Not fso.FolderExists(AppData() & "\PeakPact") Then fso.CreateFolder AppData() & "\PeakPact"

' Prefer Edge, then Chrome, then Yandex — always --app (no tabs, no address bar)
edge = sh.ExpandEnvironmentStrings("%ProgramFiles(x86)%") & "\Microsoft\Edge\Application\msedge.exe"
If Not Exists(edge) Then edge = sh.ExpandEnvironmentStrings("%ProgramFiles%") & "\Microsoft\Edge\Application\msedge.exe"
If Not Exists(edge) Then edge = AppData() & "\Microsoft\Edge\Application\msedge.exe"

chrome = sh.ExpandEnvironmentStrings("%ProgramFiles%") & "\Google\Chrome\Application\chrome.exe"
If Not Exists(chrome) Then chrome = sh.ExpandEnvironmentStrings("%ProgramFiles(x86)%") & "\Google\Chrome\Application\chrome.exe"
If Not Exists(chrome) Then chrome = AppData() & "\Google\Chrome\Application\chrome.exe"

yandex = AppData() & "\Yandex\YandexBrowser\Application\browser.exe"

If Exists(edge) Then
  cmd = """" & edge & """ --app=""" & url & """ --user-data-dir=""" & profile & """ --no-first-run --disable-features=msEdgeSidebar --window-size=1280,800"
  sh.Run cmd, 1, False
  WScript.Quit 0
End If

If Exists(chrome) Then
  cmd = """" & chrome & """ --app=""" & url & """ --user-data-dir=""" & profile & """ --no-first-run --window-size=1280,800"
  sh.Run cmd, 1, False
  WScript.Quit 0
End If

If Exists(yandex) Then
  cmd = """" & yandex & """ --app=""" & url & """ --user-data-dir=""" & profile & """ --window-size=1280,800"
  sh.Run cmd, 1, False
  WScript.Quit 0
End If

MsgBox "Install Microsoft Edge or Google Chrome (free). Peak Pact needs it to run as a desktop window — Node.js is NOT required.", 48, "Peak Pact"
' last resort: open file (may use default browser tab)
sh.Run """" & game & """", 1, False
