unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, TntForms, ComCtrls, TntComCtrls, StdCtrls, TntStdCtrls, ExtCtrls,
  Registry, SecurityInfo, NSDatSettingsUtils, Generics.Collections;

const
  CONFIG_STEPS = 8;

type
  TfmMain = class(TTntForm)
    sbMain: TTntStatusBar;
    TntGroupBox1: TTntGroupBox;
    pbMain: TTntProgressBar;
    tmMain: TTimer;
    procedure tmMainTimer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    function InLocalUser: Boolean;
    function GetCurrentVersion: String;
    {$IFDEF DATSETTINGS}
    //procedure SetDATDefaultsInRegistry;
    {$ELSE}
    procedure SetDefaultsInRegistry;
    {$ENDIF}
    //Nigel - 9/22/2009
    // procedure ExtractDriverBinary;
    procedure ExtractDriverBinary(ADebug: Boolean = FALSE);
    procedure SetKBDriverDefaults;
    procedure SetUpPrinterService;
    procedure SetCurrentVersion;
    procedure MoveRegistrationInfo;
    procedure MoveAutoLogonInfo;
    procedure DeleteOldRegistryKeys;
    procedure Configure;
    procedure SetSecurityOnDirectories;
    procedure Dlog(ALogStr: String);
    procedure SetInjectionLibKey;
    procedure SetOwnerSpecifics(AOwnerID,AKioskID: Integer; AVFC,AOwnerValidationString: String);
    procedure SetRegistrationSpecifics(AMulti, ARegistrationCode,ARegistrationID: String);
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
  end;

var
  fmMain: TfmMain;

implementation

uses
  Utilities, RegMerge, KeyboardBase, KBDriverService, KBDriverConfig,
  ShellProServices, UpgradeFactory, UpgradeClass, UserControl, OSProduct,
  RegistryFunctions, Constants;

{$R *.DFM}
{$R DRVFILE.RES}
{$R ..\..\DefaultSettings\DEFAULTREG.RES}
{===============================================================================
  Custom Methods
===============================================================================}
constructor TfmMain.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  pbMain.Min := 0;
  pbMain.Max := CONFIG_STEPS;

  {$IFDEF DATSETTINGS}
  Dic := TDictionary<String,Tv6Setting>.Create;
  {$ENDIF}

end;

function TfmMain.InLocalUser: Boolean;
begin
  Result := False;
  with TRegistry.Create do
  begin
    try
      RootKey := HKEY_CURRENT_USER;
      if OpenKey('Software\Moonrise Systems Inc\NetstopPro', FALSE) then
      begin
        Result :=  ValueExists('Background Color');
        CloseKey;
      end;
    finally
      Free;
    end;
  end;
end;

function TfmMain.GetCurrentVersion: String;
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

{$IFDEF DATSETTINGS}
{
procedure TfmMain.SetDATDefaultsInRegistry;
var
  vDefaultReg: String;
  vExtractedFromResources: Boolean;
  AppDir : string;
begin
  sbMain.SimpleText := 'Merging Configuration Changes';

  AppDir := ExtractFilePath(Application.ExeName);
  vDefaultReg := 'Default_DOMAINUSER';
  if FileExists(vDefaultReg + '.REG') then
    DeleteFile(vDefaultReg + '.REG');
  vExtractedFromResources := not FileExists(vDefaultReg + '.REG');


  // Make sure we have all the values
  // We need a DEFAULT_SETTINGS.REG file - if one does not exist already, we exctract one from the resource file
  if FileExists(vDefaultReg + '.REG') or ExtractFileFromRes(hInstance, vDefaultReg + '.REG', 'CUSTOM', vDefaultReg) then
  begin
    // If DAT file does not exist, create it from default
    if not FileExists(DATSETTINGSPATH + DATSETTINGSFILENAME) then
      ConvertRegToDat(AppDir + vDefaultReg + '.reg',DATSETTINGSPATH + DATSETTINGSFILENAME)
    else begin
      NS_OpenSettings;
      // If DAT file DOES exist, Update it for missing values
      MergeFromDefault(AppDir + vDefaultReg + '.reg',DATSETTINGSPATH + DATSETTINGSFILENAME, True);
      NS_CloseSettings;
    end;
  end;

  if vExtractedFromResources then
    DeleteFile(vDefaultReg + '.REG');

  with TRegistry.Create do
  begin
    try
      RootKey := HKEY_LOCAL_MACHINE;
      Access := KEY_ALL_ACCESS;
      if OpenKey(NETSTOP_REG_KEY + '\PrinterIPC', TRUE) then
      begin
        WriteInteger('IPCDelay',200);
        WriteInteger('Lockable',0);
        WriteString('MonitoredProcess','');
        WriteInteger('PerProcess',0);
        WriteInteger('PipeControl',0);
        WriteInteger('PrintMonitorLog',0);
        WriteInteger('UseIPC',1);
        CloseKey;
      end;
    finally
      Free;
    end;
  end;
end;
}
{$ENDIF}

