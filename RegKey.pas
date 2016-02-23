unit RegKey;

interface

uses
  SysUtils, Windows, Classes, Utilities, RegMerge, TntClasses, TntSysUtils,
  TntRegistry, OtherLanguages, TntDialogs, Forms, Controls, ProductVersionInfo,
  Dialogs;

type
  TRegKey = class
    private
      FRegFile: String;
      FKey: String;
      function GetFileVersion: Integer;
      function GetRegistryVersion: Integer;
      function GetDefaultLanguage: Integer;
      function GetPreviouslyInstalled: Boolean;
      procedure DoBackUp;
      function ExportKey(AFileName, AKey: String): Boolean;
      function UsingLocalMachine: Boolean;
      function UsingCurrentUser: Boolean;
      function Upgrading: Boolean;
      function Convert(AFileName: String): Boolean;
      function ImportKey(AFileName: String): Boolean;
      function SetVersion: Boolean;
      procedure CheckRegistration;
//      function RemoveKeyFromCurrentUser(AKey: String): Boolean;
    public
      constructor Create; virtual;
      procedure Execute;

      property RegFile: String read FRegFile write FRegFile;
      property Key: String read FKey write FKey;
      property PreviouslyInstalled: Boolean read GetPreviouslyInstalled;
    end;

implementation

constructor TRegKey.Create;
begin
  FRegFile := IncludeTrailingPathDelimiter(string(TempPath)) + 'tmp.reg';
end;

function TRegKey.GetFileVersion: Integer;
var
  pv    : TProductVersionInfo;
begin
//  Result := -1;
  pv := TProductVersionInfo.Create(AnsiString(ParamStr(0)));
  try
    Result := StrToIntDef(String(pv.MajorVersion + pv.MinorVersion + pv.Release + pv.Build), 0);
  finally
    pv.Free;
  end;
end;

function TRegKey.GetRegistryVersion: Integer;
begin
  Result := -1;
  with TTntRegistry.Create(KEY_READ) do
  begin
    try
      RootKey := HKEY_LOCAL_MACHINE;
      if OpenKey('Software\Moonrise Systems Inc\NetStopPro', False) then
      begin
        if ValueExists('VersionInfo') then
          Result := ReadInteger('VersionInfo');
        CloseKey;
      end;
    finally
      Free;
    end;
  end;

  if -1 <> Result then
    EXIT;

  with TTntRegistry.Create(KEY_READ) do
  begin
    try
      RootKey := HKEY_CURRENT_USER;
      if OpenKey('Software\Moonrise Systems Inc\NetStopPro', False) then
      begin
        if ValueExists('VersionInfo') then
          Result := ReadInteger('VersionInfo');
        CloseKey;
      end;
    finally
      Free;
    end;
  end;
end;

function TRegKey.GetDefaultLanguage: Integer;
var
  LExit : Boolean;
begin
  Result := 0;
  LExit := FALSE;
  with TTntRegistry.Create(KEY_READ) do
  begin
    try
      RootKey := HKEY_CURRENT_USER;
      if OpenKey('Software\Moonrise Systems Inc\NetStopPro', FALSE) then
      begin
        if ValueExists('DesignerPro Language') then
        begin
          Result := ReadInteger('DesignerPro Language');
          LExit := TRUE;
        end;
        CloseKey;
      end;
    finally
      Free;
    end;
  end;

  if LExit then
    EXIT;

  with TTntRegistry.Create(KEY_READ) do
  begin
    try
      RootKey := HKEY_LOCAL_MACHINE;
      if OpenKey('Software\Moonrise Systems Inc\NetStopPro', FALSE) then
      begin
        if ValueExists('DesignerPro Language') then
          Result := ReadInteger('DesignerPro Language');
        CloseKey;
      end;
    finally
      Free;
    end;
  end;
end;

function TRegKey.GetPreviouslyInstalled: Boolean;
begin
  Result := UsingLocalMachine or UsingCurrentUser;
end;

procedure TRegKey.DoBackUp;
var
  Dialog: TTntSaveDialog;
begin
  if mrYes = MessageDlg(GetTextFromResourceOrRegistry(GetDefaultLanguage, 649), mtConfirmation, [mbYes, mbNo], 0) then
  begin
    Dialog := TTntSaveDialog.Create(nil);
    try
      Dialog.Filter := 'Registry Files (*.reg)|*.reg|All Files (*.*)|*.*';
      if Dialog.Execute then
      begin
        if UsingCurrentUser then
          LaunchApplication('regedit /s /e "' + Dialog.FileName + '" ' + '"HKEY_CURRENT_USER\Software\Moonrise Systems Inc"', True)
        else
          LaunchApplication('regedit /s /e "' + Dialog.FileName + '" ' + '"HKEY_LOCAL_MACHINE\Software\Moonrise Systems Inc"', True)
      end;
    finally
      Dialog.Free;
    end;
  end;
end;

function TRegKey.UsingLocalMachine: Boolean;
begin
  Result := False;
  with TTntRegistry.Create(KEY_READ) do
  begin
    try
      RootKey := HKEY_LOCAL_MACHINE;
      if OpenKey('Software\Moonrise Systems Inc\NetStopPro', False) then
      begin
        Result := ValueExists('Image World Interface - Displayed');
        CloseKey;
      end;
    finally
      Free;
    end;
  end;
end;

function TRegKey.UsingCurrentUser: Boolean;
begin
  Result := False;
  with TTntRegistry.Create(KEY_READ) do
  begin
    try
      RootKey := HKEY_CURRENT_USER;
      if OpenKey('Software\Moonrise Systems Inc\NetStopPro', False) then
      begin
        Result := ValueExists('Image World Interface - Displayed');
        CloseKey;
      end;
    finally
      Free;
    end;
  end;
