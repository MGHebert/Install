unit UserSelect;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, TntForms, ComCtrls, TntComCtrls, StdCtrls, TntStdCtrls, IBEButton,
  IBEAntialiasButton, ExtCtrls, TntExtCtrls, cmpNetServer, cmpNetUser,
  OtherLanguages, Utilities;

type
  TfmUserSelect = class(TTntForm)
    pnMain: TTntPanel;
    gbUsers: TTntGroupBox;
    pnDomain: TTntPanel;
    LabelDomain: TTntLabel;
    ebDomain: TTntEdit;
    btnList: TIBEAntialiasButton;
    tvUsers: TTntTreeView;
    pnBottom: TTntPanel;
    pnApply: TTntPanel;
    btnOK: TIBEAntialiasButton;
    pnNew: TTntPanel;
    ListBoxGroups: TTntListBox;
    LabelMemberOf: TTntLabel;
    btnCancel: TIBEAntialiasButton;
    procedure btnCancelClick(Sender: TObject);
    procedure tvUsersChange(Sender: TObject; Node: TTreeNode);
    procedure btnOKClick(Sender: TObject);
    procedure btnListClick(Sender: TObject);
  private
    { Private declarations }
    FLanguage: Integer;
    FLoading: Boolean;
    FSID: String;
    FUserName: String;
    FDomainName: String;
    procedure GetUsers(ADomainName: String);
    procedure GetLocalGroups(AUser, ADomain: String);
    procedure GetGlobalGroups(AUser, ADomain: String);
    procedure SetLanguage;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent; ALanguage: Integer; ADomain: String); reintroduce;
    property UserName: String read FUserName;
    property Domain: String read FDomainName;
    property SID: String read FSID;
  end;

implementation

{$R *.DFM}
{===============================================================================
  Custom Methods
===============================================================================}
constructor TfmUserSelect.Create(AOwner: TComponent; ALanguage: Integer; ADomain: String);
begin
  inherited Create(AOwner);
  FLoading := False;
  FLanguage := ALanguage;
  SetLanguage;
  ebDomain.Text := ADomain;
  GetUsers(ADomain);
end;

procedure TfmUserSelect.GetUsers(ADomainName: String);
var
  NetServer: TNetServer;
  sl: TStringList;
  node: TTntTreeNode;
  i: Integer;
begin
  FLoading := True;
  tvUsers.Items.Clear;
  NetServer := TNetServer.Create;
  try
    if '' <> Trim(ADomainName) then
      NetServer.SetNameToPDC(ADomainName);
    sl := TStringList.Create;
    try
      sl.Clear;
      NetServer.GetUsers([fltrNormal], sl);

      node := tvUsers.Items.AddChild(nil, 'Users');

      for i := 0 to (sl.Count - 1) do
        tvUsers.Items.AddChild(node, sl[i]);
    finally
      sl.Free;
    end;
  finally
    NetServer.Free;
  end;
  tvUsers.Items[0].Expand(True);
  FLoading := False;
end;

procedure TfmUserSelect.GetLocalGroups(AUser, ADomain: String);
var
  User   : TNetUser;
  Server : TNetServer;
  sl     : TStringList;
  i      : Integer;
begin
  Server := TNetServer.Create;
  try
    User := TNetUser.Create;
    try
      User.Server := Server;
      if '' <> Trim(ADomain) then
        User.UserName := ADomain + '\' + AUser
      else
        User.UserName := AUser;

      try
        sl := TStringList.Create;
        try
          User.GetLocalGroups(sl);
        except
          //Suppress User Not Found Error
        end;
        for i := 0 to (sl.Count -1) do
          ListBoxGroups.Items.Add(sl[i]  + ' (Local)');
      finally
        sl.Free;
      end;
    finally
      User.Free;
    end;
  finally
    Server.Free;
  end;
end;

procedure TfmUserSelect.GetGlobalGroups(AUser, ADomain: String);
var
  User   : TNetUser;
  Server : TNetServer;
  sl     : TStringList;
  i      : Integer;
begin
  Server := TNetServer.Create;
  try
    User := TNetUser.Create;
    try
      if '' <> Trim(ADomain) then
        Server.SetNameToPDC(ADomain);
      User.Server := Server;
      User.UserName := AUser;

      try
        sl := TStringList.Create;
        try
          User.GetGlobalGroups(sl);
        except
          //Suppress User Not Found Error
        end;
        for i := 0 to (sl.Count -1) do
          ListBoxGroups.Items.Add(sl[i] + ' (Global)');
      finally
        sl.Free;
      end;
    finally
      User.Free;
    end;
  finally
    Server.Free;
  end;
end;

procedure TfmUserSelect.SetLanguage;
begin
  Self.Caption := GetTextFromResourceOrRegistry(FLanguage, 638);
  btnOK.Caption := GetTextFromResourceOrRegistry(FLanguage, 410);
  btnCancel.Caption := GetTextFromResourceOrRegistry(FLanguage, 411);
  btnList.Caption := GetTextFromResourceOrRegistry(FLanguage, 233);
  LabelDomain.Caption := GetTextFromResourceOrRegistry(FLanguage, 639);
  LabelMemberOf.Caption := GetTextFromResourceOrRegistry(FLanguage, 640);
end;
{===============================================================================
  End Of Custom Methods
===============================================================================}
procedure TfmUserSelect.btnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TfmUserSelect.tvUsersChange(Sender: TObject; Node: TTreeNode);
begin
  if not FLoading then
  begin
    ListBoxGroups.Items.Clear;
    if GetPCName = Trim(ebDomain.Text) then
      GetLocalGroups(Node.Text, '')
    else
    begin
      GetLocalGroups(Node.Text, ebDomain.Text);
      GetGlobalGroups(Node.Text, ebDomain.Text);
    end;
  end;
end;

procedure TfmUserSelect.btnOKClick(Sender: TObject);
begin
  if tvUsers.SelectionCount = 1 then
  begin
    if tvUsers.Selected.Index > 0 then
    begin
      FUserName := tvUsers.Selected.Text;
      FDomainName := Trim(ebDomain.Text);
      if '' = FDomainName then
      begin
        FDomainName := GetPCName;
        FSID := GetSID(FUserName);
      end else
        FSID := GetSID(FDomainName + '\' + FUserName);
      ModalResult := mrOK;
    end;
  end;
end;

procedure TfmUserSelect.btnListClick(Sender: TObject);
begin
  if GetPCName = Trim(ebDomain.Text) then
    GetUsers('')
  else
    GetUsers(Trim(ebDomain.Text));
end;

end.