{$IFNDEF DATSETTINGS}
procedure TfmMain.SetDefaultsInRegistry;
var
  vDefaultReg: String;
  vExtractedFromResources: Boolean;
  F1, F2 : TextFile;
  sTempFile1 : string;
  sTempFile2 : string;
  sPath,sPath2, S : string;
begin
  sbMain.SimpleText := 'Merging Configuration Changes';

  sPath := ExtractFileDir(Application.ExeName) + '\';
  sPath2 := StringReplace(sPath,'\','\\',[rfReplaceAll]);

  vDefaultReg := 'Default_DOMAINUSER';
  if FileExists(vDefaultReg + '.REG') then
    DeleteFile(vDefaultReg + '.REG');

  vExtractedFromResources := not FileExists(vDefaultReg + '.REG');

  if FileExists(vDefaultReg + '.REG') or ExtractFileFromRes(hInstance, vDefaultReg + '.REG', 'CUSTOM', vDefaultReg) then
  begin

    with TRegMerge.Create(vDefaultReg + '.REG') do
    try
      //mh 12/15/2009 replace key values with correct program dir spec
      /////////////////////////////////////////////////////////////////
      sTempFile1 := sPath + vDefaultReg + '.REG';
      sTempFile2 := sPath + 'temp.REG';

      AssignFile(F1, sTempFile1);
      AssignFile(F2, sTempFile2);
      Reset(F1);
      Rewrite(F2);
      While not EOF(F1) do
      begin
        ReadLn(F1, S);
        if (pos('c:\\program files\\netstoppro\\',lowercase(S)) > 0 ) then
          S := StringReplace(S,'C:\\Program Files\\NetStopPro\\',sPath2,[rfIgnoreCase]);
        WriteLn(F2, S);
      end;
      CloseFile(F1);
      CloseFile(F2);
      DeleteFile(sTempFile1);
      RenameFile(sTempFile2,sTempFile1);
      /////////////////////////////////////////////////////////////////

      //mh this did not seem to work - the above does
      // AddTransform('<PROGRAMDIR>', IncludeTrailingPathDelimiter(ExtractFileDir(Application.ExeName)), [rfIgnoreCase]);
      if not Merge then
        ShowMessage(SysErrorMessage(LastError));
    finally
      free;
    end;
  end;

  if vExtractedFromResources then
    DeleteFile(vDefaultReg + '.REG');

  with TRegistry.Create do
  begin
    try
      RootKey := HKEY_LOCAL_MACHINE;
      Access := KEY_ALL_ACCESS;
      if OpenKey(NETSTOP_REG_KEY + '\PrinterIPC', TRUE) then
      begin
        WriteInteger('IPCDelay',200);
        WriteInteger('Lockable',0);
        WriteString('MonitoredProcess','');
        WriteInteger('PerProcess',0);
        WriteInteger('PipeControl',0);
        WriteInteger('PrintMonitorLog',0);
        WriteInteger('UseIPC',1);
        CloseKey;
      end;
    finally
      Free;
    end;
  end;
  //mh 8/27/2010 - insert default chinese into registry
  //    ShellExecute_AndWait('open',program,vParam,vDirectory,SW_HIDE,TRUE);
  if FileExists(spath + 'ChinDefaultReg.reg') then
    ShellExecute_AndWait('open','regedit.exe','/s ChinDefaultReg.reg',spath,SW_HIDE,TRUE);
end;
{$ENDIF}


{per Nigel - 9/22/2009 - this now obsolete - see new one below
procedure TfmMain.ExtractDriverBinary;
var
  LDrvDir : String;
  vVersionInfo: TOSVersionInfo;
begin
  sbMain.SimpleText := 'Updating Keyboard Controller';
  vVersionInfo.dwOSVersionInfoSize := SizeOf(vVersionInfo);
  GetVersionEx(vVersionInfo);
  LDrvDir := IncludeTrailingPathDelimiter(GetEnvironmentStr('%SystemRoot%')) + 'System32\Drivers';

  case vVersionInfo.dwMajorVersion of
    5: begin
         case vVersionInfo.dwMinorVersion of
           0: ExtractFileFromRes(hInstance, LDrvDir + '\NSKbFiltr2K.sys', 'SYS', 'NSKBFILTR2K');
           1: ExtractFileFromRes(hInstance, LDrvDir + '\NSKbFiltrXP.sys', 'SYS', 'NSKBFILTR2K');
         end;
       end;
    6: begin
         ExtractFileFromRes(hInstance, LDrvDir + '\NSKbFiltrVista.sys', 'SYS', 'NSKBFILTRVISTA');
       end;
  end;
end;
}

{per Nigel - 12/14/2009 - this now obsolete - see new one below - includes signed 64bit drivers for Win7
procedure TfmMain.ExtractDriverBinary(ADebug: Boolean = FALSE);
var
  LDrvDir : String;
  vVersionInfo: TOSVersionInfo;
begin
  sbMain.SimpleText := 'Updating Keyboard Controller';
  vVersionInfo.dwOSVersionInfoSize := SizeOf(vVersionInfo);
  GetVersionEx(vVersionInfo);
  LDrvDir := IncludeTrailingPathDelimiter(GetEnvironmentStr('%SystemRoot%')) + 'System32\Drivers';

  case vVersionInfo.dwMajorVersion of
    5: begin
         case vVersionInfo.dwMinorVersion of
           0:if ADebug then
               ExtractFileFromRes(hInstance, LDrvDir + '\' + DEFAULT_FILE_NAME, 'SYS', 'NSKBFILTR2K_I386_DBG')
             else
               ExtractFileFromRes(hInstance, LDrvDir + '\' + DEFAULT_FILE_NAME, 'SYS', 'NSKBFILTR2K_I386');
           1:if ADebug then
               ExtractFileFromRes(hInstance, LDrvDir + '\' + DEFAULT_FILE_NAME, 'SYS', 'NSKBFILTRXP_I386_DBG')
             else
               ExtractFileFromRes(hInstance, LDrvDir + '\' + DEFAULT_FILE_NAME, 'SYS', 'NSKBFILTRXP_I386');
         end;
       end;
    6: begin
         case vVersionInfo.dwMinorVersion of
           0:begin
               //Windows Vista
               if Is64Bit then
               begin
                 if ADebug then
                   ExtractFileFromRes(hInstance, LDrvDir + '\' + DEFAULT_FILE_NAME, 'SYS', 'NSKBFILTRVISTA_X64_DBG')
                 else
                   ExtractFileFromRes(hInstance, LDrvDir + '\' + DEFAULT_FILE_NAME, 'SYS', 'NSKBFILTRVISTA_X64');
               end
               else
               begin
                 if ADebug then
                   ExtractFileFromRes(hInstance, LDrvDir + '\' + DEFAULT_FILE_NAME, 'SYS', 'NSKBFILTRVISTA_I386_DBG')
                 else
                   ExtractFileFromRes(hInstance, LDrvDir + '\' + DEFAULT_FILE_NAME, 'SYS', 'NSKBFILTRVISTA_I386');
               end;
             end;
           1:begin
               //Windows 7
               if Is64Bit then
                 ExtractFileFromRes(hInstance, LDrvDir + '\' + DEFAULT_FILE_NAME, 'SYS', 'NSKBFILTRWIN764')
               else
                 ExtractFileFromRes(hInstance, LDrvDir + '\' + DEFAULT_FILE_NAME, 'SYS', 'NSKBFILTRWIN732');
             end;
         end;
       end;
  end;
end;
}

procedure TfmMain.ExtractDriverBinary(ADebug: Boolean = FALSE);
var
  LDrvDir : String;
  vVersionInfo: TOSVersionInfo;
begin
  //sbMain.SimpleText := 'Updating Keyboard Controller';
  vVersionInfo.dwOSVersionInfoSize := SizeOf(vVersionInfo);
  GetVersionEx(vVersionInfo);
  LDrvDir := IncludeTrailingPathDelimiter(GetEnvironmentStr('%SystemRoot%')) + 'System32\Drivers';


  case vVersionInfo.dwMajorVersion of
    5: begin
         case vVersionInfo.dwMinorVersion of
           0:if ADebug then
               ExtractFileFromRes(hInstance, LDrvDir + '\' + DEFAULT_FILE_NAME, 'SYS', 'NSKBFILTR2K_I386_DBG')
             else
               ExtractFileFromRes(hInstance, LDrvDir + '\' + DEFAULT_FILE_NAME, 'SYS', 'NSKBFILTR2K_I386');
           1:if ADebug then
               ExtractFileFromRes(hInstance, LDrvDir + '\' + DEFAULT_FILE_NAME, 'SYS', 'NSKBFILTRXP_I386_DBG')
             else
               ExtractFileFromRes(hInstance, LDrvDir + '\' + DEFAULT_FILE_NAME, 'SYS', 'NSKBFILTRXP_I386');
         end;
       end;
    6: begin
         case vVersionInfo.dwMinorVersion of
           0:begin
               //Windows Vista
               if Is64Bit then
               begin
                 if ADebug then
                   ExtractFileFromRes(hInstance, LDrvDir + '\' + DEFAULT_FILE_NAME, 'SYS', 'NSKBFILTRVISTA_X64_DBG')
                 else
                   ExtractFileFromRes(hInstance, LDrvDir + '\' + DEFAULT_FILE_NAME, 'SYS', 'NSKBFILTRVISTA_X64');
               end
               else
               begin
                 if ADebug then
                   ExtractFileFromRes(hInstance, LDrvDir + '\' + DEFAULT_FILE_NAME, 'SYS', 'NSKBFILTRVISTA_I386_DBG')
                 else
                   ExtractFileFromRes(hInstance, LDrvDir + '\' + DEFAULT_FILE_NAME, 'SYS', 'NSKBFILTRVISTA_I386');
               end;
             end;
           1:begin
               //Windows 7
               if Is64Bit then
               begin
                 if ADebug then
                   ExtractFileFromRes(hInstance, LDrvDir + '\' + DEFAULT_FILE_NAME, 'SYS', 'NSKBFILTRWIN7_X64_DBG')
                 else
                   ExtractFileFromRes(hInstance, LDrvDir + '\' + DEFAULT_FILE_NAME, 'SYS', 'NSKBFILTRWIN7_X64');
               end
               else
               begin
                 if ADebug then
                   ExtractFileFromRes(hInstance, LDrvDir + '\' + DEFAULT_FILE_NAME, 'SYS', 'NSKBFILTRWIN7_I386_DBG')
                 else
                   ExtractFileFromRes(hInstance, LDrvDir + '\' + DEFAULT_FILE_NAME, 'SYS', 'NSKBFILTRWIN7_I386');
               end;
             end;
           2:begin
               //Windows 8
               if Is64Bit then
               begin
                 if ADebug then
                   ExtractFileFromRes(hInstance, LDrvDir + '\' + DEFAULT_FILE_NAME, 'SYS', 'NSKBFILTRWIN7_X64_DBG')
                 else
                   ExtractFileFromRes(hInstance, LDrvDir + '\' + DEFAULT_FILE_NAME, 'SYS', 'NSKBFILTRWIN7_X64');
               end
               else
               begin
                 if ADebug then
                   ExtractFileFromRes(hInstance, LDrvDir + '\' + DEFAULT_FILE_NAME, 'SYS', 'NSKBFILTRWIN7_I386_DBG')
                 else
                   ExtractFileFromRes(hInstance, LDrvDir + '\' + DEFAULT_FILE_NAME, 'SYS', 'NSKBFILTRWIN7_I386');
               end;
             end;
         end;
       end;
  end;

end;


procedure TfmMain.FormCreate(Sender: TObject);
begin
  {$IFDEF DATSETTINGS}
  //determine location of DAT settings file
  DATSETTINGSPATH := ExtractFilePath(Application.ExeName);
  {$ENDIF}
end;

procedure TfmMain.SetKBDriverDefaults;
var
  sv          : TKBDriverService;
  kb          : TKBDriverConfig;
  LInstalled  : Boolean;
begin
  sbMain.SimpleText := 'Configuring Keyboard Controller';
  sv := TKBDriverService.Create;
  try
    LInstalled := sv.DriverInstalled;
    if not LInstalled then
    begin
      sv.CreateDriverService;
      sv.EnableFilter;
    end;

  finally
    sv.Free;
  end;

  if LInstalled then
    EXIT;

  kb := TKBDriverConfig.Create;
  try
    kb.Enabled := FALSE;
    kb.CtlAltDel := TRUE;
    kb.AltTab := TRUE;
    kb.AltEsc := TRUE;
    kb.CtlEsc := TRUE;
    kb.WindowsLogo := TRUE;
    kb.WindowsMenu := TRUE;
    kb.ShiftF10 := TRUE;
    kb.CtlAltF12 := TRUE;
    kb.F8 := TRUE;
    kb.CtlP := TRUE;
    kb.AltF4 := TRUE;
    kb.CtlN := TRUE;
    kb.EscapeCodeEnabled := True;
    kb.EscapeCode1 := KEY_LCTRL;
    kb.EscapeCode2 := KEY_LSHIFT;
    kb.EscapeCode3 := KEY_R;
    kb.EscapeCode4 := KEY_BACKSPACE;
    kb.SaveSettings;
  finally
    kb.Free;
  end;
end;

procedure TfmMain.SetOwnerSpecifics(AOwnerID, AKioskID: Integer; AVFC,
  AOwnerValidationString: String);
begin
  with TRegistry.Create do
  begin
    try
      RootKey := HKEY_LOCAL_MACHINE;
      if OpenKey(NETSTOP_MACHINE_KEY, TRUE) then
      begin
        WriteInteger('Owner ID', AOwnerID);
        WriteInteger('Kiosk ID', AKioskID);
        WriteString('VFC', AVFC);
        WriteString('Owner Validation String', AOwnerValidationString);
        CloseKey;
      end;
    finally
      Free;
    end;
  end;
end;

procedure TfmMain.SetRegistrationSpecifics(AMulti, ARegistrationCode,
  ARegistrationID: String);
begin
  with TRegistry.Create do
  begin
    try
      RootKey := HKEY_LOCAL_MACHINE;
      if OpenKey('SOFTWARE\Moonrise Systems Inc', TRUE) then
      begin
        WriteString('Multi', AMulti);
        WriteString('Registration Code', ARegistrationCode);
        WriteString('Registration ID', ARegistrationID);
        CloseKey;
      end;
    finally
      Free;
    end;
  end;
end;

procedure TfmMain.SetUpPrinterService;
var
  vVersionInfo: TOSVersionInfo;
begin

  //mh 7/30/2010 - delete the printing service if installed
  //this is due to changes made with the 32/64 bit versions
  //on the different platforms
  /////////////////////////////////////////////////////////
  if PrinterServiceInstalled then
  begin
    StopPrinterService;
    DeletePrinterService;
    Application.ProcessMessages;
    Sleep(1000);
  end;
  /////////////////////////////////////////////////////////

  if not PrinterServiceInstalled then
  begin
    InstallPrinterService;
  end;

  //mh 7/30/2010
  vVersionInfo.dwOSVersionInfoSize := SizeOf(vVersionInfo);
  GetVersionEx(vVersionInfo);

  //Only start the service if XP, otherwise the new service is 'manual' and stopped
  case vVersionInfo.dwMajorVersion of
    5: begin
         if PrinterServiceStopped then
         begin
           StartPrinterService;
         end;
       end;
  end;
end;

procedure TfmMain.SetCurrentVersion;
begin
  with TRegistry.Create do
  begin
    try
      RootKey := HKEY_LOCAL_MACHINE;
      if OpenKey(NETSTOP_BASE_KEY, TRUE) then
      begin
        WriteString('CurrentVersion', VERSION_NUMBER);
        CloseKey;
      end;
    finally
      Free;
    end;
  end;
end;

procedure TfmMain.MoveRegistrationInfo;
var
  LMulti, LRegistrationID, LRegistrationCode: String;
  LEncType, LReg1, LReg2, LType : String;
begin
  LEncType := '';
  LReg1 := '';
  LReg2 := '';
  LType := '';

  with TRegistry.Create(KEY_READ) do
  begin
    try
      RootKey := HKEY_CURRENT_USER;
      if OpenKey('Software\Moonrise Systems Inc', FALSE) then
      begin
        LMulti := ReadString('Multi');
        LRegistrationID := ReadString('Registration ID');
        LRegistrationCode := ReadString('Registration Code');
        CloseKey;
      end;
      if OpenKey('Software\Microsoft\Cryptography\Microsoft Base ABSS2', FALSE) then
      begin
        if ValueExists('EncType') then
          LEncType := ReadString('EncType');
        if ValueExists('Registration1') then
          LReg1 := ReadString('Registration1');
        if ValueExists('Registration1') then
          LReg2 := ReadString('Registration2');
        if ValueExists('Type') then
          LType := ReadString('Type');
        CloseKey;
      end;
    finally
      Free;
    end;
  end;

  with TRegistry.Create do
  begin
    try
      RootKey := HKEY_LOCAL_MACHINE;
      if OpenKey('Software\Moonrise Systems Inc', TRUE) then
      begin
        WriteString('Multi', LMulti);
        WriteString('Registration ID', LRegistrationID);
        WriteString('Registration Code', LRegistrationCode);
        CloseKey;
      end;

      if OpenKey('Software\Microsoft\Cryptography\Microsoft Base ABSS2', TRUE) then
      begin
        WriteString('EncType', LEncType);
        WriteString('Registration1', LReg1);
        WriteString('Registration2', LReg2);
        WriteString('Type', LType);
        CloseKey;
      end;
    finally
      Free;
    end;
  end;
end;

procedure TfmMain.MoveAutoLogonInfo;
var
//  LAutoLogonEnabled : Boolean;
  LUserName, LPassword, LDomain: String;
begin
  LDomain := '';
  LUserName := '';
  LPassword := '';
//  LAutoLogonEnabled := FALSE;

  with TRegistry.Create do
  begin
    try
      RootKey := HKEY_LOCAL_MACHINE;
      if OpenKey('Software\Microsoft\Windows NT\CurrentVersion\WinLogon', FALSE) then
      begin
//        if ValueExists('AutoAdminLogon') then
//          LAutoLogonEnabled := ('1' = ReadString('AutoAdminLogon'));
        if ValueExists('DefaultDomainName') then
          LDomain := ReadString('DefaultDomainName');
        if ValueExists('DefaultUserName') then
          LUserName := ReadString('DefaultUserName');
        if ValueExists('DefaultPassword') then
          LPassword := ReadString('DefaultPassword');
        CloseKey;
      end;

      if ('' <> LDomain) and ('' <> LUserName) then
      begin
        if OpenKey(NETSTOP_MACHINE_KEY, TRUE) then
        begin
          if not ValueExists('Reboot - UserName') then
            WriteString('Reboot - UserName', String(GetEncryptedValue(AnsiString(LUserName))));
          if not ValueExists('Reboot - Password') then
            WriteString('Reboot - Password', String(GetEncryptedValue(AnsiString(LPassword))));
          if not ValueExists('Reboot - Domain') then
            WriteString('Reboot - Domain', String(GetEncryptedValue(AnsiString(LDomain))));
          if not ValueExists('Windows Logon - User Name') then
            WriteString('Windows Logon - User Name', String(GetEncryptedValue(AnsiString(LUserName))));
          if not ValueExists('Windows Logon - Password') then
            WriteString('Windows Logon - Password', String(GetEncryptedValue(AnsiString(LPassword))));
          if not ValueExists('Windows Logon - Domain') then
            WriteString('Windows Logon - Domain', String(GetEncryptedValue(AnsiString(LDomain))));
          if not ValueExists('Maintenance - AdminUser') then
            WriteString('Maintenance - AdminUser', String(GetEncryptedValue(AnsiString(LUserName))));
          if not ValueExists('Maintenance - AdminPassword') then
            WriteString('Maintenance - AdminPassword', String(GetEncryptedValue(AnsiString(LPassword))));
          if not ValueExists('Maintenance - AdminDomain') then
            WriteString('Maintenance - AdminDomain', String(GetEncryptedValue(AnsiString(LDomain))));
          CloseKey;
        end;

        {$IFDEF DATSETTINGS}
         NS_WriteBool('Reboot - Auto Logon', TRUE);
        {$ELSE}
        if OpenKey(NETSTOP_REG_KEY, TRUE) then
        begin
          WriteBool('Reboot - Auto Logon', TRUE);
          CloseKey;
        end;
        {$ENDIF}
      end;
    finally
      Free;
    end;
  end;
end;

procedure TfmMain.DeleteOldRegistryKeys;
var
  Reg: TRegistry;
  sl: TStringList;
  i: Integer;
begin
  DeleteValues(HKEY_CURRENT_USER, 'Software\Moonrise Systems Inc\NetStopPro');
  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey('Software\Moonrise Systems Inc\NetStopPro', FALSE) then
    begin
      sl := TStringList.Create;
      try
        sl.Clear;
        Reg.GetKeyNames(sl);
        for i := 0 to (sl.Count -1) do
        begin
          if sl[i] <> 'KioskWatchRemote' then
            Reg.DeleteKey('Software\Moonrise Systems Inc\NetStopPro\' + sl[i]);
        end;
      finally
        sl.Free;
      end;
      Reg.CloseKey;
    end;
  finally
    Reg.Free;
  end;
  DeleteValues(HKEY_CURRENT_USER, 'Software\Moonrise Systems Inc');

  //mh 4/19/2010 - Delete this key if found -
  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    if reg.KeyExists('Software\Microsoft\Shared Tools\Text Converters\Import\MSWord6.wpc') then
      reg.DeleteKey('Software\Microsoft\Shared Tools\Text Converters\Import\MSWord6.wpc');
  finally
    Reg.Free;
  end;

end;

procedure TfmMain.SetSecurityOnDirectories;
var
   LINIDir, LLogDir: String;
begin
  {$IFDEF DATSETTINGS}
  LINIDir := NS_ReadString('General - Previous ini');
  LLogDir := ExtractFileDir(NS_ReadString('Log File - Log File Location'));
  {$ELSE}
  with TRegistry.Create(KEY_READ) do
  begin
    try
      RootKey := HKEY_LOCAL_MACHINE;
      if OpenKey(NETSTOP_REG_KEY, FALSE) then
      begin
        LINIDir := ReadString('General - Previous ini');
        LLogDir := ExtractFileDir(ReadString('Log File - Log File Location'));
        CloseKey;
      end;
    finally
      Free;
    end;
  end;
  {$ENDIF}

  SetFolderPermissions(LINIDir);
  SetFolderPermissions(LLogDir);
  SetDescendingFolderPermissions(ExtractFileDir(ParamStr(0)));
  //SetDirectoryAccess(ExtractFileDir(ParamStr(0)));
end;

procedure TfmMain.Configure;
var
  LCurrent : String;
  iOwnerID, iKioskID : integer;
  iVFC, iOwnerValidationString : String;
  sMulti, sRegistrationCode, sRegistrationID : string;
  sWow6432Node : string;
  sKeyToOpen1 : string;
  sKeyToOpen2 : string;
begin
  iOwnerID := 0;
  iKioskID := 0;
  iVFC := '';
  iOwnerValidationString := '';

  sMulti := '';
  sRegistrationCode := '';
  sRegistrationID := '';

  if Is64Bit then
    sWow6432Node := 'Wow6432Node\'
  else
    sWow6432Node := '';

  sKeyToOpen1 := '';
  sKeyToOpen2 := '';


  if not IsWindowsAdmin then
  begin
    MessageDlg('You must be running under an Administrator account.', mtError, [mbOK], 0);
    EXIT;
  end;

  pbMain.StepBy(1);

  if InLocalUser then
  begin
    Dlog('Moving Registry Keys From HKEY_LOCAL_USER');

    sKeyToOpen1 := 'SOFTWARE\' + sWow6432Node + 'Moonrise Systems Inc\NetStopPro\' + VERSION_NUMBER;
    MoveKeys(HKEY_CURRENT_USER, 'SOFTWARE\Moonrise Systems Inc\NetStopPro', HKEY_LOCAL_MACHINE, sKeyToOpen1);

    sKeyToOpen1 := 'SOFTWARE\' + sWow6432Node + 'Moonrise Systems Inc\AccountPro\' + VERSION_NUMBER;
    MoveKeys(HKEY_CURRENT_USER, 'SOFTWARE\Moonrise Systems Inc\AccountPro', HKEY_LOCAL_MACHINE, sKeyToOpen1);
    MoveRegistrationInfo;

    MoveAutoLogonInfo;
  end
  else
  begin
    //Upgrade Version
    LCurrent := GetCurrentVersion;
    if '' <> Trim(LCurrent) then
    begin
      if LCurrent <> VERSION_NUMBER then
      begin
        sbMain.SimpleText := 'Migrating Settings to New Version';

        //mh 1/24/2013
        //get/set owner/kiosk/vfc/validation string
        with TRegistry.Create do
        begin
          try
            sKeyToOpen1 := 'SOFTWARE\' + sWow6432Node + 'Moonrise Systems Inc\NetStopPro\' + LCurrent;

            RootKey := HKEY_LOCAL_MACHINE;
            if OpenKey(sKeyToOpen1, TRUE) then
            begin
              iOwnerID := ReadInteger('Owner ID');
              iKioskID := ReadInteger('Kiosk ID');
              iVFC := ReadString('VFC');
              iOwnerValidationString := ReadString('Owner Validation String');
              CloseKey;
            end;
          finally
            Free;
          end;
        end;
        SetOwnerSpecifics(iOwnerID,iKioskID,iVFC,iOwnerValidationString);
        //

        //mh 1/24/2013
        //get/set multi/Registration Code/Registration ID string
        with TRegistry.Create do
        begin
          try
            sKeyToOpen1 := 'SOFTWARE\' + sWow6432Node + 'Moonrise Systems Inc';

            RootKey := HKEY_LOCAL_MACHINE;
            if OpenKey(sKeyToOpen1, TRUE) then
            begin
              if ValueExists('Multi') then
                sMulti := ReadString('Multi');
              if ValueExists('Registration Code') then
                sRegistrationCode := ReadString('Registration Code');
              if ValueExists('Registration ID') then
                sRegistrationID := ReadString('Registration ID');
              CloseKey;
            end;
          finally
            Free;
          end;
        end;
        SetRegistrationSpecifics(sMulti,sRegistrationCode,sRegistrationID);
        //

        Dlog('Upgrading Version Info');
        //mh 10/21/2011 - If DATSETTINGS defined, the movekeys proc will not move v5 values
        //Old values will be copied out and converted.

        //mh 1/23/2013 here is where the duplicate 5.0 tree came from
        //MoveKeys(HKEY_LOCAL_MACHINE, 'Software\Moonrise Systems Inc\NetStopPro\' + LCurrent, HKEY_LOCAL_MACHINE, 'Software\Moonrise Systems Inc\NetStopPro\' + VERSION_NUMBER);

        sKeyToOpen1 := 'SOFTWARE\' + sWow6432Node + 'Moonrise Systems Inc\NetStopPro\' + LCurrent;
        sKeyToOpen2 := 'SOFTWARE\' + sWow6432Node + 'Moonrise Systems Inc\NetStopPro\' + VERSION_NUMBER;

        {$IFDEF DATSETTINGS}
        //this creates a dat file from the existing prior version registry keys
        DoDatFix(HKEY_LOCAL_MACHINE, sKeyToOpen1, HKEY_LOCAL_MACHINE, sKeyToOpen2);
        {$ENDIF}

        sKeyToOpen1 := 'SOFTWARE\' + sWow6432Node + 'Moonrise Systems Inc\AccountPro\' + LCurrent;
        sKeyToOpen2 := 'SOFTWARE\' + sWow6432Node + 'Moonrise Systems Inc\AccountPro\' + VERSION_NUMBER;

        MoveKeys(HKEY_LOCAL_MACHINE, sKeyToOpen1, HKEY_LOCAL_MACHINE, sKeyToOpen2);
      end;
    end;

    //mh 9/10/2012 - no idea why this was in here.  This was the cause of some of the doubled up keys
    //else
    //begin
    //  Dlog('Moving Test Builds');
    //  MoveKeys(HKEY_LOCAL_MACHINE, 'Software\Moonrise Systems Inc\NetStopPro', HKEY_LOCAL_MACHINE, 'Software\Moonrise Systems Inc\NetStopPro\' + VERSION_NUMBER);
    //  MoveKeys(HKEY_LOCAL_MACHINE, 'Software\Moonrise Systems Inc\AccountPro', HKEY_LOCAL_MACHINE, 'Software\Moonrise Systems Inc\AccountPro\' + VERSION_NUMBER);
    //end;
  end;

  pbMain.StepBy(1);
  Dlog('Setting Current Version');
  SetCurrentVersion;
  Dlog('Current Version Set');

  pbMain.StepBy(1);
  sbMain.SimpleText := 'Deleting Old Registry Keys form HKCU';
  Dlog('Deleting Old Registry Keys');
  DeleteOldRegistryKeys;
  Dlog('Old Registry Keys Deleted');

  pbMain.StepBy(1);
  sbMain.SimpleText := 'Setting Defaults';
  Dlog('Setting Defaults/New Keys in Registry');
  {$IFNDEF DATSETTINGS}
  SetDefaultsInRegistry;
  {$ENDIF}
  Dlog('Defaults/New Keys in Registry  Set');

  pbMain.StepBy(1);
  sbMain.SimpleText := 'Installing Keyboard Filter';
  Dlog('Installing Keyboard Filter');
  ExtractDriverBinary(False);
  Dlog('Keyboard Filter Installed');

  pbMain.StepBy(1);
  Dlog('Setting Keyboard Filter Defaults');
  SetKBDriverDefaults;
  Dlog('Keyboard Filter Defaults Set');

  pbMain.StepBy(1);
  sbMain.SimpleText := 'Setting Injection Library Key';
  Dlog('Setting InjectionLibraryKey');
  SetInjectionLibKey;
  Dlog('InjectionLibraryKey Set');

  {4/8/2010 - not needed - service (32 & 64) will be started/stopped by ShellPro
  if not IsXPSP3 then
  begin
    //mh 4/6/2010 - Print Monitor Service must now be completely
    //stopped & uninstalled before installing / starting new version
    //an issue for updating pre ver 366 sites
    Dlog('Stop The Printer Service');
    if not PrinterServiceStopped then
    begin
      StopPrinterService;
    end;
    Dlog('Printer Service Stopped');

    Dlog('Uninstalling Printer Service');
    while not PrinterServiceStopped do begin
      Application.ProcessMessages;
      Sleep(1000);
    end;
    UninstallPrinterService;
    Dlog('Printer Service Uninstalled');
  end;
  }

  sbMain.SimpleText := 'Installing Printer Monitor';
  Dlog('Installing Printer Monitor');
  SetUpPrinterService;
  Dlog('Printer Monitor Installed');

  pbMain.StepBy(1);
  sbMain.SimpleText := 'Setting Permissions On Directories';
  Dlog('Setting Permissions On Directory');
  SetSecurityOnDirectories;
  Dlog('Permissions On Directory Set');

  //Requires User Interaction
  {Dlog('Setting Up Netstop User');
  try
    SetUpNetStopUser(0);
  except
  end;
  Dlog('Netstop User Set Up');}
  Application.Terminate;
end;

procedure TfmMain.Dlog(ALogStr: String);
var
  FLogFileName: String;
  f: TextFile;
  s: String;
begin
  try
    FLogFileName := IncludeTrailingPathDelimiter(ExtractFileDir(ParamStr(0))) + 'Config.log';
    AssignFile(f, FLogFileName);

    if FileExists(FLogFileName) then
      Append(f)
    else
      Rewrite(f);

    try
      s := FormatDateTime('DD-MMM-YYYY hh:nn:ss.zzz', Now) + ' ' + ALogStr;
      Writeln(f);
    finally
      CloseFile(f);
    end;
  except

  end;
end;
{===============================================================================
  End Of Custom Methods
===============================================================================}
procedure TfmMain.tmMainTimer(Sender: TObject);
begin
  sbMain.SimpleText := 'Netstop Pro Configuration';
  tmMain.Enabled := False;
  Configure;
  Application.Terminate;
end;

//mh per Nigel - New Print Monitor.  Kludge to deal with XP SP3 exception in way it handles print
procedure TfmMain.SetInjectionLibKey;
var
  AppDir, LogFileLocation : string;
  Info : TOSProduct;
begin
  AppDir := ExtractFilePath(Application.ExeName);
  LogFileLocation := '';
  Info := TOSProduct.Create;

  // DATSETTINGS NOT USED HERE for Print Monitor specific settings.
  // Need to get Log File spec for Print Monitor
  {$IFDEF DATSETTINGS}
  NS_OpenSettings;
  if NS_ValueExists('Log File - Log File Location') then
    LogFileLocation := NS_ReadString('Log File - Log File Location');
  NS_CloseSettings;
  {$ENDIF}

  with TRegistry.Create do
  begin
    try
      RootKey := HKEY_LOCAL_MACHINE;
      if OpenKey('Software\Moonrise Systems Inc\NetstopPro\6.0', FALSE) then
      begin
        if Is64Bit then
        begin
          if ValueExists('InjectionLibrary32') then
            DeleteValue('InjectionLibrary32');
          WriteString('InjectionLibrary64',AppDir + 'PrintMonitor64.dll');
          {$IFDEF DATSETTINGS}
          LogFileLocation := Stringreplace(LogFileLocation,'Program Files\','Program Files (x86)\',[rfReplaceAll]);
          WriteString('Log File - Log File Location',LogFileLocation);
          {$ENDIF}
          CloseKey;
        end;

        if not Is64Bit then
        begin
          if ValueExists('InjectionLibrary64') then DeleteValue('InjectionLibrary64');

          if (Info.WindowsVersion = vWinXP) then
          begin
            WriteString('InjectionLibrary32','Legacy PrintMonitor.dll');
            //WriteString('InjectionLibrary32',AppDir + 'PrintMonitorXP.dll');
            //mh 4/8/2010 - this is not needed - raises hell with Host Based Printer Drivers
            //WriteInteger('DLL Injection - System Processes',1);
            WriteInteger('DLL Injection - System Processes',0);
          end else begin
            WriteString('InjectionLibrary32',AppDir + 'PrintMonitor32.dll');
            WriteInteger('DLL Injection - System Processes',0);
          end;

          {$IFDEF DATSETTINGS}
          WriteString('Log File - Log File Location',LogFileLocation);
          {$ENDIF}
          CloseKey;
        end;
      end;

    finally
      Free;
    end;
  end;
  Info.Free;
end;

end.