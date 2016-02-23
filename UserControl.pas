unit UserControl;

interface

uses
  SysUtils, Classes, Utilities, Windows, cmpNetServer, cmpNetUser, UserType,
  Registry, OtherLanguages, Dialogs, Constants, OSProduct;

const
  NETSTOP_USER = 'netstoplimited';
  NETSTOP_PSSWD = 'netstop';

function NetStopUserExists(ADomainName: AnsiString): Boolean;
procedure CreateNetStopUser(ADomainName: AnsiString);
function GetLimitedUserType(var ADomain: AnsiString): Integer;
procedure SetLimitedUserType(const AValue: Integer; const ADomain: AnsiString);
function SetUpNetStopUser(ALanguage: Integer): Boolean;
procedure SetAutoLogonValues(AUser, APassword, ADomain: AnsiString);

implementation

function NetStopUserExists(ADomainName: AnsiString): Boolean;
var
  Server  : TNetServer;
  LUser   : AnsiString;
  LDomain : AnsiString;
  sl      : TStringList;
begin
  GetSID(LUser, LDomain);
  Server := TNetServer.Create;
  try
    if '' <> Trim(String(ADomainName)) then
      Server.SetNameToPDC(String(ADomainName));
    sl := TStringList.Create;
    try
      sl.Clear;
      Server.GetUsers([fltrNormal], sl);
      Result := (-1 <> sl.IndexOf(NETSTOP_USER));
    finally
      sl.Free;
    end;
  finally
    Server.Free;
  end;
end;

procedure CreateNetStopUser(ADomainName: AnsiString);
var
  NetServer: TNetServer;
  User     : TNetUser;
  LUser   : AnsiString;
  LDomain : AnsiString;
begin
  GetSID(LUser, LDomain);
  NetServer := TNetServer.Create;
  try
    if '' <> Trim(String(ADomainName)) then
      NetServer.SetNameToPDC(String(ADomainName));
    User := TNetUser.Create;
    try
      User.UserName := NETSTOP_USER;
      User.CreateAccount('NetStop Limited User Account', NETSTOP_PSSWD);
      User.AddToLocalGroup('Users');
    finally
      User.Free;
    end;
  finally
    NetServer.Free;
  end;
end;

function GetLimitedUserType(var ADomain: AnsiString): Integer;
begin
  Result := -1;
  ADomain := '';
  with TRegistry.Create do
  begin
    try
      RootKey := HKEY_LOCAL_MACHINE;
      Access := KEY_READ;
      if OpenKey(NETSTOP_REG_KEY, False) then
      begin
        if ValueExists('LimitedUserType') then
          Result := ReadInteger('LimitedUserType');
        if ValueExists('LimitedUserDomain') then
          ADomain := AnsiString(ReadString('LimitedUserDomain'));
        CloseKey;
      end;
    finally
      Free;
    end;
  end;
end;

procedure SetLimitedUserType(const AValue: Integer; const ADomain: AnsiString);
begin
  with TRegistry.Create do
  begin
    try
      RootKey := HKEY_LOCAL_MACHINE;
      if OpenKey(NETSTOP_REG_KEY, True) then
      begin
        WriteInteger('LimitedUserType', AValue);
        WriteString('LimitedUserDomain', String(ADomain));
        CloseKey;
      end;
    finally
      Free;
    end;
  end;
end;

function SelectUserType(ALanguage: Integer; var ADomain: AnsiString): Integer;
var
  fm : TfmUserType;
begin
  fm := TfmUserType.Create(nil, ALanguage);
  try
    fm.ShowModal;
    Result := fm.LimitedUserType;
    ADomain := AnsiString(fm.DomainName);
  finally
    fm.Free;
  end;
end;

function SetUpNetStopUser(ALanguage: Integer): Boolean;
var
  LLimitedUserType : Integer;
  LDomain          : AnsiString;
  OS               : TOSProduct;
  LHasDomain       : Boolean;
begin
  OS := TOSProduct.Create;
  try
    LHasDomain := not ((vWinVista = OS.WindowsVersion) and  (pHome = OS.ProductVersion));
  finally
    OS.Free;
  end;

  Result := False;
  LLimitedUserType := GetLimitedUserType(LDomain);

  if -1 = LLimitedUserType then
  begin
    if LHasDomain then
      LLimitedUserType := SelectUserType(ALanguage, LDomain)
    else
      LLimitedUserType := 0;

    if 1 = LLimitedUserType then
    begin
      if not RunningAsGlobalAdmin(String(LDomain)) then
      begin
        MessageDlg(GetTextFromResourceOrRegistry(ALanguage, 646), mtError, [mbOK], 0);
        EXIT;
      end else
      begin
        SetLimitedUserType(LLImitedUserType, LDomain);
        Result := TRUE;
      end;
    end
    else if 0 = LLimitedUserType then
    begin
      SetLimitedUserType(LLImitedUserType, '');
      Result := TRUE;
    end;
  end else
    Result := TRUE;

  if not NetStopUserExists(LDomain) then
  begin
    CreateNetStopUser(LDomain);
    with TRegistry.Create do
    begin
      try
        RootKey := MyRootKey;
        if OpenKey(NETSTOP_REG_KEY, FALSE) then
        begin
          WriteString('Windows Logon - User Name', NETSTOP_USER);
          WriteString('Windows Logon - Password', NETSTOP_PSSWD);
          WriteString('Windows Logon - Domain Name', String(LDomain));
          CloseKey;
        end;
      finally
        Free;
      end;
    end;
  end;
end;

procedure SetAutoLogonValues(AUser, APassword, ADomain: AnsiString);
begin
  with TRegistry.Create do
  begin
    try
      RootKey := HKEY_LOCAL_MACHINE;
      if OpenKey('\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon', True) then
      begin
        WriteString('DefaultUserName', String(AUser));
        WriteString('DefaultPassword', String(APassword));
        WriteString('DefaultDomainName', String(ADomain));
        CloseKey;
      end;
    finally
      Free;
    end;
  end;
end;

end.