end;

function TRegKey.Upgrading: Boolean;
begin
  Result := GetFileVersion > GetRegistryVersion;
end;

function TRegKey.ExportKey(AFileName, AKey: String): Boolean;
begin
  Result := True;
  LaunchApplication('regedit /s /e "' + AFileName + '" ' + '"' + AKey + '"', True);
end;

function TRegKey.ImportKey(AFileName: String): Boolean;
var
  LTemp : String;
begin
  Result := False;
  if FileExists(AFileName) then
  begin
    LTemp := 'regedit /s "' + AFileName +'"';
    LaunchApplication(LTemp, True);
  end else
    raise Exception.Create('File ' + AFileName + ' does not exist');
end;

function TRegKey.Convert(AFileName: String): Boolean;
var
  s     : TTntStringList;
  i     : Integer;
  LTemp : WideString;
begin
//  Result := False;
  s := TTntStringList.Create;
  try
    s.LoadFromFile(AFileName);
    for i := 0 to (s.Count - 1) do
    begin
      LTemp := s[i];
      s[i] := Tnt_WideStringReplace(LTemp, '[HKEY_CURRENT_USER\', '[HKEY_LOCAL_MACHINE\', [rfReplaceAll]);
    end;
    s.SaveToFile(FRegFile);
    Result := True;
  finally
    s.Free;
  end;
end;

function TRegKey.SetVersion: Boolean;
begin
  Result := False;
  with TTntRegistry.Create do
  begin
    try
      RootKey := HKEY_LOCAL_MACHINE;
      if OpenKey('Software\Moonrise Systems Inc\NetStopPro', False) then
      begin
        WriteInteger('VersionInfo', GetFileVersion);
        CloseKey;
        Result := True;
      end;
    finally
      Free;
    end;
  end;
end;

procedure TRegKey.CheckRegistration;
var
  Multi, Code, ID : String;
  LWrite          : Boolean;
  LType, LEncType : String;
  LReg1, LReg2    : String;
begin
  LWrite := False;

  Multi := '';
  ID := '';
  Code := '';

  with TTntRegistry.Create(KEY_READ) do
  begin
    try
      RootKey := HKEY_CURRENT_USER;
      if OpenKey('Software\Moonrise Systems Inc', False) then
      begin
        LWrite := ValueExists('Multi');
        if LWrite then
          Multi := ReadString('Multi');

        LWrite := LWrite and ValueExists('Registration Code');
        if LWrite then
          ID := ReadString('Registration Code');

        LWrite := LWrite and ValueExists('Registration Code');
        if LWrite then
          Code := ReadString('Registration Code');
        CloseKey;
      end;
    finally
      Free;
    end;
  end;

  if LWrite then
  begin
    with TTntRegistry.Create do
    begin
      try
        RootKey := HKEY_LOCAL_MACHINE;
        if OpenKey('Software\Moonrise Systems Inc', False) then
        begin
          WriteString('Multi', Multi);
          WriteString('Registration Code', ID);
          WriteString('Registration Code', Code);
          CloseKey;
        end;
      finally
        Free;
      end;
    end;
  end;

  LWrite := False;
  with TTntRegistry.Create(KEY_READ) do
  begin
    try
      RootKey := HKEY_CURRENT_USER;
      if OpenKey('Software\Microsoft\Cryptography\Microsoft Base ABSS2', FALSE) then
      begin
        LWrite := ValueExists('Type');
        if LWrite then
          LType := ReadString('Type');

        LWrite := LWrite and ValueExists('EncType');
        if LWrite then
          LEncType := ReadString('EncType');

        LWrite := LWrite and ValueExists('Registration1');
        if LWrite then
          LReg1 := ReadString('Registration1');

        LWrite := LWrite and ValueExists('Registration2');
        if LWrite then
          LReg2 := ReadString('Registration2');
          
        CloseKey;
      end;
    finally
      Free;
    end;
  end;

  if LWrite then
  begin
    with TTntRegistry.Create do
    begin
      try
        RootKey := HKEY_LOCAL_MACHINE;
        if OpenKey('Software\Microsoft\Cryptography\Microsoft Base ABSS2', TRUE) then
        begin
          WriteString('Type', LType);
          WriteString('EncType', LEncType);
          WriteString('Registration1', LReg1);
          WriteString('Registration2', LReg2);
          CloseKey;
        end;
      finally
        Free;
      end;
    end;
  end;
end;

//function TRegKey.RemoveKeyFromCurrentUser(AKey: String): Boolean;
//begin
//  with TTntRegistry.Create do
//  begin
//    try
//      RootKey := HKEY_CURRENT_USER;
//      if not DeleteKey(AKey) then
//        raise Exception.Create('Could Not Delete Key ' + AKey);
//    finally
//      Free;
//    end;
//  end;
//end;

procedure TRegKey.Execute;
begin
  if not Upgrading then
    EXIT;

  if PreviouslyInstalled then
    DoBackup;

  if UsingCurrentUser then
  begin
    Screen.Cursor := crAppStart;
    try
      ExportKey(FRegFile, 'HKEY_CURRENT_USER\Software\Moonrise Systems Inc');
      Convert(FRegFile);
      ImportKey(FRegFile);
      CheckRegistration;
      //RemoveKeyFromCurrentUser('Software\Moonrise Systems Inc');
    finally
      Screen.Cursor := crDefault;
    end;
  end;

  SetVersion;
end;

end.
