unit UserType;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, TntForms, StdCtrls, TntStdCtrls, IBEButton, IBEAntialiasButton,
  TntExtCtrls, OtherLanguages;

type
  TfmUserType = class(TTntForm)
    RadioGroupUserType: TTntRadioGroup;
    btnOK: TIBEAntialiasButton;
    GroupBoxDomainName: TTntGroupBox;
    ebDomain: TTntEdit;
    procedure btnOKClick(Sender: TObject);
    procedure RadioGroupUserTypeClick(Sender: TObject);
  private
    { Private declarations }
    FLanguage              : Integer;
    FLimitedUserType       : Integer;
    FDomainName            : String;
    procedure SetDomainName(const AValue: String);
    procedure SetLanguage;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent; ALanguage: Integer); reintroduce;
    property LimitedUserType: Integer read FLimitedUserType;
    property DomainName: String read FDomainName write SetDomainName;
  end;

implementation

{$R *.DFM}
{===============================================================================
  Custom Methods
===============================================================================}
constructor TfmUserType.Create(AOwner: TComponent; ALanguage: Integer);
begin
  inherited Create(AOwner);
  FLanguage := ALanguage;
  SetLanguage;
  RadioGroupUserType.ItemIndex := 0;
end;

procedure TfmUserType.SetDomainName(const AValue: String);
begin
  if '' <> Trim(AValue) then
  begin
    FDomainName := Trim(AValue);
    RadioGroupUserType.ItemIndex := 1;
  end else
  begin
    FDomainName := '';
    RadioGroupUserType.ItemIndex := 0;
  end;
end;

procedure TfmUserType.SetLanguage;
begin
  //Self.Caption := GetTextFromResourceOrRegistry(FLanguage, 644);
  //RadioGroupUserType.Items[0] := GetTextFromResourceOrRegistry(FLanguage, 642);
  //RadioGroupUserType.Items[1] := GetTextFromResourceOrRegistry(FLanguage, 643);
  //btnOK.Caption := GetTextFromResourceOrRegistry(FLanguage, 410);
  //GroupBoxDomainName.Caption := GetTextFromResourceOrRegistry(FLanguage, 639);
end;
{===============================================================================
  End Of Custom Methods
===============================================================================}
procedure TfmUserType.btnOKClick(Sender: TObject);
begin
  FLimitedUserType := RadioGroupUserType.ItemIndex;
  FDomainName := Trim(ebDomain.Text);
  if (1 = FLimitedUserType) and ('' = FDomainName) then
    MessageDlg(GetTextFromResourceOrRegistry(FLanguage, 645), mtError, [mbOK], 0)
  else
    ModalResult := mrOK;
end;

procedure TfmUserType.RadioGroupUserTypeClick(Sender: TObject);
begin
  case RadioGroupUserType.ItemIndex of
    1: ebDomain.Enabled := True;
  else
    ebDomain.Text := '';
    ebDomain.Enabled := False;
    FDomainName := '';
  end;
end;

end.
