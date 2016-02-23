program SpConfig;

uses
  ExceptionLog,
  Forms,
  Main in 'Main.pas' {fmMain: TTntForm},
  RegistryFunctions in 'RegistryFunctions.pas',
  NSDATSettingsUtils in '..\..\Framework\Settings\NSDATSettingsUtils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Configure Netstop';
  Application.CreateForm(TfmMain, fmMain);
  Application.Run;
end.
