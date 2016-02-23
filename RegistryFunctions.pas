unit RegistryFunctions;

interface

uses
  Sysutils, Classes, Windows, Registry, Utilities, Constants, Forms, KBDriverService,
  NSDatSettingsUtils;

procedure MoveKeys(AFromRoot: HKey; AFromKey: String; AToRoot: HKey; AToKey: String);
procedure DeleteValues(ARootKey: HKey; AKeyName: String);
procedure DoDATFix(AFromRoot: HKey; AFromKey: String; AToRoot: HKey; AToKey: String);

implementation

function GetTheCurrentVersion: String;
begin
  Result := '';
  with TRegistry.Create do
  begin
    try
      RootKey := MyRootKey;
      if OpenKey(NETSTOP_BASE_KEY, FALSE) then
      begin
        if ValueExists('CurrentVersion') then
          Result := ReadString('CurrentVersion');
        CloseKey;
      end;
    finally
      Free;
    end;
  end;
end;

procedure DeleteValues(ARootKey: HKey; AKeyName: String);
var
  sl: TStringList;
  i: Integer;
begin
  sl := TStringList.Create;
  try
    with TRegistry.Create do
    begin
      RootKey := ARootKey;
      if OpenKey(AKeyName, FALSE) then
      begin
        sl.Clear;
        GetValueNames(sl);
        for i := 0 to (sl.Count - 1) do
          DeleteValue(sl[i]);
        CloseKey;
      end;
    end;
  finally
    sl.Free;
  end;
end;

procedure MoveValues(AFromRoot: HKey; AFromKey: String; AToRoot: HKey; AToKey: String);
var
  RegFrom, RegTo: TRegistry;
  sl : TStringList;
  i : Integer;
  LDataInfo: TRegDataInfo;
  buff: Pointer;
begin
  RegFrom := TRegistry.Create;
  try
    RegFrom.RootKey := AFromRoot;
    if RegFrom.OpenKey(AFromKey, FALSE) then
    begin
      sl := TStringList.Create;
      try
        sl.Clear;
        RegFrom.GetValueNames(sl);
        if sl.Count > 0 then
        begin
          RegTo := TRegistry.Create;
          try
            RegTo.RootKey := AToRoot;
            if RegTo.OpenKey(AToKey, TRUE) then
            begin
              for i := 0 to (sl.Count - 1) do
              begin
                case RegFrom.GetDataType(sl[i]) of
                  rdString: RegTo.WriteString(sl[i], RegFrom.ReadString(sl[i]));
                  rdExpandString: RegTo.WriteExpandString(sl[i], RegFrom.ReadString(sl[i]));
                  rdInteger: RegTo.WriteInteger(sl[i], RegFrom.ReadInteger(sl[i]));
                  rdBinary:begin
                      RegFrom.GetDataInfo(sl[i], LDataInfo);
                      GetMem(buff, LDataInfo.DataSize);
                      try
                        RegFrom.ReadBinaryData(sl[i], buff^, LDataInfo.DataSize);
                        RegTo.WriteBinaryData(sl[i], buff^, LDataInfo.DataSize);
                      finally
                        FreeMem(buff);
                      end;
                    end;
                end;
              end;
              RegTo.CloseKey;
            end;
          finally
            RegTo.Free;
          end;
        end;
      finally
        sl.Free;
      end;
      RegFrom.CloseKey;
    end;
  finally
    RegFrom.Free;
  end;
end;


procedure DoDATFix(AFromRoot: HKey; AFromKey: String; AToRoot: HKey; AToKey: String);
var
  RegFrom, RegTo: TRegistry;
  sTempFile1, sTempFile2 : string;
  ver : string;
begin
  ver := GetTheCurrentVersion;
  RegFrom := TRegistry.Create;
  RegFrom.RootKey := AFromRoot;

  if RegFrom.OpenKey(AFromKey, FALSE) then
  try
    RegFrom.DeleteKey('CustomColors');
    RegFrom.DeleteKey(ver);

    sTempFile1 := ExtractFilePath(Application.ExeName) + 'TempConv.reg';
    sTempFile2 := ExtractFilePath(Application.ExeName) + DATSETTINGSFILENAME;
    if Is64Bit then
    begin
      LaunchApplication('regedit /s /e "' + sTempFile1 + '" ' + '"HKEY_LOCAL_MACHINE\Software\Wow6432Node\Moonrise Systems Inc\NetStopPro\5.0"', True);
    end else begin
      LaunchApplication('regedit /s /e "' + sTempFile1 + '" ' + '"HKEY_LOCAL_MACHINE\' + NETSTOP_BASE_KEY + '\' + ver + '"', True);
    end;

    Application.ProcessMessages;
    ConvertRegToDat(sTempFile1,sTempFile2);
    DeleteFile(pchar(sTempFile1));
    RegFrom.CloseKey;
    //delete the old key
    RegFrom.DeleteKey(AFromKey);
  finally
    RegFrom.Free;
  end;

  //Cleanup new version keys & Values
  DeleteValues(AToRoot,AToKey);

  RegTo := TRegistry.Create;
  RegTo.RootKey := AToRoot;
  if RegTo.OpenKey(AToKey, FALSE) then
  try
    RegTo.DeleteKey('CustomColors');
    RegTo.DeleteKey(ver);
    RegTo.CloseKey;
  finally
    RegTo.Free;
  end;


end;

procedure MoveKeys(AFromRoot: HKey; AFromKey: String; AToRoot: HKey; AToKey: String);
var
  RegFrom: TRegistry;
  sl : TStringList;
  i : Integer;
begin
  RegFrom := TRegistry.Create;
  try
    RegFrom.RootKey := AFromRoot;
    if RegFrom.OpenKey(AFromKey, FALSE) then
    begin
      sl := TStringList.Create;
      try
        sl.Clear;
        RegFrom.GetKeyNames(sl);
        for i := 0 to (sl.Count - 1) do
        begin
          if sl[i] <> 'KioskWatchRemote' then
            MoveKeys(AFromRoot, AFromKey + '\' + sl[i], AToRoot, AToKey + '\' + sl[i]);
        end;
        MoveValues(AFromRoot, AFromKey, AToRoot, AToKey);
      finally
        sl.Free;
      end;
      RegFrom.CloseKey;
    end;
  finally
    RegFrom.Free;
  end;
end;

end.
